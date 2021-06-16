#-----------
#WQD 7001 Group Project
#-----------
library(TTR)
library(dplyr)
library(readr)

setwd("/Users/n2n/RWorkingDirectory/wqd7001_group_project/")
df <- read.csv(file = "FBM_KLCI_stocks_list.csv", stringsAsFactors = FALSE)

symbol_codes <- df$Symbol
stock_codes <- df$StkCode

#download historical prices
for (stk_code in stock_codes){
  fromDate <- '1577836800'  #January 1, 2020 12:00:00 AM
  toDate <- '1620863999'    #May 12, 2021 11:59:59 PM
  
  url <- paste("https://query1.finance.yahoo.com/v7/finance/download/", stk_code, 
               ".KL?period1=", fromDate,"&period2=", toDate, 
               "&interval=1d&events=history&includeAdjustedClose=true",sep='');
  filename <- paste(stk_code, ".csv", sep='')
  download.file(url, filename)
}

#add stock code and symbol and roc to each file
for(i in 1:length(stock_codes)){
  original_filename <- paste(stock_codes[i], ".csv", sep='')
  stock_df <- read.csv(file = original_filename)
  df_len <- nrow(stock_df)
  stock_codes_df <- data.frame(StockCode=rep(stock_codes[i], df_len))
  
  #add symbol and stock code to each file
  symbol_df <- data.frame(Symbol=rep(symbol_codes[i], df_len))
  stock_df <- cbind(stock_df, stock_codes_df, symbol_df)
  
  #calculate new features
  stock_df$roc <- ROC(stock_df['Close'], n=1)  * 100
  stock_df$trend <- stock_df$Close / stock_df[1,"Close"]
  
  #save to file
  filename <- paste(stock_codes[i], "_", symbol_codes[i], ".csv", sep='')
  write.csv(stock_df, file = filename)
}

#merge all stocks into one data frame
data_all <- list.files(path = "processed_files/",
                       pattern = "*.csv", full.names = TRUE) %>%
  lapply(read_csv) %>%
  bind_rows

write.csv(data_all, file = "FBM_KLCI_historical_price_all_stocks.csv")