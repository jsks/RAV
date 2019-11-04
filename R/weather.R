#!/usr/bin/env RScript

library(dplyr)
library(jsonlite)
library(tidyr)

client_id <- Sys.getenv("client_id")
if (nchar(client_id) == 0)
    stop("Missing client_id", call. = F)

api <- sprintf("https://%s@frost.met.no/observations/v0.jsonld", client_id)

station <- "SN18700"
time_interval <- "2016-04-01/2019-11-03"
elements <- c("mean(air_temperature P1D)",
              "mean(cloud_area_fraction P1D)",
              "mean(max(wind_speed PT1H) P1D)",
              "sum(precipitation_amount P1D)")

url <- sprintf("%s?sources=%s&referencetime=%s&elements=%s",
               api, station, time_interval, paste0(elements, collapse = ","))

# Let's be cavelier with potential errors here
json <- fromJSON(URLencode(url), flatten = T)

df <- unnest(json$data) %>%
    filter(!(grepl("precipitation", elementId) & timeOffset == "PT18H"),
           !(grepl("air", elementId) & timeOffset == "PT0H")) %>%
    select(referenceTime, elementId, value) %>%
    mutate(date = as.Date(referenceTime),
           elementId =
               case_when(grepl("air_temperature", elementId) ~ "temp",
                         grepl("cloud_area", elementId) ~ "cloud",
                         grepl("wind_speed", elementId) ~ "wind",
                         grepl("precipitation", elementId) ~ "precipitation")) %>%
    spread(elementId, value)

saveRDS(df, "data/weather.rds")
