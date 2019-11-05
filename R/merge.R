#!/usr/bin/env Rscript

library(dbplyr)
library(dplyr)
library(lubridate)

db <- DBI::dbConnect(RSQLite::SQLite(), "data/db")
df <- tbl(db, "aggregated") %>%
    collect(n = Inf) %>%
    mutate(datestr = as.Date(datestr),
           year = year(datestr),
           month = month(datestr, T) %>% droplevels,
           weekday = weekdays(datestr) %>%
               factor(ordered = T,
                      levels = c("Monday", "Tuesday", "Wednesday", "Thursday",
                                 "Friday", "Saturday", "Sunday")))

weather <- readRDS("data/weather.rds") %>%
    select(-referenceTime)

full.df <- full_join(df, weather, c("datestr" = "date"))
saveRDS(full.df, "data/dataset.rds")
