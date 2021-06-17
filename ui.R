library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)
library(treemap)
library(data.table)
library(plotly)

stock_list_df <- read.csv('data/FBM_KLCI_stocks_list.csv')

shinyUI(
  navbarPage(
    title = "Starry Nine",
    theme = "style/style.css",
    fluid = TRUE,
    collapsible = TRUE,
    
    # ----------------------------------
    # tab panel 1 - Home
    tabPanel("Home",
             includeHTML("home.html")),
    
    # ----------------------------------
    # tab panel 2 - Market Overview
    tabPanel(
      "Market Overview",
      titlePanel("FBM KLCI Market Index Overview"),
      
      fluidRow(
        column(1),
        column(
          10,
          helpText(
            align = "center",
            "This section provides an overview of the FBMKLCI Market Index datasets in different charts."
          ),
          helpText(align = "center", "Select the chart type you wished to explore."),
          br(),
          tabsetPanel(
            type = "pills",
            tabPanel(
              "Table",
              br(),
              tags$div(class = "alert alert-info",
                       tags$ul(
                         tags$li("The table below shows details of the 30 FBMKLCI stocks."),
                         tags$li(
                           "The table is responsive table, feel free to filter or sort the stocks as you wished."
                         ),
                       )),
              helpText(align = "center", "Table of 30 FBMKLCI stocks details"),
              dataTableOutput('table'),
            ),
            tabPanel(
              "Treemap",
              br(),
              tags$div(class = "alert alert-info",
                       tags$ul(
                         tags$li("The treemap below shows 30 FBMKLCI stocks based on Market Cap."),
                         tags$li(
                           "The comany with smallest market capital is SUPERMAX CORPORATION BERHAD (12.977 billion)."
                         ),
                         tags$li(
                           "The company with largest market capital is MALAYAN BANKING BERHAD (93.709 billion)."
                         ),
                       )),
              helpText(
                align = "center",
                "Treemap of 30 FBMKLCI stocks based on Market Cap (in billion)"
              ),
              column(2),
              column(6, plotOutput("tree", width = "100%")),
              column(2)
              
            ),
            tabPanel(
              "Line Chart",
              br(),
              tags$div(class = "alert alert-info",
                       tags$ul(
                         tags$li(
                           "The line chart plots FBM KLCI Market Performance from 2020-03-19 to 2021-06-11."
                         ),
                         tags$li("Please select the date range you wished to view."),
                         tags$li(
                           "Please notice that the minimum date is 2020-03-19 and maximum date is 2021-06-11."
                         ),
                       ),),
              column(
                3,
                dateRangeInput(
                  "daterange",
                  "Date range:",
                  start  = "2020-03-19",
                  end    = "2021-06-11",
                  min    = "2020-03-19",
                  max    = "2021-06-11"
                ),
              ),
              column(
                9,
                fluidRow(align = "center", textOutput("chart_title")),
                plotOutput("line", width = "100%")
              )
              
            )
          )
        ),
        column(1)
      ),
    ),
    
    # ----------------------------------
    # tab panel 3 - Stock Explorer
    tabPanel("Stock Explorer",
             titlePanel("Stock Explorer"),
             fluidRow(
               column(2),
               column(8,
                      helpText(
                        align = "center",
                        "This section allows you to study details of each stock's performance."
                      ),
                      tags$div(
                        class = "alert alert-info",
                        helpText(HTML("<b>User Guide</b>")),
                        tags$ul(
                          tags$li("Select a stock"),
                          tags$li("You can choose the desired interval")
                        )
                      ),
                      selectInput(inputId = "Stock_select",label = "Stock",stock_list_df$Symbol),
                      plotlyOutput("plotCandleStick")
               ),
               column(2))
    ),
    # ----------------------------------
    
    
    # tab panel 4 - Stocks Comparison
    tabPanel(
      "Stocks Comparison",
      titlePanel("Stock Comparison by Chart"),
      fluidRow(
        column(1),
        column(
          10,
          helpText(
            align = "center",
            "This section illustrates a comparison among the FBMKLCI Stocks datasets in one charts."
          ),
          helpText(
            align = "center",
            "Select the stocks you wished to compare, you may choose up to 3 stocks at once."
          ),
          br(),
          
          
          tabPanel(
            "Line Chart",
            br(),
            tags$div(class = "alert alert-info",
                     tags$ul(
                       tags$li("Please select the date range you wished to view."),
                       tags$li(
                         "Please notice that the minimum date is 2020-03-19 and maximum date is 2021-06-11."
                       ),
                     ),),
            column(
              6,
              selectInput(
                "stockSelection",
                "Choose 2 or 3 stocks for comparison",
                multiple = T,
                choices = ""
              ),
              dateRangeInput(
                "daterange_c",
                "Date range:",
                start  = "2020-03-19",
                end    = "2021-06-11",
                min    = "2020-03-19",
                max    = "2021-06-11"
              ),
            ),
            column(10,
                   plotOutput("plot_comparison", width = "100%"))
            
            
          )
        ),
        column(1)
      ),
      
    ),
    # ----------------------------------
    # tab panel 5 - Analysis by sector
    tabPanel("Analysis",
             titlePanel("Market Analysis by Sector"),
             
             fluidRow(
               column(2),
               column(8,
                      helpText(align="center", "This section let you analyse stock market performance by sector."), 
                      helpText(align="center", "Adjust the sector and other parameters from the left control"),
                      tags$div(
                        class = "alert alert-info",
                        helpText(HTML("<b>User Guide</b>")),
                        tags$ul(
                          tags$li(HTML("<b>Sector: </b>Choose a desired sector you wish to explore")),
                          tags$li(HTML("<b>Price Scale: </b>Select desire price scale for comparisons between stocks")),
                          tags$li(HTML("<b>Reference Line: </b>Add reference lines to further inspect the impact")),
                          tags$li(HTML("<i>MCO: Movement Control Order imposed by Malaysian government</i>"))
                        )
                      ),
               ),
               column(2)),
             
             sidebarLayout(
               sidebarPanel(
                 selectInput("sector_id", "Sector",
                             choices = c("Banking" = "1",
                                         "Food & Beverages" = "2",
                                         "Healthcare Equipment & Services" = "3",
                                         "Plantation" = "4",
                                         "Telecommunications Service Providers" = "5")),
                 radioButtons("price_scale_id", "Select price scale",
                              choices = c("Trendline" = "1",
                                          "Daily close price" = "2",
                                          "ROC (Rate of Change)" = "3")),
                 br(),
                 helpText(HTML("<b>Choose reference line</b>")),
                 checkboxInput("chk_mco_1", "start of MCO 1.0", value=FALSE),
                 checkboxInput("chk_mco_2", "start of MCO 2.0", value=FALSE),
                 checkboxInput("chk_mco_3", "start of MCO 3.0", value=FALSE),
                 checkboxInput("chk_vaccine", "First vaccine announcement by Pfizer", value=FALSE),
               ),
               
               mainPanel(
                 helpText(HTML("<h4>Selected criteria:</h4>")),
                 htmlOutput("user_selection_analysis"),
                 helpText(HTML("<h4>Analysis by daily close price</h4>")),
                 plotOutput("plot_price_analysis_by_sector"),
                 br(),
                 helpText(HTML("<h4>Summary of daily traded volume</h4>")),
                 helpText("Note: Movement indicates how many times the stock is traded above the mean"),
                 dataTableOutput('summary_by_volume')
               )
             )
    ),
    # ----------------------------------
    
    # ----------------------------------   
    # tab panel 6 - About Us
    tabPanel("About Us",
             includeHTML("about.html"))
    # ----------------------------------
  )
)