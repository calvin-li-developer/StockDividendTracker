//
//  ViewController.swift
//  Dividend-Tracker
//
//  Created by Calvin Li on 2021-04-01.
//

import UIKit

let simpleCellIdentifier = "ReuseIdentifier"

class TableViewCell:UITableViewCell
{
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
}

class ListStockViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var filteredStocks = [Stock]()
    var refreshControl = UIRefreshControl()
    
    let segueID = "StockDetail"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Stock Dividend Manager"
        var valid = false
        var stocks = [Stock]()
        do{
            (stocks, valid) = try StockList.get.loadStocks()
            StockList.get.stocks = stocks
        } catch{
            print("viewDidLoad: Cannot get stocks from the archive")
        }
        if(valid == false)
        {
            addStocks()
        }
        filteredStocks = StockList.get.stocks
        
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(true, animated: false)
        filteredStocks = StockList.get.stocks
        tableView.reloadData()
    }
    
    @objc func refresh(_ sender: AnyObject)
    {
        let update = DispatchQueue(label: "refresh.list.q")
        
        update.sync
        {
            for stock in StockList.get.stocks
            {
                self.updateStockData(stock: stock)
            }
            self.refreshControl.endRefreshing()
        }//DispatchQueue
    }
    
    func updateStockData(stock:Stock)
    {
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
            
            let leftSideOf_stockMarketPrice = "\"18\"><span class=\"Trsdu(0.3s) Trsdu(0.3s) Fw(b) Fz(36px) Mb(-4px) D(b)\" data-reactid=\"19\">"
            let rightSideOf_stockMarketPrice = "</span><div class=\"D(ib) Va(t) \" data-reactid=\"20\">"
            
            let leftSideOf_Currency = "Currency in "
            let rightSideOf_Currency = "</span></div></div><div class=\"D(ib)"
            
            let leftSideOf_DaysRange = "data-test=\"DAYS_RANGE-value\" data-reactid=\"67\">"
            let rightSideOf_DaysRange = "</td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"68\">"
            
            let leftSideOf_52WeekRange = "52 Week Range</span></td><td class=\"Ta(end) Fw(600) Lh(14px)\" data-test=\"FIFTY_TWO_WK_RANGE-value\" data-reactid=\"71\">"
            let rightSideOf_52WeekRange = "/td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"72\">"
            
            let leftSideOf_PERatio = "data-test=\"PE_RATIO-value\" data-reactid=\"98\"><span class=\"Trsdu(0.3s) \" data-reactid=\"99\">"
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
            
            self.filteredStocks = StockList.get.stocks
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        task.resume()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredStocks = StockList.get.stocks.filter({ stock -> Bool in
            switch searchBar.selectedScopeButtonIndex {
            case 0:
                if searchText.isEmpty { return true }
                return stock.getTicker().lowercased().contains(searchText.lowercased())
            case 1:
                if searchText.isEmpty { return true }
                return String(stock.getPrice()).lowercased().contains(searchText.lowercased())
            case 2:
                if searchText.isEmpty { return true }
                return String(stock.getTotalValue()).lowercased().contains(searchText.lowercased())
            default:
                return false
            }
        })
        tableView.reloadData()
    } //textDidChange
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        tableView.reloadData()
    }
    
    func addStocks()
    {
        StockList.get.addToStocks(ticker: "BCE.TO", name: "N/A", price: 57.46, currency: "CAD",daysRange: "N/A", fiftyTwoWeekRange: "N/A", peRatio: "N/A", shares: 12, dividend: 0.875, dividendFrequency: 4, url: "https://finance.yahoo.com/quote/BCE.TO?p=BCE.TO")
        StockList.get.addToStocks(ticker: "ENB.TO", name: "N/A", price: 423.0, currency: "CAD",daysRange: "N/A", fiftyTwoWeekRange: "N/A", peRatio: "0.0", shares: 55, dividend: 0.835, dividendFrequency: 4, url: "https://finance.yahoo.com/quote/ENB.TO?p=ENB.TO")
        StockList.get.addToStocks(ticker: "AAPL", name: "N/A", price: 23.0, currency: "USD",daysRange: "N/A", fiftyTwoWeekRange: "N/A", peRatio: "0.0", shares: 23, dividend: 0.835, dividendFrequency: 4, url: "https://finance.yahoo.com/quote/AAPL?p=AAPL")
        StockList.get.addToStocks(ticker: "TRP", name: "N/A", price: 43.0, currency: "USD",daysRange: "N/A", fiftyTwoWeekRange: "N/A", peRatio: "0.0", shares: 42, dividend: 0.835, dividendFrequency: 4, url: "https://finance.yahoo.com/quote/TRP?p=TRP")
        StockList.get.addToStocks(ticker: "VZ", name: "N/A", price: 32.0, currency: "USD",daysRange: "N/A", fiftyTwoWeekRange: "N/A", peRatio: "0.0", shares: 15, dividend: 0.835, dividendFrequency: 12, url: "https://finance.yahoo.com/quote/VZ?p=VZ")
        StockList.get.addToStocks(ticker: "RY.TO", name: "N/A", price: 2.0, currency: "CAD",daysRange: "N/A", fiftyTwoWeekRange: "N/A", peRatio: "0.0", shares: 39, dividend: 1.08, dividendFrequency: 4, url: "https://finance.yahoo.com/quote/RY.TO?p=RY.TO")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredStocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: simpleCellIdentifier, for: indexPath) as? TableViewCell
        if (cell == nil) {
            cell = TableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: simpleCellIdentifier)
        }
        
        // the cell has an image property, set it
        cell?.tickerLabel.text = filteredStocks[indexPath.row].getTicker()
        // the cell has a text property
        let currencyFormat = NumberFormatter()
        currencyFormat.locale = Locale.current
        currencyFormat.numberStyle = .currency
        if let currencyPrice = currencyFormat.string(from: filteredStocks[indexPath.row].getPrice() as NSNumber)
        {
            cell?.priceLabel?.text = "Stock Price: \(currencyPrice) \(filteredStocks[indexPath.row].getCurrency())"
        }
        
        if let currencyTotalValue = currencyFormat.string(from: filteredStocks[indexPath.row].getTotalValue() as NSNumber)
        {
            cell?.totalPriceLabel?.text = "Total Value: \(currencyTotalValue) \(filteredStocks[indexPath.row].getCurrency())"
        }
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        StockList.get.index = indexPath.row
        performSegue(withIdentifier: segueID, sender: filteredStocks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            StockList.get.stocks.remove(at: indexPath.row)
            filteredStocks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        print("Size After Deletion: \(StockList.get.stocks.count)")
    }
}
