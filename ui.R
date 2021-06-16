library(shiny)
library(dplyr)
library(ggplot2)
library(lubridate)
library(scales)
library(treemap)

shinyUI(navbarPage(title = "Starry Nine",
                   theme = "style/style.css",
                   fluid = TRUE, 
                   collapsible = TRUE,
                  
                   # ----------------------------------
                   # tab panel 1 - Home
                   tabPanel("Home",
                            includeHTML("home.html")
                   ),
                   
                   # ----------------------------------
                   # tab panel 2 - Market Overview
                   tabPanel("Market Overview",
                            titlePanel("FBM KLCI Market Index Overview"),
                            
                            fluidRow(
                              column(1),
                              column(10,
                                     helpText(align="center", "This section provides an overview of the FBMKLCI Market Index datasets in different charts."), 
                                     helpText(align="center", "Select the chart type you wished to explore."), 
                                     br(),
                                     tabsetPanel( 
                                       type = "pills", 
                                       tabPanel("Table", br(), 
                                                tags$div(
                                                  class = "alert alert-info",
                                                  tags$ul(
                                                    tags$li("The table below shows details of the 30 FBMKLCI stocks."),
                                                    tags$li("The table is responsive table, feel free to filter or sort the stocks as you wished."),
                                                  )
                                                ),
                                                helpText(align="center", "Table of 30 FBMKLCI stocks details"),
                                                dataTableOutput('table'),
                                       ),
                                       tabPanel("Treemap",br(),
                                                tags$div(
                                                  class = "alert alert-info",
                                                  tags$ul(
                                                    tags$li("The treemap below shows 30 FBMKLCI stocks based on Market Cap."),
                                                    tags$li("The comany with smallest market capital is SUPERMAX CORPORATION BERHAD (12.977 billion)."),
                                                    tags$li("The company with largest market capital is MALAYAN BANKING BERHAD (93.709 billion)."),
                                                  )
                                                ),
                                                helpText(align="center", "Treemap of 30 FBMKLCI stocks based on Market Cap (in billion)"),
                                                column(2),
                                                column(6,plotOutput("tree",width = "100%")),
                                                column(2)
                                                
                                       ),
                                       tabPanel("Line Chart", br(),
                                                tags$div(
                                                  class = "alert alert-info",
                                                  tags$ul(
                                                    tags$li("The line chart plots FBM KLCI Market Performance from 2020-03-19 to 2021-06-11."),
                                                    tags$li("Please select the date range you wished to view."),
                                                    tags$li("Please notice that the minimum date is 2020-03-19 and maximum date is 2021-06-11."),
                                                  ),
                                                ),
                                                column(3,
                                                       dateRangeInput("daterange", "Date range:",
                                                                      start  = "2020-03-19",
                                                                      end    = "2021-06-11",
                                                                      min    = "2020-03-19",
                                                                      max    = "2021-06-11"), 
                                                ),
                                                column(9, 
                                                    fluidRow(align="center",textOutput("chart_title")),
                                                    plotOutput("line",width = "100%"))
                                                
                                        )
                                     )
                                     ),
                              column(1)
                            ),
                            
                            
                   ),
                   
                   # ----------------------------------
                   # tab panel 3 - Stock Explorer
                   tabPanel("Stock Explorer"
                   ),
                   # ----------------------------------
                   
                   # ----------------------------------
                   # tab panel 4 - Stocks Comparison
                   tabPanel("Stocks Comparison"
                   ),
                   
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
                                       tags$ul(
                                         tags$li("xxxx"),
                                         tags$li("xxxx"),
                                       )
                                     )
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
                                                         "Last Done Price" = "2",
                                                         "ROC (Rate of Change)" = "3"))
                              ),
                              mainPanel(
                                helpText("Stock Price Analysis by sector"),
                                br(),
                                htmlOutput("user_selection_analysis"),
                                br(),
                                plotOutput("plot_price_analysis_by_sector")
                              )
                            )
                   ),
                   # ----------------------------------
                   
                   # tab panel 6 - About Us
                   tabPanel("About Us",
                            includeHTML("about.html")
                   )
                   # ----------------------------------
))