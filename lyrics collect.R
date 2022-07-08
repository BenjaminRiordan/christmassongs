## Pull Wikipedia table - list of Christmas songs

# Packages
library (rvest)
library (tidyverse)

# Scrape christmas list

url <- "https://en.wikipedia.org/wiki/List_of_popular_Christmas_singles_in_the_United_States"

christmas_US <- url %>% read_html() %>% 
  html_table(header = TRUE, fill = TRUE)  %>% 
  .[[3]]
