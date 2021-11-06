//
//  UpdateStockViewController.swift
//  StockDividendTracker
//
//  Created by Calvin Li on 2021-04-06.
//

import UIKit

class UpdateStockViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    
    var stock: Stock!

    @IBOutlet weak var sharesTextField: UITextField!
    @IBOutlet weak var dividendTextField: UITextField!
    @IBOutlet weak var frequencyTextField: UITextField!
    @IBOutlet weak var updateButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidLoad()

        let index = StockList.get.index
        stock = StockList.get.stocks[index]
        
        sharesTextField.delegate = self
        dividendTextField.delegate = self
        frequencyTextField.delegate = self
        
        self.title = "Update \(stock.getTicker())"
        sharesTextField.text = "\(stock.getShares())"
        dividendTextField.text = "\(stock.getDividend())"
        frequencyTextField.text = "\(stock.getFrequency())"
        updateButton.isEnabled = false
    }
    @IBAction func updateStock(_ sender: Any)
    {
        stock.updateStock(shares: Int(sharesTextField.text!)!, dividend: Double(dividendTextField.text!)!,dividendFrequency: Int(frequencyTextField.text!)!)
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        updateButton.isEnabled = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateUpdateButtonState()
    }
    
    private func updateUpdateButtonState() {
        // Disable the Save button if the text field is empty.
        if (frequencyTextField.text != "" && sharesTextField.text != "" && dividendTextField.text != "")
        {
            if let frequency = Int(frequencyTextField.text!), let shares = Int(sharesTextField.text!), let dividend = Double(dividendTextField.text!)
            {
                if (frequency == 12 || frequency == 4) && shares > 0 && dividend > 0.0
                {
                    updateButton.isEnabled = true
                }
            }
            else
            {
                updateButton.isEnabled = false
                return
            }
        }
        
    }
    @IBAction func tapped(_ sender: Any) {
        frequencyTextField.resignFirstResponder()
        sharesTextField.resignFirstResponder()
        dividendTextField.resignFirstResponder()
    }
}
