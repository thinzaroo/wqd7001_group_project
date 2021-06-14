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
library(lubridate)
library(scales)
library(treemap)


# Define server logic
shinyServer(function(input, output) {
    # ----------------------------------
    #general functions
    stock_list_df <- read.csv('data/FBM_KLCI_stocks_list.csv')
    all_stocks_df <- read.csv('data/FBM_KLCI_historical_price_all_stocks.csv')
    
    #reformat all the date
    all_stocks_df$Date <- ymd(all_stocks_df$Date)
    
    get_stocks_by_sector <- function(sector_id){
        stocks_by_sector <- stock_list_df %>% filter(SectorId == sector_id) %>% select(Symbol)
        unlist(stocks_by_sector)
    }
    # ----------------------------------
    # Market Overview
    stock_list_df_1 <- read.csv('data/FBM_KLCI_stocks_list.csv',header = TRUE)
    output$table <- renderDataTable(stock_list_df_1)

    output$tree <- renderPlot({
      
      treemap(stock_list_df_1, 
              index="CompanyName", 
              vSize="MarketCapInBillion", 
              vColor="MarketCapInBillion", 
              type="value", 
              palette="RdYlBu", 
              title=" ", 
              range=c(12,94), n = 9)
    }, height = 500, width = 700 )
    
    
    output$line <- renderPlot({
      performace_df <- read.csv('data/fbm_klci_market_performance.csv',header = TRUE)
      performace_df$Date <- ymd(performace_df$Date)
      performace_df <- performace_df %>% filter(Date >= input$daterange[1] & Date <= input$daterange[2])
      
      p <- ggplot(performace_df, aes(Date, Close, group = 1)) +
        geom_line(color="#69b3a2", size=1, alpha=0.9) +
        labs(x = "Date", y = "Close Price", title = " ") +
        theme(axis.text = element_text(face = "bold", size = rel(1))) +
        scale_x_date(labels=date_format ("%b %y"), breaks=("2 months")) +
        theme(axis.text.x=element_text(angle = 90, hjust = 0))

      print(p)
    }, height = 500, width = 800)
    
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
    
    output$plot_price_analysis_by_sector <- renderPlot({
      stock_list <- get_stocks_by_sector(input$sector_id)
      sector_df <- all_stocks_df %>% filter(Symbol %in% stock_list)
      
      glimpse(sector_df)
      
      g <- ggplot(data = sector_df, aes(x=Date, y=Close, color=Symbol)) + geom_line()
      
      theme_bare <- theme(panel.background = element_blank(), 
                          panel.grid = element_blank())
      
      g <- g + theme_bare + 
        theme(axis.text = element_text(face = "bold", size = rel(1))) +
        scale_x_date(labels=date_format ("%b %y"), breaks=("2 months")) +
        theme(axis.text.x=element_text(angle = 90, hjust = 0))
      
      g <- g + labs(title = "Stock Price Trend", 
                    caption = "Source: Yahoo Finance")
      print(g) 
    })
    
    # ----------------------------------
})