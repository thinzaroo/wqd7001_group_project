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
                   tabPanel("Stocks Comparison",
                   ),
                   
                   # tab panel 5 - Analysis by sector
                   tabPanel("Analysis by sector"
                   ),
                   # ----------------------------------
                   
                   # tab panel 6 - About Us
                   tabPanel("About Us",
                            includeHTML("about.html")
                   )
                   # ----------------------------------
                   
))