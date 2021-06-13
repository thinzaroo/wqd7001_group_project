#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(dplyr)
library(ggplot2)

# Define server logic
shinyServer(function(input, output) {
    # ----------------------------------
    #general functions
    stock_list_df <- read.csv('data/FBM_KLCI_stocks_list.csv')
    all_stocks_df <- read.csv('data/FBM_KLCI_historical_price_all_stocks.csv')
    
    #calculate price trend
    plotLineChart = function (maindf, mSymbol) {
      p1 <- ggplot(filter(maindf, Symbol == mSymbol), mapping = aes(Date, Close, group = 1)) +
        geom_line(color="#69b3a2") +
        labs(x = "Date Range", y = "Close Price", 
             title = mSymbol)  
      p1 + theme(axis.text.x=element_text(angle = 90, hjust = 0))
      print(p1)
    }
    
    get_stocks_by_sector <- function(sector_id){
        stocks_by_sector <- stock_list_df %>% filter(SectorId == sector_id) %>% select(Symbol)
    }
    # ----------------------------------
    
    
    # ----------------------------------
    #panel 5
    sector_list <- c("Banking" = "1",
      "Food & Beverages" = "2",
      "Healthcare Equipment & Services" = "3",
      "Plantation" = "4",
      "Telecommunications Service Providers" = "5")
    
    interval_list <- c("All time" = "1",
                       "First Wave" = "2",
                       "Second Wave" = "3",
                       "Third Wave" = "4")
    
    output$user_selection_analysis <- renderUI({
        sector_str <- paste("Sector: ", names(sector_list)[sector_list == input$sector_id])
        interval_str <- paste("Interval: ",  names(interval_list)[interval_list == input$interval_id])
        stock_list <- get_stocks_by_sector(input$sector_id)
        stock_list_str <- paste("List of stocks: ", toString(stock_list))
        
        HTML(paste(sector_str, interval_str, stock_list_str, sep = '<br/>'))
    })
    
    
    # ----------------------------------
})
