library(shiny)

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
                   tabPanel("Market Overview"
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
                            sidebarLayout(
                              sidebarPanel(
                                selectInput("sector_id", "Sector",
                                            choices = c("Banking" = "1",
                                                        "Food & Beverages" = "2",
                                                        "Healthcare Equipment & Services" = "3",
                                                        "Plantation" = "4",
                                                        "Telecommunications Service Providers" = "5")),
                                radioButtons("interval_id", "Select interval",
                                             choices = c("All time" = "1",
                                                         "First Wave" = "2",
                                                         "Second Wave" = "3",
                                                         "Third Wave" = "4"))
                              ),
                              mainPanel(
                                helpText("Select the sector you wished to explore."),
                                htmlOutput("user_selection_analysis"),
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