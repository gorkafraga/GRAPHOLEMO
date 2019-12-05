// Author: Patrick Haller
// https://github.com/pathalle/RLDDM_stan
// November 2019

data {
  int<lower=1> N;      // Number of subjects
  real minRT[N];       // minimum RT for each subject of the observed data
  int first[N];        // first trial of subject
  int last[N];         // last trial of subject
  int<lower=1> T;      // Number of observations
  real RTbound;        // lower bound of RT across all subjects (e.g., 0.1 second)
  real iter[T];        // trial of given observation
  int response[T];      // encodes successful trial [1: lower bound (incorrect), 2: upper bound(correct)]
  real RT[T];          // reaction time
  int value[T];        // value of trial: successful / unsuccessful -> encodes rewards
  int stim_assoc[T];   // index of associated sound-symbol pair
  int stim_nassoc[T];  // index of presented non-associated symbol
  int n_stims[N];      // number of items learned by each subject (represents # blocks)
}

parameters {
  // alpha (a): Boundary separation or Speed-accuracy trade-off 
  // tau (ter): Nondecision time + Motor response time + encoding time
  // v_mod: modulator for drift diffusion rate
  // Hyper-parameters
  vector[3] mu_pr;
  vector<lower=0>[3] sigma;

  // Subject-level raw parameters
  vector[N] alpha_pr;
  vector[N] v_mod_pr;
  vector[N] tau_pr;
  
}

transformed parameters {
  // Transform subject-level raw parameters
  vector<lower=0>[N] alpha;                       // boundary separation
  vector<lower=0, upper=10>[N] v_mod;             // scaling parameter
  vector<lower=RTbound, upper=max(minRT)>[N] tau; // nondecision time

  alpha = exp(mu_pr[1] + sigma[1] * alpha_pr); //
  v_mod = exp(mu_pr[2] + sigma[2] * v_mod_pr);
  for (s in 1:N) {
    tau[s]  = Phi_approx(mu_pr[3] + sigma[3] * tau_pr[s]) * (minRT[s] - RTbound) + RTbound;
    tau[s] = fabs(tau[s]);
  }
}

model {
  real eta = 0.07;
  real ev[T,max(n_stims)];
  vector[T] delta;
  // Hyperparameters
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2);

  // Individual parameters
  alpha_pr ~ normal(0, 1);
  v_mod_pr ~ normal(0, 1);
  tau_pr   ~ normal(0, 1);
  // Begin subject loop
  // until second last 
  for (s in 1:N) {
    for(a in 1:n_stims[s]){
      // ev for pos values
      ev[first[s],a] = 0.5;
    }
    for(trial in (first[s]):(last[s]-1)) {
      for(a in 1:n_stims[s]){
        ev[trial+1,a] = ev[trial,a];
      }
      delta[trial] = (ev[trial,stim_assoc[trial]] + ev[trial,stim_nassoc[trial]])/2 * v_mod[s];
      // if lower bound
      if (response[trial]==1){
        RT[trial] ~  wiener(alpha[s], tau[s] ,0.5,-(delta[trial]));
        ev[trial+1,stim_nassoc[trial]] = ev[trial,stim_nassoc[trial]] + (eta * fabs(value[trial]-(1-ev[trial,stim_nassoc[trial]])));
        ev[trial+1,stim_assoc[trial]] = ev[trial,stim_assoc[trial]] + (eta * fabs(value[trial]-ev[trial,stim_assoc[trial]]));
      }
      // if upper bound (resp = 2)
      else{
        RT[trial] ~  wiener(alpha[s],tau[s] ,0.5,delta[trial]);
        ev[trial+1,stim_nassoc[trial ]] = ev[trial,stim_nassoc[trial]] + (eta * (value[trial]-(1-ev[trial,stim_nassoc[trial]])));
        ev[trial+1,stim_assoc[trial]] = ev[trial,stim_assoc[trial]] + (eta * (value[trial]-ev[trial,stim_assoc[trial]]));
      }
    }
    // in last cycle, don't update anymore
    delta[last[s]] = (ev[last[s]-1,stim_assoc[last[s]]] - ev[last[s]-1,stim_nassoc[last[s]]])/2 * v_mod[s];
    if (response[last[s]]==1){
      RT[last[s]] ~  wiener(alpha[s],tau[s] ,0.5,-(delta[last[s]]));
    }
    if (response[last[s]]==2){
      RT[last[s]] ~  wiener(alpha[s], tau[s] ,0.5,delta[last[s]]);
    }
  }
}
generated quantities {
  // For group level parameters
  real<lower=0> mu_alpha;                  // boundary separation
  real<lower=0> mu_v_mod;                  // drift rate modification
  real<lower=RTbound, upper=max(minRT)> mu_tau; // nondecision time
  
  real ev_hat[T,max(n_stims)];
  real pe_hat[T];
  real assoc_active_pair[T];
  real assoc_inactive_pair[T];
  vector[T] delta_hat;
  
  vector[T] log_lik;
  
  real eta_gen = 0.07;
  
  // Assign group level parameter values
  mu_alpha = exp(mu_pr[1]);
  mu_v_mod =  exp(mu_pr[2]);
  mu_tau = Phi_approx(mu_pr[3]) * (mean(minRT)-RTbound) + RTbound;
  
  for (s in 1:N){
    for(a in 1:n_stims[s]){
      // ev for pos values
      ev_hat[first[s],a] = 0.5;
    }
    assoc_active_pair[first[s]] = 0.5;
    assoc_inactive_pair[first[s]] = 0.5;
    for(trial in (first[s]):(last[s]-1)) {
      for(a in 1:n_stims[s]){
        ev_hat[trial+1,a] = ev_hat[trial,a];
      }
      delta_hat[trial] = (ev_hat[trial,stim_assoc[trial]] + ev_hat[trial,stim_nassoc[trial]])/2 * v_mod[s];
      assoc_active_pair[trial] = ev_hat[trial,stim_assoc[trial]];
      assoc_inactive_pair[trial] = ev_hat[trial,stim_nassoc[trial]];
      pe_hat[trial] = value[trial]-(ev_hat[trial,stim_assoc[trial]]);
      // if lower bound
      if (response[trial]==1){
        ev_hat[trial+1,stim_nassoc[trial]] = ev_hat[trial,stim_nassoc[trial]] + (eta_gen * fabs(value[trial]-(1-ev_hat[trial,stim_nassoc[trial]])));
        ev_hat[trial+1,stim_assoc[trial]] = ev_hat[trial,stim_assoc[trial]] + (eta_gen * fabs(value[trial]-ev_hat[trial,stim_assoc[trial]]));
        log_lik[trial] = wiener_lpdf(RT[trial] | alpha[s] ,tau[s],0.5,-(delta_hat[trial]));
      }
      // if upper bound (resp = 2)
      else{
        ev_hat[trial+1,stim_nassoc[trial]] = ev_hat[trial,stim_nassoc[trial]] + (eta_gen * (value[trial]-(1-ev_hat[trial,stim_nassoc[trial]])));
        ev_hat[trial+1,stim_assoc[trial]] = ev_hat[trial,stim_assoc[trial]] + (eta_gen * (value[trial]-ev_hat[trial,stim_assoc[trial]]));
        log_lik[trial] = wiener_lpdf(RT[trial] | alpha[s] ,tau[s],0.5,delta_hat[trial]);
      }
    }
    pe_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_nassoc[last[s]]]);
    assoc_active_pair[last[s]] = ev_hat[last[s],stim_assoc[last[s]]];
    assoc_inactive_pair[last[s]] = ev_hat[last[s],stim_nassoc[last[s]]];
    delta_hat[last[s]] = (ev_hat[last[s]-1,stim_assoc[last[s]]] + ev_hat[last[s]-1,stim_nassoc[last[s]]])/2 * v_mod[s];
    if (response[last[s]]==1){
      log_lik[last[s]] = wiener_lpdf(RT[last[s]] | alpha[s] ,tau[s],0.5,-(delta_hat[last[s]]));
    }
    if (response[last[s]]==2){
      log_lik[last[s]] = wiener_lpdf(RT[last[s]] | alpha[s] ,tau[s],0.5,delta_hat[last[s]]);
    }
  }
}

