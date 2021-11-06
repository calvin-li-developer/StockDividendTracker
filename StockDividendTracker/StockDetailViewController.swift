//
//  StockDetailViewController.swift
//  StockDividendTracker
//
//  Created by Calvin Li on 2021-04-05.
//

import UIKit

class StockDetailViewController: UIViewController {

    @IBOutlet weak var sharesLabel: UILabel!
    @IBOutlet weak var totalValueLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var dividendLabel: UILabel!
    @IBOutlet weak var peRatioLabel: UILabel!
    @IBOutlet weak var daysRangeLabel: UILabel!
    @IBOutlet weak var fiftyTwoWeekRangeLabel: UILabel!
    @IBOutlet weak var annualDividendLabel: UILabel!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.isHidden = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(false, animated: false)

        let index = StockList.get.index
        let stock = StockList.get.stocks[index]
        
        updateDisplay(stock: stock)
    }
    
    func updateDisplay(stock: Stock)
    {
        let currencyFormat = NumberFormatter()
        currencyFormat.locale = Locale.current
        currencyFormat.numberStyle = .currency
        
        if let currencyPrice = currencyFormat.string(from: stock.getPrice() as NSNumber)
        {
            priceLabel.text! = "Price: \(currencyPrice) \(stock.getCurrency())"
        }
        if let currencyTotalValue = currencyFormat.string(from: stock.getTotalValue() as NSNumber)
        {
            totalValueLabel.text! = "Total Value: \(currencyTotalValue) \(stock.getCurrency())"
        }
        if let annualDividend = currencyFormat.string(from: stock.getAnnualDividend() as NSNumber)
        {
            annualDividendLabel.text! = "Annual Dividend: \(annualDividend) \(stock.getCurrency())"
        }
        
        title = "\(stock.getName())"
        sharesLabel.text! = "# Of Shares: \(stock.getShares())"
        frequencyLabel.text! = "Frequency: \(stock.getFrequency())"
        dividendLabel.text! = "Dividend: \(stock.getDividend())"
        peRatioLabel.text! = "PE Ratio: \(stock.getPERatio())"
        daysRangeLabel.text! = "Days Range: $\(stock.getDaysRange()) \(stock.getCurrency())"
        fiftyTwoWeekRangeLabel.text! = "52 Week Range: $\(stock.getFiftyTwoWeekRange()) \(stock.getCurrency())"
    }
    @IBAction func updateStockData(_ sender: Any)
    {
        spinner.isHidden = false
        spinner.startAnimating()
        let index = StockList.get.index
        let stock = StockList.get.stocks[index]
        let ticker = stock.getTicker()
        let baseUrl = "https://finance.yahoo.com/quote/" + ticker + "?p=" + ticker
        let url = URL(string: baseUrl)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            let data = data
            let htmlString = String(data: data!, encoding: .utf8)
//            print(htmlString!)
            // Find Strings Between Variables
            let leftSideOf_stockName = "<h1 class=\"D(ib) Fz(16px) Lh(18px)\" data-reactid=\"7\">"
            let rightSideOf_stockName = "</h1></div><div class=\"C"
            
            let leftSideOf_stockMarketPrice = "<span class=\"Trsdu(0.3s) Trsdu(0.3s) Fw(b) Fz(36px) Mb(-4px) D(b)\" data-reactid=\"19\">"
            let rightSideOf_stockMarketPrice = "</span><div class=\"D"
            
            let leftSideOf_Currency = "Currency in "
            let rightSideOf_Currency = "</span></div></div><div class=\"D(ib)"
            
            let leftSideOf_DaysRange = "</td><td class=\"Ta(end) Fw(600) Lh(14px)\" data-test=\"DAYS_RANGE-value\" data-reactid=\"67\">"
            let rightSideOf_DaysRange = "</td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"68\">"
            
            let leftSideOf_52WeekRange = "data-test=\"FIFTY_TWO_WK_RANGE-value\" data-reactid=\"71\">"
            let rightSideOf_52WeekRange = "</td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"72\">"
            
            let leftSideOf_PERatio = "PE_RATIO-value\" data-reactid=\"98\"><span class=\"Trsdu(0.3s) \" data-reactid=\"99\">"
            let rightSideOf_PERatio = "</span></td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"100\">"
            
            // Set the range of the string we need.
            let rangeOf_stockName = htmlString!.range(of: leftSideOf_stockName)!.upperBound..<htmlString!.range(of: rightSideOf_stockName)!.lowerBound
            let rangeOf_stockMarketPrice = htmlString!.range(of: leftSideOf_stockMarketPrice)!.upperBound..<htmlString!.range(of: rightSideOf_stockMarketPrice)!.lowerBound
            let rangeOf_Currency = htmlString!.range(of: leftSideOf_Currency)!.upperBound..<htmlString!.range(of: rightSideOf_Currency)!.lowerBound
            let rangeOf_DaysRange = htmlString!.range(of: leftSideOf_DaysRange)!.upperBound..<htmlString!.range(of: rightSideOf_DaysRange)!.lowerBound
            let rangeOf_52WeekRange = htmlString!.range(of: leftSideOf_52WeekRange)!.upperBound..<htmlString!.range(of: rightSideOf_52WeekRange)!.lowerBound
            let rangeOf_PERatio = htmlString!.range(of: leftSideOf_PERatio)!.upperBound..<htmlString!.range(of: rightSideOf_PERatio)!.lowerBound
            
            let nameArray = htmlString![rangeOf_stockName].split(separator: "-", maxSplits: 1)
            
         
            stock.setName(name: nameArray[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "amp;", with: ""))
            stock.setPrice(price: Double(htmlString![rangeOf_stockMarketPrice].replacingOccurrences(of: ",", with: ""))!)
            stock.setCurrency(currency: String(htmlString![rangeOf_Currency]))
            stock.setDaysRange(daysRange: String(htmlString![rangeOf_DaysRange]))
            stock.setFiftyTwoWeekRange(weekRange: String(htmlString![rangeOf_52WeekRange]))
            stock.setPERatio(peRatio: String(htmlString![rangeOf_PERatio]))
            
            DispatchQueue.main.async {
                self.updateDisplay(stock: stock)
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
            }
        }
        task.resume()
    }
}
