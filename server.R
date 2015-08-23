#################################################################################
# @project : Developing Data Products using Shiny
# @author  : jshiju
# @date    : 21/AUG/15
# @desc    : This source code contains the server module which takes the inputs
#            from the UI and calculate the stock price for a future period  
#            at a specific confidence interval based on the historical price 
#################################################################################

# load required libraries
library (data.table)
library(quantmod)

# initialize variables
cButton <<- 0
ticker <<- "AAPL"
rawData <<- getSymbols (ticker, src = "yahoo", auto.assign = FALSE)

# server code which grabs the inputs and plot the results.
shinyServer(
  function(input, output) {
    
    output$ostartDate <- renderPrint({input$startDate})
    output$oendDate <- renderPrint({input$endDate})
    output$oforecastDays <- renderPrint({input$forecastDays})
    
    output$stockForecast <- renderPlot({
      
      if (cButton < as.numeric (input$update)) {
        cButton <<- input$update
        ticker <<- input$ticker
        rawData <<- getSymbols (ticker, src = "yahoo", auto.assign = FALSE)
      }
      
      attr (rawData, "dimnames")[[2]] <- c ("Open", "High", "Low", "Close", "Volume", "Adjusted")
      stockData <- rawData [ (input$startDate <= index (rawData)) & (index (rawData) <= input$endDate) ]
      
      returns <- Delt (stockData$Close)
      meanReturn <- mean (returns, na.rm = TRUE)
      sdReturn <- sd (returns, na.rm = TRUE)
      qMult <- qnorm (0.5 + input$confidence/200)
      
      predictClose <- as.numeric (tail (stockData$Close, 1)) * (1 + meanReturn) ^ seq (1, input$forecastDays, by = 1)
      predictHigh <- predictClose * (1 + sqrt (seq (1, input$forecastDays, by = 1)) * sdReturn * qMult)
      predictLow <- predictClose * (1 - sqrt (seq (1, input$forecastDays, by = 1)) * sdReturn * qMult)
      
      predict <- data.table (date = seq.Date (from = as.Date (input$endDate) + 1, to = as.Date (input$endDate) + input$forecastDays, by = 1),
                             Close = predictClose, High = predictHigh, Low = predictLow)
      
      plot (x = index (stockData), y = stockData$Close, type = "l", col = "black",
            xlim = c (as.Date (input$startDate), max (as.Date (predict$date))),
            ylim = c (min (stockData$Close, predict$Low), max (stockData$Close, predict$High)),
            main = paste (ticker, " price and forecast"), xlab = "Date", ylab = "Price")
      lines (x = predict$date, predict$Close, lty = 1, col = "red")
      lines (x = predict$date, predict$High, lty = 2, col = "red")
      lines (x = predict$date, predict$Low, lty = 2, col = "red")
      legend ("topleft", legend = c ("Close", "Predicted", paste (input$confidence, "% Confidence Interval")),
              col = c ("black", "red", "red"), lty = c (1, 1, 2))
    })
  }
)