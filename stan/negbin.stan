functions {
  /*
   * Taken from Gelman's example to deal with overflow during warmup
   * phase.
   *
   * "Alternative to neg_binomial_2_log_rng() that avoids potential
   * numerical problems during warmup"
   */
  int neg_binomial_2_log_safe_rng(real eta, real phi) {
    real gamma_rate = gamma_rng(phi, phi / exp(eta));
    if (gamma_rate >= exp(20.79))
      return -9;

    return poisson_rng(gamma_rate);
  }
}

data {
  int N;
  int K;
  matrix[N, K] X;

  int n_years;
  int n_months;
  int n_weekdays;

  int<lower=1, upper=n_years> year_id[N];
  int<lower=1, upper=n_months> month_id[N];
  int<lower=1, upper=n_weekdays> weekday_id[N];

  int y[N];
}

parameters {
  real alpha;
  vector[K] beta;

  real<lower=0, upper=pi()/2> sigma_unif[3];
  vector[n_years] raw_year;
  vector[n_months] raw_month;
  vector[n_weekdays] raw_weekday;

  real<lower=0> phi;
}

transformed parameters {
  vector[N] eta;
  real<lower=0> sigma[3];
  vector[n_years] Z_year;
  vector[n_months] Z_month;
  vector[n_weekdays] Z_weekday;

  // sigma ~ HalfCauchy(0, 1)
  sigma = tan(sigma_unif);

  Z_year = raw_year * sigma[1];
  Z_month = raw_month * sigma[2];
  Z_weekday = raw_weekday * sigma[3];

  eta = X * beta +
    alpha +
    Z_year[year_id] +
    Z_month[month_id] +
    Z_weekday[weekday_id];
}

model {
  alpha ~ normal(0, 10);
  beta ~ normal(0, 5);

  raw_year ~ std_normal();
  raw_month ~ std_normal();
  raw_weekday ~ std_normal();

  phi ~ cauchy(0, 2.5);

  y ~ neg_binomial_2_log(eta, phi);
}

generated quantities {
  vector[N] y_rep;

  for (i in 1:N)
    y_rep[i] = neg_binomial_2_log_safe_rng(eta[i], phi);
}
