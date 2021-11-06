//
//  AddStockViewController.swift
//  StockDividendTracker
//
//  Created by Calvin Li on 2021-04-05.
//

import UIKit

class AddStockViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate{

    @IBOutlet weak var stockTickerTextField: UITextField!
    @IBOutlet weak var sharesTextField: UITextField!
    @IBOutlet weak var dividendTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stockTickerTextField.delegate = self
        sharesTextField.delegate = self
        dividendTextField.delegate = self
        frequencyTextField.delegate = self
        
        super.viewDidLoad()
        self.title = "Add Stock"
        spinner.isHidden = true
        addButton.isEnabled = false;
    }
    
    @IBAction func addStock(_ sender: Any)
    {
        let ticker = String(stockTickerTextField.text!).uppercased()
        var foundStock = false
        
        for stock in StockList.get.stocks
        {
            if stock.getTicker() == ticker
            {
                foundStock = true
                break
            }
        }
        if foundStock == false
        {
            spinner.isHidden = false
            spinner.startAnimating()
            generateStockData(ticker: ticker)
        }
        else
        {
            let message = "The stock list already have this stock. Stock not added."
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated:true, completion: nil)
        }
    }
    func generateStockData(ticker: String)
    {
        
        let baseUrl = "https://finance.yahoo.com/quote/" + ticker + "?p=" + ticker
        let url = URL(string: baseUrl)!
        let shares = Int(self.sharesTextField.text!)!
        let dividend = Double(self.dividendTextField.text!)!
        let dividendFrequency = Int(self.frequencyTextField.text!)!
        let task = URLSession.shared.dataTask(with: url)
        {
            (data, response, error) in
            let data = data
            let htmlString = String(data: data!, encoding: .utf8)
            
            // Find Strings Between what we want
            let leftSideOf_stockName = "<h1 class=\"D(ib) Fz(16px) Lh(18px)\" data-reactid=\"7\">"
            let rightSideOf_stockName = "</h1></div><div class=\"C"
            
            if (htmlString!.contains(leftSideOf_stockName) != false)
            {
                let leftSideOf_stockMarketPrice = "<span class=\"Trsdu(0.3s) Trsdu(0.3s) Fw(b) Fz(36px) Mb(-4px) D(b)\" data-reactid=\"20\">"
                let rightSideOf_stockMarketPrice = "</span><div class=\"D"
                
                let leftSideOf_Currency = "Currency in "
                let rightSideOf_Currency = "</span></div></div><div class=\"D(ib)"
                
                let leftSideOf_DaysRange = "<td class=\"Ta(end) Fw(600) Lh(14px)\" data-test=\"DAYS_RANGE-value\" data-reactid=\"68\">"
                let rightSideOf_DaysRange = "</td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"69\">"
                
                let leftSideOf_52WeekRange = "<td class=\"Ta(end) Fw(600) Lh(14px)\" data-test=\"FIFTY_TWO_WK_RANGE-value\" data-reactid=\"72\">"
                let rightSideOf_52WeekRange = "</td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"73\">"
                
                let leftSideOf_PERatio = "data-test=\"PE_RATIO-value\" data-reactid=\"99\"><span class=\"Trsdu(0.3s) \" data-reactid=\"100\">"
                let rightSideOf_PERatio = "</span></td></tr><tr class=\"Bxz(bb) Bdbw(1px) Bdbs(s) Bdc($seperatorColor) H(36px) \" data-reactid=\"101\">"
                
                let rangeOf_stockName = htmlString!.range(of: leftSideOf_stockName)!.upperBound..<htmlString!.range(of: rightSideOf_stockName)!.lowerBound
                let rangeOf_stockMarketPrice = htmlString!.range(of: leftSideOf_stockMarketPrice)!.upperBound..<htmlString!.range(of: rightSideOf_stockMarketPrice)!.lowerBound
                let rangeOf_Currency = htmlString!.range(of: leftSideOf_Currency)!.upperBound..<htmlString!.range(of: rightSideOf_Currency)!.lowerBound
                
                if htmlString!.contains(leftSideOf_DaysRange) == false
                {
                    DispatchQueue.main.async {
                        self.spinner.stopAnimating()
                        self.spinner.isHidden = true
                        let message = "Error, can't get certain stock attributes."
                        let alert = UIAlertController(title: "Error Stock Attributes", message: message, preferredStyle: .alert)
                        let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                        alert.addAction(action)
                        self.present(alert, animated:true, completion: nil)
                    }
                    return
                }
                
                let rangeOf_DaysRange = htmlString!.range(of: leftSideOf_DaysRange)!.upperBound..<htmlString!.range(of: rightSideOf_DaysRange)!.lowerBound
                let rangeOf_52WeekRange = htmlString!.range(of: leftSideOf_52WeekRange)!.upperBound..<htmlString!.range(of: rightSideOf_52WeekRange)!.lowerBound
                let rangeOf_PERatio = htmlString!.range(of: leftSideOf_PERatio)!.upperBound..<htmlString!.range(of: rightSideOf_PERatio)!.lowerBound
                
                let nameArray = htmlString![rangeOf_stockName].split(separator: "-",maxSplits: 1)
               
                StockList.get.addToStocks(ticker: ticker, name: nameArray[1].trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "amp;", with: ""), price: Double(htmlString![rangeOf_stockMarketPrice].replacingOccurrences(of: ",", with: ""))!, currency: String(htmlString![rangeOf_Currency]),daysRange: String(htmlString![rangeOf_DaysRange]), fiftyTwoWeekRange: String(htmlString![rangeOf_52WeekRange]), peRatio: String(htmlString![rangeOf_PERatio]), shares: shares, dividend: dividend, dividendFrequency: dividendFrequency, url: "https://finance.yahoo.com/quote/" + ticker + "?p=" + ticker)
                
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    self.spinner.stopAnimating()
                }
            }
            else
            {
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                    self.spinner.isHidden = true
                    let message = "Please enter a proper stock ticker symbol."
                    let alert = UIAlertController(title: "Stock Doesn't Exist", message: message, preferredStyle: .alert)
                    let action = UIAlertAction(title: "Okay", style: .default, handler: nil)
                    alert.addAction(action)
                    self.present(alert, animated:true, completion: nil)
                }
            }
        }
        task.resume()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        addButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateAddButtonState()
    }
    
    private func updateAddButtonState() {
        // Disable the Save button if the text field is empty.
        if (stockTickerTextField.text != "" && sharesTextField.text != "" && dividendTextField.text != "" && frequencyTextField.text != "")
        {
            if let frequency = Int(frequencyTextField.text!), let shares = Int(sharesTextField.text!), let dividend = Double(dividendTextField.text!)
            {
                if (frequency == 12 || frequency == 4) && shares > 0 && dividend > 0.0
                {
                    addButton.isEnabled  = true
                }
            }
            else
            {
                addButton.isEnabled  = false
                return
            }
        }
        
    }
    
    @IBAction func tapped(_ sender: Any) {
        stockTickerTextField.resignFirstResponder()
        sharesTextField.resignFirstResponder()
        dividendTextField.resignFirstResponder()
        frequencyTextField.resignFirstResponder()
    }
}
