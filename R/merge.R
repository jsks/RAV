#!/usr/bin/env Rscript

library(dbplyr)
library(dplyr)
library(lubridate)

db <- DBI::dbConnect(RSQLite::SQLite(), "data/db")
df <- tbl(db, "aggregated") %>%
    collect(n = Inf) %>%
    mutate(datestr = as.Date(datestr),
           month = month(datestr, T),
           weekday = weekdays(datestr),
           strata = ifelse(weekday %in% c("Friday", "Saturday", "Sunday"),
                           weekday,
                           "Mon-Thurs") %>% as.factor)

weather <- readRDS("data/weather.rds") %>%
    select(-referenceTime)

full.df <- full_join(df, weather, c("datestr" = "date"))
saveRDS(full.df, "data/dataset.rds")
