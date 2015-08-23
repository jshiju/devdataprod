#################################################################################
# @project : Developing Data Products using Shiny
# @author  : jshiju
# @date    : 21/AUG/15
# @desc    : This source code contains the UI module which takes the inputs
#            from the UI and plot the stock price for a future period  
#            at a specific confidence interval based on the historical price 
#################################################################################


# load required libraries
library(shiny)

# grab user inputs and send it to server module to plot the graph
shinyUI(pageWithSidebar(
  headerPanel("EQUITY STOCK PRICE FORECAST"),
  sidebarPanel(
    h5 ("About App:"),
    h6 ("For a given stock ticker this will provide a confidence interval of future stock price based on its historical stock price."),
    h5 ("Usage:"),
    h6 ("Enter a stock ticker and a date range to use as input for calculating the confidence interval. 
        The prediction and confidence interval is based on mean daily returns calculated for the sample period."),
    h5 ("Warning:"),
    h6 ("The application pulls data from Yahoo Finance, so will only work with tickers available there (eg: AAPL, GOOG, FB, or TWTR).  
        Inputs are not validated for correctness, so provide reasonable input data."),
    textInput('ticker', 'Ticker: ', 'AAPL'),
    actionButton ("update", "Update data (reload from Yahoo Finance)"),
    h5 (""),
    dateInput ('startDate', 'Start Date: ', value = Sys.Date () - 30),
    dateInput ('endDate', 'End Date: ', value = Sys.Date () - 1),
    numericInput ('forecastDays', 'Forecast period (days): ', 30, min = 1, max = 90, step = 1),
    numericInput ('confidence', 'Confidence Interval (%):', 95, min = 0, max = 99, step = 1)
  ),
  mainPanel(
    tags$b("INPUT CRITERIA"),
    h6 ("START DATE, END DATE & FORECAST DAYS?"),
    verbatimTextOutput("ostartDate"),
    verbatimTextOutput("oendDate"),
    verbatimTextOutput("oforecastDays"),
    plotOutput('stockForecast')
  )
))