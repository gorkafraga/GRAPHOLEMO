data {
  int<lower=1> N;      // Number of subjects
  real minRT[N];       // minimum RT for each subject of the observed data
  int first[N];        // first trial of subject
  int last[N];         // last trial of subject
  int<lower=1> T;      // Number of observations
  real RTbound;        // lower bound of RT across all subjects (e.g., 0.1 second)
  real iter[T];        // trial of given observation
  int trials[T];       // max trials per subject per block
  int response[T];      // encodes successful trial [1: lower bound (incorrect), 2: upper bound(correct)]
  real RT[T];          // reaction time
  int value[T];        // value of trial: successful / unsuccessful -> encodes rewards
  int stim_assoc[T];   // index of associated sound-symbol pair
  int stim_nassoc[T];  // index of presented non-associated symbol
  int n_stims[N];      // number of items learned by each subject (represents # blocks)
}

parameters {
  // Hyper-parameters
  vector[4] mu_pr;
  vector[2] mu_eta_pr;
  vector<lower=0>[4] sigma;
  vector<lower=0>[2] sigma_eta;

  // Subject-level raw parameters
  vector[N] a_pr;
  vector[N] eta_pos_pr;
  vector[N] eta_neg_pr;
  vector[N] a_mod_pr;
  vector[N] v_mod_pr;
  vector[N] tau_pr;
}

transformed parameters {
  // Transform subject-level raw parameters
  vector<lower=0>[N] a; //(a): Boundary separation or Speed-accuracy trade-off 
  vector<lower=0, upper=1>[N] eta_pos; // learning parameter
  vector<lower=0, upper=1>[N] eta_neg; // learning parameter
  vector[N] a_mod;           // choice consistency or modulator for decision boundary
  vector<lower=0>[N] v_mod;             // scaling parameter
  vector<lower=RTbound, upper=max(minRT)>[N] tau; // tau (ter): Nondecision time + Motor response time + encoding time

  a = exp(mu_pr[1] + sigma[1] * a_pr); //
  eta_pos = 0.1*Phi_approx(mu_eta_pr[1] + sigma_eta[1] * eta_pos_pr);
  eta_neg = 0.1*Phi_approx(mu_eta_pr[2] + sigma_eta[2] * eta_neg_pr);
  a_mod = exp(mu_pr[2] + sigma[2] * a_mod_pr);
  v_mod = exp(mu_pr[3] + sigma[3] * v_mod_pr);
  for (s in 1:N) {
    tau[s]  = Phi_approx(mu_pr[4] + sigma[4] * tau_pr[s]) * (minRT[s] - RTbound) + RTbound;
    tau[s] = fabs(tau[s]);
  }
}

model {
  real z=0.5; // starting point							
  real ev[T,max(n_stims)];
  vector[T] v;
  // Hyperparameters
  mu_pr  ~ normal(0, 1);
  mu_eta_pr ~ normal(0, 0.3);
  sigma_eta ~ normal(0, 0.5);
  sigma ~ normal(0, 0.2);

  // Individual parameters
  a_pr ~ normal(0, 1);
  eta_pos_pr ~ normal(0,2); 
  eta_neg_pr ~ normal(0,2); 
  a_mod_pr ~ normal(0, 1);
  v_mod_pr ~ normal(0, 1);
  tau_pr   ~ normal(0, 1);
  // Begin subject loop
  // until second last 
  for (s in 1:N) {
    for(p in 1:n_stims[s]){
      // ev for pos values
      ev[first[s],p] = 0.5;
    }
    for(trial in (first[s]):(last[s]-1)) {
      for(p in 1:n_stims[s]){
        ev[trial+1,p] = ev[trial,p];
      }
      // if lower bound
      if (response[trial]==1){
        v[trial] = -((ev[trial,stim_assoc[trial]] + ev[trial,stim_nassoc[trial]])/2 * v_mod[s]);
        RT[trial] ~  wiener(a[s] - ((iter[trial]/trials[trial])*a_mod[s]), tau[s], z,v[trial]);
        //ev[trial+1,stim_nassoc[trial]] = ev[trial,stim_nassoc[trial]] + (eta_neg[s] * fabs(value[trial]-(1-ev[trial,stim_nassoc[trial]])));
        //if (ev[trial+1,stim_nassoc[trial]]>1){
        //  ev[trial+1,stim_nassoc[trial]]=1;
        //}									  								   
        ev[trial+1,stim_assoc[trial]] = ev[trial,stim_assoc[trial]] + (eta_neg[s] * fabs(value[trial]-ev[trial,stim_assoc[trial]]));
        if (ev[trial+1,stim_assoc[trial]]>1){
          ev[trial+1,stim_assoc[trial]]=1;
        }									  
      }
      // if upper bound (resp = 2)
      else{
        v[trial] = (ev[trial,stim_assoc[trial]] + ev[trial,stim_nassoc[trial]])/2 * v_mod[s];
        RT[trial] ~  wiener(a[s] - ((iter[trial]/trials[trial])*a_mod[s]), tau[s], z, v[trial]);
        //ev[trial+1,stim_nassoc[trial]] = ev[trial,stim_nassoc[trial]] + (eta_pos[s] * (value[trial]-(1-ev[trial,stim_nassoc[trial]])));
        //if (ev[trial+1,stim_nassoc[trial]]>1){
        //  ev[trial+1,stim_nassoc[trial]]=1;
        //}										  
        ev[trial+1,stim_assoc[trial]] = ev[trial,stim_assoc[trial]] + (eta_pos[s] * (value[trial]-ev[trial,stim_assoc[trial]]));
        if (ev[trial+1,stim_assoc[trial]]>1){
          ev[trial+1,stim_assoc[trial]]=1;
        }											 			 
      }
    }
    // in last cycle, don't update anymore
    if (response[last[s]]==1){
      v[last[s]] = -((ev[last[s]-1,stim_assoc[last[s]]] - ev[last[s]-1,stim_nassoc[last[s]]])/2 * v_mod[s]);
      RT[last[s]] ~  wiener(a[s] - ((iter[last[s]]/trials[last[s]])*a_mod[s]),tau[s], z, v[last[s]]);
    }
    if (response[last[s]]==2){
      v[last[s]] = (ev[last[s]-1,stim_assoc[last[s]]] - ev[last[s]-1,stim_nassoc[last[s]]])/2 * v_mod[s];
      RT[last[s]] ~  wiener(a[s] - ((iter[last[s]]/trials[last[s]])*a_mod[s]),tau[s], z, v[last[s]]);
    }
  }
}
generated quantities {
  real z=0.5;  
  // For group level parameters
  real<lower=0> mu_a;                  // boundary separation
  real<lower=0> mu_eta_pos;                 // learning rate lower
  real<lower=0> mu_eta_neg;                 // learning rate lower
  real<lower=0> mu_a_mod;                  // boundary separation modification
  real<lower=0> mu_v_mod;                  // drift rate modification
  real<lower=RTbound, upper=max(minRT)> mu_tau; // nondecision time
  
  real ev_hat[T,max(n_stims)];
  real pe_tot_hat[T];
  real pe_pos_hat[T];
  real pe_neg_hat[T];
  real as_active[T];
  real as_inactive[T];
  real as_chosen[T];
  vector[T] v_hat;  // estimated drift rate
  vector[T] log_lik;

  // Assign group level parameter values
  mu_a = exp(mu_pr[1]);
  mu_a_mod =  exp(mu_pr[2]);
  mu_eta_pos = 0.1*Phi_approx(mu_eta_pr[1]);
  mu_eta_neg = 0.1*Phi_approx(mu_eta_pr[2]);
  mu_v_mod =  exp(mu_pr[3]);
  mu_tau = Phi_approx(mu_pr[4]) * (mean(minRT)-RTbound) + RTbound;
  
  for (s in 1:N){
    for(p in 1:n_stims[s]){
      // ev for pos values
      ev_hat[first[s],p] = 0.5;
    }
    for(trial in (first[s]):(last[s]-1)) {
      for(p in 1:n_stims[s]){
        ev_hat[trial+1,p] = ev_hat[trial,p];
      }
      as_active[trial] = ev_hat[trial,stim_assoc[trial]];
      as_inactive[trial] = ev_hat[trial,stim_nassoc[trial]];
      // if lower bound
      if (response[trial]==1){
        v_hat[trial] = -((ev_hat[trial,stim_assoc[trial]] + ev_hat[trial,stim_nassoc[trial]])/2 * v_mod[s]);
        as_chosen[trial] = ev_hat[trial,stim_nassoc[trial]];
        pe_tot_hat[trial] = value[trial]-(ev_hat[trial,stim_nassoc[trial]]);
        pe_neg_hat[trial] = value[trial]-(ev_hat[trial,stim_nassoc[trial]]);
        //pe_pos_hat[trial] = 0;
        //ev_hat[trial+1,stim_nassoc[trial]] = ev_hat[trial,stim_nassoc[trial]] + (eta_neg[s] * fabs(value[trial]-(1-ev_hat[trial,stim_assoc[trial]])));
        //if (ev_hat[trial+1,stim_nassoc[trial]]>1){
        //ev_hat[trial+1,stim_nassoc[trial]]=1;
        //}												  
        ev_hat[trial+1,stim_assoc[trial]] = ev_hat[trial,stim_assoc[trial]] + (eta_neg[s] * fabs(value[trial]-ev_hat[trial,stim_assoc[trial]]));
        if (ev_hat[trial+1,stim_assoc[trial]]>1){
          ev_hat[trial+1,stim_assoc[trial]]=1;
        } 
        log_lik[trial] = wiener_lpdf(RT[trial] | a[s] - ((iter[trial]/trials[trial])*a_mod[s]),tau[s],z,v_hat[trial]);
      }
      // if upper bound (resp = 2)
      else{
        v_hat[trial] = (ev_hat[trial,stim_assoc[trial]] + ev_hat[trial,stim_nassoc[trial]])/2 * v_mod[s];
        as_chosen[trial] = ev_hat[trial,stim_assoc[trial]];
        pe_tot_hat[trial] = value[trial]-(ev_hat[trial,stim_assoc[trial]]);
        pe_pos_hat[trial] = value[trial]-(ev_hat[trial,stim_assoc[trial]]);
        pe_neg_hat[trial] = 0;
        //ev_hat[trial+1,stim_nassoc[trial]] = ev_hat[trial,stim_nassoc[trial]] + (eta_pos[s] * (value[trial]-(1-ev_hat[trial,stim_assoc[trial]])));
        //if (ev_hat[trial+1,stim_nassoc[trial]]>1){
        //  ev_hat[trial+1,stim_nassoc[trial]]=1;
        //}
        ev_hat[trial+1,stim_assoc[trial]] = ev_hat[trial,stim_assoc[trial]] + (eta_pos[s] * (value[trial]-ev_hat[trial,stim_assoc[trial]]));
        if (ev_hat[trial+1,stim_assoc[trial]]>1){
          ev_hat[trial+1,stim_assoc[trial]]=1;
        }
        log_lik[trial] = wiener_lpdf(RT[trial] | a[s] - ((iter[trial]/trials[trial])*a_mod[s]),tau[s],z,v_hat[trial]);
      }
    }
    as_active[last[s]] = ev_hat[last[s],stim_assoc[last[s]]];
    as_inactive[last[s]] = ev_hat[last[s],stim_nassoc[last[s]]];
    if (response[last[s]]==1){
      v_hat[last[s]] = -((ev_hat[last[s]-1,stim_assoc[last[s]]] + ev_hat[last[s]-1,stim_nassoc[last[s]]])/2 * v_mod[s]);
      as_chosen[last[s]] = ev_hat[last[s],stim_nassoc[last[s]]];
      pe_tot_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_nassoc[last[s]]]);
      pe_neg_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_nassoc[last[s]]]);
      pe_pos_hat[last[s]] = 0;
      log_lik[last[s]] = wiener_lpdf(RT[last[s]] | a[s] - ((iter[last[s]]/trials[last[s]])*a_mod[s]),tau[s],z,v_hat[last[s]]);
    }
    else{
      v_hat[last[s]] = (ev_hat[last[s]-1,stim_assoc[last[s]]] + ev_hat[last[s]-1,stim_nassoc[last[s]]])/2 * v_mod[s];
      as_chosen[last[s]] = ev_hat[last[s],stim_assoc[last[s]]];
      pe_tot_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_assoc[last[s]]]);
      pe_pos_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_assoc[last[s]]]);
      pe_neg_hat[last[s]] = 0;
      log_lik[last[s]] = wiener_lpdf(RT[last[s]] | a[s] -  ((iter[last[s]]/trials[last[s]])*a_mod[s]),tau[s],z,v_hat[last[s]]);
    }
  }
}
