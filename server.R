#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#

library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)
library(treemap)
library(data.table)

# Define server logic
shinyServer(function(input, output,session) {
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
    
    output$chart_title <- renderText({ 
      paste("FBM KLCI Market Performance from ", as.character(input$daterange[1]), " to ", as.character(input$daterange[2]))
    })
    
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
	
	#--------------------------------
	    #Update the stocks list (assumed all but d and year are variables of interest)
    updateSelectInput(session, "stockSelection", 
                      choices = sort(unique(all_stocks_df$Symbol)))
    
    
    #Load the chart function
    draw_chart <- function(all_stocks_df, listv){
        
        df2 <- all_stocks_df %>%
            filter(Symbol %in% listv)
        
        df3 <- subset(df2,df2$Date >= input$daterange_c[1] & df2$Date <= input$daterange_c[2])
            
        
        # Visualization
        p <- ggplot(df3, aes(x = Date, y = Close)) + 
             geom_line(aes(color = Symbol, linetype = Symbol)) + 
             scale_color_discrete() 
			
		theme_bare <- theme(panel.background = element_blank(), 
                          panel.grid = element_blank())
						 
		p <- p + theme_bare + 
        theme(axis.text = element_text(face = "bold", size = rel(1))) +
        scale_x_date(labels=date_format ("%b %y"), breaks=("2 months")) +
        theme(axis.text.x=element_text(angle = 90, hjust = 0))
      
		p <- p + labs(title = "Stock Comparison", 
                    caption = "Source: Yahoo Finance")
        print(p) 			
    }  
    output$plot_comparison = renderPlot({
        
        
        #Only render if there are 2 or 3 stocks selected
        req(between(length(input$stockSelection), 2, 3))
        draw_chart(all_stocks_df, input$stockSelection)
    })
	
    
    # ----------------------------------
    #panel 5
    sector_list <- c("Banking" = "1",
                     "Food & Beverages" = "2",
                     "Healthcare Equipment & Services" = "3",
                     "Plantation" = "4",
                     "Telecommunications Service Providers" = "5")
    
    price_scale_list <- c("Trendline" = "1",
                          "Daily Close Price" = "2",
                          "ROC (Rate of Change)" = "3")
    
    output$user_selection_analysis <- renderUI({
      sector_str <- paste(HTML("<b>Sector: </b>"), names(sector_list)[sector_list == input$sector_id])
      stock_list <- get_stocks_by_sector(input$sector_id)
      stock_list_str <- paste(HTML("<b>List of stocks: </b>"), toString(stock_list))
      interval_str <- paste(HTML("<b>Price Scale: </b>"),  names(price_scale_list)[price_scale_list == input$price_scale_id])
      
      #initialise empty strings
      ref_line_str <- ""
      ref_line_legend_str <- ""
      mco1_legend <- ""
      mco2_legend <- ""
      mco3_legend <- ""
      vaccine_legend <- ""
      
      if(input$chk_mco_1 | input$chk_mco_2 | input$chk_mco_3 | input$chk_vaccine){
        ref_line_str <- HTML("<b>Reference Line(s): </b>")
      }
      
      if(input$chk_mco_1)
        mco1_legend <- HTML("<font color=\'red\'>-----</font> MCO 1.0<br/>")
      
      if(input$chk_mco_2)
        mco2_legend <- HTML("<font color=\'orange\'>-----</font> MCO 2.0<br/>")
      
      if(input$chk_mco_3)
        mco3_legend <- HTML("<font color=\'orange\'>-----</font> MCO 3.0<br/>")
      
      if(input$chk_vaccine)
        vaccine_legend <- HTML("<font color=\'green\'>-----</font> First Vaccine Announcement by Pfizer-BioNTech")
      
      ref_line_legend_str <- paste(mco1_legend, mco2_legend, mco3_legend, vaccine_legend, "<br/>")
      HTML(paste(sector_str, stock_list_str, interval_str, ref_line_str, ref_line_legend_str, sep = '<br/>'))
    })
    
    output$plot_price_analysis_by_sector <- renderPlot({
      stock_list <- get_stocks_by_sector(input$sector_id)
      sector_df <- all_stocks_df %>% filter(Symbol %in% stock_list)
      
      str_title <- "Stock Price Trend"
      
      if(input$price_scale_id == 1){
        
        str_title <- "Summary of sector by price trend"
        g <- ggplot(data = sector_df, aes(x=Date, y=trend, color=Symbol)) + geom_line()
        
      }else if(input$price_scale_id == 2){
        
        str_title <- "Summary of sector by Daily close price"
        g <- ggplot(data = sector_df, aes(x=Date, y=Close, color=Symbol)) + geom_line()
        
      }else{
        
        str_title <- "Summary of sector by ROC (Rate of Change)"
        g <- ggplot(data = sector_df, aes(x=Date, y=roc, color=Symbol)) + geom_line()
      }
      
      #add reference line
      if(input$chk_mco_1)
        g <- g + geom_vline(xintercept = as.Date("2020-03-18"), linetype="dashed", color="red")
      
      if(input$chk_mco_2)
        g <- g + geom_vline(xintercept = as.Date("2021-01-13"), linetype="dashed", color="orange")
      
      if(input$chk_mco_3)
        g <- g + geom_vline(xintercept = as.Date("2021-05-03"), linetype="dashed", color="gold")
      
      if(input$chk_vaccine)
        g <- g + geom_vline(xintercept = as.Date("2020-11-9"), linetype="dashed", color="springgreen4")
      
      #remove grid and background
      theme_bare <- theme(panel.background = element_blank(), 
                          panel.grid = element_blank())
      
      #update axis to break 2 months each, and change text angle
      g <- g + theme_bare + 
        theme(axis.text = element_text(face = "bold", size = rel(1))) +
        scale_x_date(labels=date_format ("%b %y"), breaks=("2 months")) +
        theme(axis.text.x=element_text(angle = 90, hjust = 0))
      
      #add title at the top and caption at bottom right
      g <- g + labs(title = str_title, 
                    caption = "Source: Yahoo Finance")
      
      print(g) 
    })
    
    output$summary_by_volume <- renderDataTable({
      stock_list <- get_stocks_by_sector(input$sector_id)
      sector_df <- all_stocks_df %>% filter(Volume > 0 & Symbol %in% stock_list)
      
      setDT(sector_df)
      volumeSummary <- sector_df[, as.list(summary(Volume)), by = Symbol]
      volumeSummary$Movement <- volumeSummary$Max. / volumeSummary$Mean
      print(volumeSummary[order(Movement)])
    }, options = list(sDom  = '<"top"><"bottom">'))
    
    # ----------------------------------
})