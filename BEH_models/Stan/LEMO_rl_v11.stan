// ---------------------------------------------------------
//   _______     _____     ______   ______   ____    ____  
//   |_   __\   |_   _|   |_   _ `.|_   _ `.|_   \  /   _| 
//   | |__) |    | |       | | `. \ | | `. \ |   \/   |   
//   |  __ /     | |   _   | |  | | | |  | | | |\  /| |   
//  _| |  \ \_  _| |__/ | _| |_.' /_| |_.' /_| |_\/_| |_      
// |____| |___||________||______.'|______.'|_____||_____|
//
// Version 1.1: 
//  - Modulation of decision boundary (exponentional):  a[s] * pow(iter[trial]/10,a_mod[s]))
//  - learning rate (x1)  
// -------------------------------------------------------------------- 
data {
  int<lower=1> N;      // Number of subjects
  real minRT[N];       // minimum RT for each subject of the observed data
  int first[N];        // first trial of subject
  int last[N];         // last trial of subject
  int<lower=1> T;      // Number of observations
  real RTbound;        // lower bound of RT across all subjects (e.g., 0.1 second)
  real iter[T];        // trial of given observation
  int response[T];     // encodes successful trial [1: lower bound (incorrect), 2: upper bound(correct)]
  real RT[T];          // reaction time
  int value[T];        // value of trial: successful / unsuccessful  1 or 0
  int stim_assoc[T];   // index of associated sound-symbol pair
  int stim_nassoc[T];  // index of presented non-associated symbol
  int n_stims[N];      // number of items learned by each subject (represents # blocks)
}
// ------------------------------------------------------------
parameters {
  //  GROUP LEVEL raw Hyperparameters
  vector[2] mu_eta_pr; // group priors mean and stdev for learning rates 
  vector<lower=0>[2] sigma_eta;   

  
  // SUBJECT LEVEL  raw parameters
  vector[N] eta_pr; // learning rate  
   
  
}
// ------------------------------------------------------------
transformed parameters {
 //  SUBJECT LEVEL transformed parameters  
 // Declare
  vector[N] eta; 
   
  vector<lower=0>[N] a; //(a): Boundary separation or Speed-accuracy trade-off 
  vector[N] a_mod; 
  vector<lower=0, upper=10>[N] v_mod;             
  vector<lower=RTbound, upper=max(minRT)>[N] tau; //
          
  //Constrain
  eta = 0.1*Phi_approx(mu_eta_pr[1] + sigma_eta[1] * eta_pr);  
   
   
}
// ------------------------------------------------------------
model {
  // Declare some initial variables
   
 // GROUP LEVEL priors 
  mu_pr  ~ normal(0, 1);
  mu_eta_pr ~ normal(0, 0.3);
  sigma_eta ~ normal(0, 0.5); //
  sigma ~ normal(0, 0.2);

 // SUBJECT LEVEL priors 
  eta_pr ~ normal(0,1.5); 
  
  
  // TRIAL LEVEL parameter , Assign values
  // Begin subject loop 
  //--------------------- 
  // until second last 
  for (s in 1:N) {  
    for(p in 1:n_stims[s]){      
      ev[first[s],p] = 0.5; // expected value starts in 0.5 for all stimuli in each subject
    }
    
    for(trial in (first[s]):(last[s]-1)) {
      for(p in 1:n_stims[s]){
        ev[trial+1,p] = ev[trial,p]; // expected value starts the same as preceding trial
      }
      // Trials from first to one before last  ~~~~~~
     // if lower bound (incorrect resp,that is response= 1)
      if (response[trial]==1){
  
        ev[trial+1,stim_nassoc[trial]] = ev[trial,stim_nassoc[trial]] + (eta[s] * fabs(value[trial]-(1-ev[trial,stim_nassoc[trial]]))); // adjust expected values for each stimuli pair in this trial
        ev[trial+1,stim_assoc[trial]] = ev[trial,stim_assoc[trial]] + (eta[s] * fabs(value[trial]-ev[trial,stim_assoc[trial]]));
      }
      // if upper bound (resp = 2)
      else{
        v[trial] = (ev[trial,stim_assoc[trial]] + ev[trial,stim_nassoc[trial]])/2 * v_mod[s];
        RT[trial] ~  wiener(a[s] * pow(iter[trial]/10,a_mod[s]),tau[s] ,beta,v[trial]);
        ev[trial+1,stim_nassoc[trial]] = ev[trial,stim_nassoc[trial]] + (eta[s] * (value[trial]-(1-ev[trial,stim_nassoc[trial]])));
        ev[trial+1,stim_assoc[trial]] = ev[trial,stim_assoc[trial]] + (eta[s] * (value[trial]-ev[trial,stim_assoc[trial]]));
      }
    }
    // Updates in last trial (no update of expected value) ~~~~~~
    if (response[last[s]]==1){
     
     
    }
    if (response[last[s]]==2){
     
     
    }
  } // end subject loop
} // end of model

// ------------------------------------------------------------
generated quantities {
  // Declare SUBJECT level parameters
  real z = 0.5; // constant bias to responses
  real<lower=0> mu_eta;                  

  real<lower=0> mu_a;                   
  real<lower=0> mu_a_mod; 
  real<lower=0> mu_v_mod;                   
  real<lower=RTbound, upper=max(minRT)> mu_tau;  
                   
  // Declare TRIAL LEVEL estimates
  real ev_hat[T,max(n_stims)]; // estimate of expected value
  real pe_pos_hat[T]; // estimate of  prediction error for trials positive, negative and both
  real pe_neg_hat[T];
  real pe_tot_hat[T]; 
  real as_active[T]; // association strength active, inactive and chosen stimuli pair
  real as_inactive[T];
  real as_chosen[T];
  vector[T] v_hat;  // estimated drift rate
  vector[T] log_lik; // log likelihood, fit estimate for model comparison 
  
  // Assign SUBJECT LEVEL  parameter values
  mu_eta = 0.1*Phi_approx(mu_eta_pr[1]);
  
  // Assign TRIAL LEVEL  parameter values
  // Begin subject loop 
 //---------------------  
  for (s in 1:N){
    for(p in 1:n_stims[s]){
      // estimates ev for pos values
      ev_hat[first[s],p] = 0.5; // estimate expected value starts in 0.5 for all stimuli in each subject
    }
    // Trials from first to one before last  ~~~~~
    for(trial in (first[s]):(last[s]-1)) {
      for(p in 1:n_stims[s]){
        ev_hat[trial+1,p] = ev_hat[trial,p];
      }
      as_active[trial] = ev_hat[trial,stim_assoc[trial]];  // estimate association strength for correct incorrect
      as_inactive[trial] = ev_hat[trial,stim_nassoc[trial]];
      // if lower bound
      if (response[trial]==1){
 
        as_chosen[trial] = ev_hat[trial,stim_nassoc[trial]];
        pe_tot_hat[trial] = value[trial]-(ev_hat[trial,stim_nassoc[trial]]);
        pe_neg_hat[trial] = value[trial]-(ev_hat[trial,stim_nassoc[trial]]);
        pe_pos_hat[trial] = 0;
        ev_hat[trial+1,stim_nassoc[trial]] = ev_hat[trial,stim_nassoc[trial]] + (eta[s] * fabs(value[trial]-(1-ev_hat[trial,stim_nassoc[trial]])));
        ev_hat[trial+1,stim_assoc[trial]] = ev_hat[trial,stim_assoc[trial]] + (eta[s] * fabs(value[trial]-ev_hat[trial,stim_assoc[trial]]));
        log_lik[trial] = wiener_lpdf(RT[trial] | a[s] * pow(iter[trial]/10,a_mod[s]),tau[s],z,v_hat[trial]);
      }
      // if upper bound (resp = 2)
      else{
        v_hat[trial] = (ev_hat[trial,stim_assoc[trial]] + ev_hat[trial,stim_nassoc[trial]])/2 * v_mod[s];
        as_chosen[trial] = ev_hat[trial,stim_assoc[trial]];
        pe_tot_hat[trial] = value[trial]-(ev_hat[trial,stim_assoc[trial]]);
        pe_pos_hat[trial] = value[trial]-(ev_hat[trial,stim_assoc[trial]]);
        pe_neg_hat[trial] = 0;
        ev_hat[trial+1,stim_nassoc[trial]] = ev_hat[trial,stim_nassoc[trial]] + (eta[s] * (value[trial]-(1-ev_hat[trial,stim_nassoc[trial]])));
        ev_hat[trial+1,stim_assoc[trial]] = ev_hat[trial,stim_assoc[trial]] + (eta[s] * (value[trial]-ev_hat[trial,stim_assoc[trial]]));
        log_lik[trial] = wiener_lpdf(RT[trial] | a[s] * pow(iter[trial]/10,a_mod[s]),tau[s],z,v_hat[trial]);
      }
    }
    // Updates in last trial (no update of expected value) ~~~~~
    as_active[last[s]] = ev_hat[last[s],stim_assoc[last[s]]];
    as_inactive[last[s]] = ev_hat[last[s],stim_nassoc[last[s]]];
    if (response[last[s]]==1){
      as_chosen[last[s]] = ev_hat[last[s],stim_nassoc[last[s]]];
      pe_tot_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_nassoc[last[s]]]);
      pe_neg_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_nassoc[last[s]]]);
      pe_pos_hat[last[s]] = 0;
      log_lik[last[s]] = wiener_lpdf(RT[last[s]] | a[s] * pow(iter[last[s]]/10,a_mod[s]),tau[s],z,v_hat[last[s]]);
    }
    else{

      as_chosen[last[s]] = ev_hat[last[s],stim_assoc[last[s]]];
      pe_tot_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_assoc[last[s]]]);
      pe_pos_hat[last[s]] = value[last[s]]-(ev_hat[last[s],stim_assoc[last[s]]]);
      pe_neg_hat[last[s]] = 0;
      log_lik[last[s]] = wiener_lpdf(RT[last[s]] | a[s] * pow(iter[last[s]]/10,a_mod[s]),tau[s],z,v_hat[last[s]]);
    }
  }
} // end generated quantities
