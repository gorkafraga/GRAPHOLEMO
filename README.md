# GRAPHOLEMO
Scripts for Grapheme-Phoneme Learning Modelling  (postdoctoral project running from 2020-2022 at the University of Zurich). Functions for MRI analysis (Matlab), computational model of learning (R,Stan), stimuli presentation (NeurobsPresentation), statistics and visualizations (R)

## Publication scripts 
This section aims at helping finding the scripts involve in the BioRxiv publication and associated submission for peer-review (Fraga-González, G., Haller, P., Willinger, D., Gehrig, V., Frei, N., & Brem, S. (2023). Neural representation of association strength and prediction error during novel symbol-speech sounds learning. bioRxiv, 2023-11. https://doi.org/10.1101/2023.11.06.564575). 

This README aims tries to facilitate navigating through the scripts. There was ample room for improvement in script organization at the time of project's initial setup, so please see below and contact me for clarifications if needed (contact details in publication; [ORCID](http://orcid.org/0000-0002-1857-8607)). See also the abbreviation section for clarifications on the name parts. 

#### Behavioral 
##### BEH_cognitive
descriptive tables and plot on performance in the cognitive tests (reading, spelling, etc)

##### BEH_computational_models
all scripts related to running the models in Stan and preparing the data for them.
-  **LEMO_model_run_rlddm**  runs the rlddm model in Stan: gathers the samples to create a stan fit object and extracts log lik values for model comparisons
-  **LEMO_gatherOutput**  gathers the output of the models and generate tables and plots. There is an associated function 
- **BEH_computational_models/Stan** the Stan scripts named *LEMO_rlddm_* are the scripts to compute the models in our project. Ignore subfolders *allread*  (script tests  for other project) and those with _bandit2arm_ (initial tests in those tasks and models as examples)



## Abbreviations 
These are the main abbreviations used in folder names and filename parts

_Main_
-  **LEMO** shortname for the project title GRAPHOLEMO 
-  **BEH_**  behavioral
-  **MR_**  MRI
-  **feedbacklearning** feedback learning task (main task)
-  **FBL**  abbreviation of feedback learning task, FBL_A and FBL_B refer to the task parts
-  **symctrl** the visual symbol task (control visual task)
-  **ROI** region of interest analysis
-  **func** funcions usually called by scripts with 'run' in their filename
-  **run** scripts that will run analyses using functions in the same folder
-  **GLM** general linear model - used in the main MR analysis scripts. GLM0, GLM1, etc, indicate different versions
-  **rlddm** reinforcement learning drift diffusion model. The versions are added as suffix e.g., \*_rlddm_v12 , etc. Versions descriptions provided in README at the corresponding folder
-  **gpl** used in subject ID to designate the experiment  'grapheme-phoneme-learning' e.g., gpl001
- **_mopa** used in the model-based MR analyses as suffix indicating _modulating paramters_. A suffix follows indicating the modulating parameters for example:  **_mopa_aspe**: associative strenght and prediction error ; **_mopa_vpe** drift rate and prediction error 

_other_
-  **_EH.** suffix with name initials of a MSc Thesis (ignore)
-  **Allread**  refers to a previous project Allread (ignore)
-  **\_AR\_** acronym for Allread project (ignore)
