//
//  Stock.swift
//  StockDividendTracker
//
//  Created by Calvin Li on 2021-04-01.
//

import Foundation

class Stock: Codable {
    private let ticker: String
    private var price: Double
    private var shares: Int
    private var dividend: Double
    private var dividendFrequency: Int
    private let url: String
    private var totalValue: Double
    private var currency: String
    private var daysRange: String
    private var fiftyTwoWeekRange: String
    private var peRatio: String
    private var name: String
    private var annualDividend: Double
    
    init?(ticker: String, name: String, price: Double, currency: String, daysRange:String,fiftyTwoWeekRange: String, peRatio: String, shares: Int, dividend: Double, dividendFrequency: Int, url: String)
    {
        self.ticker = ticker
        self.price = price
        self.shares = shares
        self.dividend = dividend
        self.dividendFrequency = dividendFrequency
        self.url = url
        self.totalValue = price * Double(shares)
        self.currency = currency
        self.daysRange = daysRange
        self.fiftyTwoWeekRange = fiftyTwoWeekRange
        self.peRatio = peRatio
        self.name = name
        self.annualDividend = Double(shares) * dividend * Double(dividendFrequency)
    } //init?
    
    //ADD get functions
    
    func getTicker() -> String
    {
        return self.ticker
    }
    func getPrice() -> Double
    {
        return self.price
    }
    func getShares() -> Int
    {
        return self.shares
    }
    func getTotalValue() -> Double
    {
        return self.totalValue
    }
    func getFrequency() -> Int
    {
        return self.dividendFrequency
    }
    func getDividend() -> Double
    {
        return self.dividend
    }
    func getWebURL() -> String
    {
        return self.url
    }
    func getCurrency() -> String
    {
        return self.currency
    }
    func getName() -> String
    {
        return self.name
    }
    func getPERatio() -> String
    {
        return self.peRatio
    }
    func getFiftyTwoWeekRange() -> String
    {
        return self.fiftyTwoWeekRange
    }
    func getDaysRange() -> String
    {
        return self.daysRange
    }
    func getAnnualDividend() -> Double
    {
        return self.annualDividend
    }
    
    func setPrice(price: Double)
    {
        self.price = price
        self.totalValue = price * Double(shares)
    }
    func setShares(shares:Int)
    {
        self.shares = shares
        self.totalValue = price * Double(shares)
        self.annualDividend = Double(shares) * dividend * Double(dividendFrequency)
    }
    func setDividend(dividend: Double)
    {
        self.dividend = dividend
        self.annualDividend = Double(shares) * dividend * Double(dividendFrequency)
    }
    func setCurrency(currency:String)
    {
        self.currency = currency
    }
    func setName(name: String)
    {
        self.name = name
    }
    func setFiftyTwoWeekRange(weekRange: String)
    {
        self.fiftyTwoWeekRange = weekRange
    }
    func setPERatio(peRatio: String)
    {
        self.peRatio = peRatio
    }
    func setDaysRange(daysRange: String)
    {
        self.daysRange = daysRange
    }
    
    func updateStock(shares: Int, dividend: Double, dividendFrequency: Int) {
        self.shares = shares
        self.dividend = dividend
        self.dividendFrequency = dividendFrequency
        self.totalValue = price * Double(shares)
        self.annualDividend = Double(shares) * dividend * Double(dividendFrequency)
    }
    
    public enum CodingKeys: String, CodingKey
    {
        case ticker
        case price
        case shares
        case dividend
        case dividendFrequency
        case url
        case totalValue
        case currency
        case name
        case peRatio
        case daysRange
        case fiftyTwoWeekRange
        case annualDividend
    }

    required init(from decoder: Decoder) throws
    {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        ticker = try container.decode(String.self, forKey: .ticker)
        price = try container.decode(Double.self, forKey: .price)
        shares = try container.decode(Int.self, forKey: .shares)
        dividend = try container.decode(Double.self, forKey: .dividend)
        dividendFrequency = try container.decode(Int.self, forKey: .dividendFrequency)
        url = try container.decode(String.self, forKey: .url)
        totalValue = try container.decode(Double.self, forKey: .totalValue)
        currency = try container.decode(String.self, forKey: .currency)
        name = try container.decode(String.self, forKey: .name)
        peRatio = try container.decode(String.self, forKey: .peRatio)
        daysRange = try container.decode(String.self, forKey: .daysRange)
        fiftyTwoWeekRange = try container.decode(String.self, forKey: .fiftyTwoWeekRange)
        annualDividend = try container.decode(Double.self, forKey: .annualDividend)

    } //decoder
    
    func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(ticker, forKey: .ticker)
        try container.encode(price, forKey: .price)
        try container.encode(shares, forKey: .shares)
        try container.encode(dividend, forKey: .dividend)
        try container.encode(dividendFrequency, forKey: .dividendFrequency)
        try container.encode(url, forKey: .url)
        try container.encode(totalValue, forKey: .totalValue)
        try container.encode(currency, forKey: .currency)
        try container.encode(name, forKey: .name)
        try container.encode(peRatio, forKey: .peRatio)
        try container.encode(daysRange, forKey: .daysRange)
        try container.encode(fiftyTwoWeekRange, forKey: .fiftyTwoWeekRange)
        try container.encode(annualDividend, forKey: .annualDividend)
    }
    
}

class StockList
{
    static let get = StockList()
    let fileName = "stocklist-file" // unique file name to save data
    var stocks = [Stock]()
    var index = 0
    
    private var valid = true
    
    var fileURL : URL {
        let documentDirectoryURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documentDirectoryURL.appendingPathComponent(fileName)
    }
    
    func addToStocks(ticker: String, name: String, price: Double, currency: String,daysRange:String, fiftyTwoWeekRange: String, peRatio: String, shares: Int, dividend: Double, dividendFrequency: Int, url: String)
    {
        let stock = Stock(ticker: ticker, name: name, price: price, currency: currency, daysRange: daysRange, fiftyTwoWeekRange: fiftyTwoWeekRange, peRatio: peRatio, shares: shares, dividend: dividend, dividendFrequency: dividendFrequency, url: url)
        stocks.append(stock!)
        stocks = stocks.sorted(by: { $0.getTicker() < $1.getTicker() })
    }
    private func saveStocks() throws
    {
        let jsonEncoder = JSONEncoder()
        var jsonData = Data()
        let deck = self.stocks
        do {
            jsonData = try jsonEncoder.encode(deck)
            print(jsonData)
        }
        catch {
            print("cannot encode stocks")
        }
        do {
            try jsonData.write(to: fileURL, options: [])
        } catch { }
            
    } // saveStockList
    
    func loadStocks() throws -> ([Stock], Bool)
    {
        let jsonDecoder = JSONDecoder()
        var stocklist = [Stock]()
        var data = Data()
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            valid = false
            print("cannot read the archive")
        }
        do{
            stocklist  = try jsonDecoder.decode([Stock].self, from: data)
        } catch {
            print("cannot decode Stock from the archive")
        }
        return (stocklist, valid)
    }
    
    func saveStocksState()
    {
        do
        {
           print ("Saving Stocks.")
            try saveStocks()
        }
        catch
        {
           print("Saving Error.")
        }
    }
}
