# Stock Dividend Tracker

## Description

The project “Stock Dividend Tracker” is an iOS app that tracks the user’s dividend portfolio. This tracker is used to track how much money you get per dividend frequency, usually dividend frequency is quarterly or monthly, and the annual earning of the dividend stock. In this project you can add stock, remove stock, update and view details of the stock.

## Design & Implementation

This project at minimum will require 4 different UIViewControllers. The first one (StockListView) is to view all the stock’s that the user has and a summary of the stock price and total stock value. The second one (AddStockView) which lets user add the stock they have on to the app. The third is (StockDetailsView) which lets user see more details on the specific stock in the StockListView when clicking on the cell. Lastly, the (UpdateStockView) which lets users update an existing stock in the StockDetailsView. More details can be added like when the stock was last updated. If feasible I might add Finance Yahoo API to track stock value live without user input via searching for stock ticker symbol. This project will only be in Portrait Mode and should be able to work with all IPhones and iPads that support iOS 14.

AddStockView | StockDetailsView | StockListView | UpdateStockView
:-------------------------:|:-------------------------:|:-------------------------:|:-------------------------:
![](https://github.com/calvin-li-developer/Stock_Dividend_Tracker_Swift/blob/main/Stock%20Dividend%20Tracker%20Add%20Stock%20View.png?raw=true)  |  ![](https://github.com/calvin-li-developer/Stock_Dividend_Tracker_Swift/blob/main/Stock%20Dividend%20Tracker%20Detailed%20View.png?raw=true) |  ![](https://github.com/calvin-li-developer/Stock_Dividend_Tracker_Swift/blob/main/Stock%20Dividend%20Tracker%20Home%20View.png?raw=true) |  ![](https://github.com/calvin-li-developer/Stock_Dividend_Tracker_Swift/blob/main/Stock%20Dividend%20Tracker%20Update%20View.png?raw=true)