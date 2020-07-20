
stan_fit <- hBayesDM_model(
  task_name       = "choiceRT",
  model_name      = "ddm_task",
  model_type      = "",
  data_columns    = c("subjID", "choice", "RT"),
  parameters      = list(
    "alpha" = c(0, 0.5, Inf),
    "beta" = c(0, 0.5, 1),
    "delta" = c(-Inf, 0, Inf),
    "tau" = c(0, 0.15, 1)
  ),
  regressors      = NULL,
  postpreds       = NULL,
  preprocess_func = choiceRT_preprocess_func)