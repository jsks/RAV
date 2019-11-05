#!/usr/bin/env Rscript

library(dplyr)
library(rstan)

rstan_options(auto_write = T)
options(mc.cores = parallel::detectCores())

df <- readRDS("data/dataset.rds") %>%
    filter(count > 500)

X <- select(df, precipitation, temp, wind) %>% data.matrix
data <- list(N = nrow(df),
             K = ncol(X),
             X = scale(X),
             n_years = n_distinct(df$year),
             n_months = n_distinct(df$month),
             n_weekdays = n_distinct(df$weekday),
             year_id = as.numeric(as.factor(df$year)),
             month_id = as.numeric(df$month),
             weekday_id = as.numeric(as.factor(df$weekday)),
             y = df$count)
str(data)

fit <- stan("stan/negbin.stan", data = data, seed = 101010,
            control = list(adapt_delta = 0.999, max_treedepth = 15))

saveRDS(fit, "posterior/fit.rds")

# Save posterior repetitions
as.matrix(fit, pars = "y_rep") %>%
    round(5) %>%
    saveRDS("posterior/y_rep.rds")

# Save regression coefficients
alpha <- as.matrix(fit, pars = "alpha") %>% round(5)
beta <- as.matrix(fit, pars = "beta") %>% round(5)

colnames(alpha) <- "intercept"
colnames(beta) <- colnames(X)

for (i in 1:ncol(beta)) {
    alpha <- alpha - (beta[, i] * mean(X[, i]) / sd(X[, i]))
    beta[, i] <- beta[, i] / sd(X[, i])
}

cbind(alpha, beta) %>%
    saveRDS("posterior/coef.rds")
