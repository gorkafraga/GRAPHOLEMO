Used scripts

## Basic analyses
analyse.performance.R (preprocesses raw data files and outputs summary file with accuracy and mean RTs (performance_data.Rda)
assess_rlddm_slrt_performance_correlations.R (takes summary performance file, reading fluency scores and estimated model parameters as input and computes correlations between all variables)
write_slrt_regressors.R (takes raw reading fluency score files as input and outputs csv-file of mean-centered scores to be used as 2nd-level regressors in imaging data analyses)

## RLDDM analyses
# Model fit
rlddm.R (loads/preprocesses task performance data, runs parameter estimation and writes out parameters used as regressors in imaging data
	load_data.R (loads or preprocesses task performance data to appropriate format. Output: list object)
	run_rlddm.R (runs parameter estimation with defined settings. Output: stanfit object)
	extract_stanfit.R (extracts parameters from stanfit objects and writes mean-centered parameters (individual and subject level) in separate files. Output: csv-files)

# Model comparison
model_comparison.R (takes saved stan object as input and returns predictive accuracy measures (WAIC, loo)

# Parameter recovery
sample_from_posterior.R (samples a pre-defined number of posterior parameters, used as input to generate data for parameter recovery.
generate_data.R (takes a set of posterior parameters as input and returns sets of simualated data with those parameters)
	wiener_generator.R (helper function that generates random samples of the wiener first time passage distribution)
get_summary_and_plots (produces summary measures and plots from generated data)