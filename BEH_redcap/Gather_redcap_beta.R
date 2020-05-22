rm(list=ls(all=TRUE)) # remove all variables (!)
#install.packages('openxlsx')
library(openxlsx)
library(readr)

#Set directories and output name 
#############################################################################################################################
dirinput <-'O:/studies/allread/mri/analysis_GFG/stats/cognitive_tests'
diroutput <-'O:/studies/allread/mri/analysis_GFG/stats/cognitive_tests'
outputfilename <- 'BehData_3TPs.xlsx'
setwd(dirinput)
# read data sets
D1 = read.delim("Allreaddata_DATA_2020-05-22_T1.csv", sep = "\t", header=TRUE)
D2 = read.delim("Allreaddata_DATA_2020-05-22_T2.csv", sep = "\t",header=TRUE)
D3 = read.delim("Allreaddata_DATA_2020-05-22_T3.csv",sep = "\t" , header=TRUE)

#small fix in variable names for D2 and D3
colnames(D1)[1] <-'vp'
colnames(D2)[1] <-'vp'
colnames(D3)[1] <-'vp'

# Save as XLSX file for Redcap cleaning Adding missing values
#write.xlsx(D1,"~/Desktop/MA_EM_Data_cleaning",sheetName = "EM_Redcap_T1_Raw_Check",col.names = TRUE,showNA=FALSE)
#write.xlsx(D2,"~/Desktop/MA_EM_Data_cleaning",sheetName = "EM_Redcap_T2_Raw_Check",col.names = TRUE,showNA=FALSE)
#write.xlsx(D3,"~/Desktop/MA_EM_Data_cleaning",sheetName = "EM_Redcap_T3_Raw_Check",col.names = TRUE,showNA=FALSE)


#VARIABLE CHECK
#############################################################################################################################
## First  check that variable names  are the same across data sets!
allVarsNames <- colnames(D1) # take D1 as default variable names.
if (length(setdiff(allVarsNames,colnames(D2)))==0 && length(setdiff(allVarsNames,colnames(D3)))==0) {
  print('yes, varnames are consistent!')
} else { print('check consistency of variable names')
}

 
# LISTING AND REMOVING UNUSED VARS
##################################################################################################################################
#Deleting all unused Variables from Datasets
#cols2remove <- c("pre_test_research_code", "gl_research_code", "schreibon_code", "schreibon_code_2", "counterbalance_ablauf", "counterbalance_avc_condord", "counterbalance_avc_version","counterbalance_avc_lr"
               #     ,"counterbalance_fpvs_r1","counterbalance_fpvs_r2","counterbalance_visstring", "bemerkungen_5", "datum_erster_telefonkontak", "wer_k_rzel",
cols2keep <- c("vp","klasse","geschlecht","fam_risiko","kontraindikationen","geschlecht2",
               "trainieren_t1","trainingsgruppe","schulstufe","alter",
               "rias_twert_verbal","rias_twert_nonverbal","summe_twerte_tot","rias_vix","rias_nix","rias_gix",
               "prozentrang_vix","prozentrang_nix","prozentrang_gix",
               "buchstabenlaute_richtige","buchstaben_namen_richtige","komplexe_buchstaben",
               "sls_richtige_rohwert","sls_lesequotient","sls_total_2","sls_richtige_rohwert_2","sls_lesequotient_2",
               "ran_objekte1_richtig","ran_objekte1_fehler","ran_objekte1_a","ran_objekte1_gesamtzeit","ran_objekte2_richtige","ran_objekte2_fehler","ran_objekte2_a","ran_objekte2_gesamtzeit",
               "zn_lz_v","zn_v_rohwert","zn_lz_r","zn_r_rohwert","gesamtrohwert_zn",
               "slrt_w_gesamt","slrt_w_fehler","slrt_w_auslassung","slrt_w_richtig","pr_richtige_w","slrt_pw_gesamt","slrt_pw_fehler","slrt_pw_auslassung","slrt_pw_richtig","pr_richtige_pw",
               "elfe_gesamt","elfe_twert","elfe_pr",
               "trainingsliste_gesamtzeit","trainingsliste_richtige","transferliste_gesamtzeit","transferliste_richtige","kontrollliste_gesamtzeit","kontrolliste_richtige","pw_gesamtzeit","pseudow_rterliste_anzahl_r","pseudow_rterliste_gesamtze","pw_2_r",
               "schreibon_w_rohwert","schreibon_prozenz_w","schreibon_prozentrang_w","schreibon_t_wert_w","graphemtreffer_richtige","graphemtreffer_prozent","graphemtreffer_prozentrang","graphemtreffer_t_wert","alphabetische_strategie_r","alphabetische_s_prozent","alphabetische_s_pr","alphabetische_s_twert","orthograph_strategie_r","orthograph_s_prozent","orthograph_s_pr","orthograph_s_twert","morphematische_strategie_r","morphemat_s_prozent","morphematische_s_pr","morphematische_s_twert","schreibon_w_rohwert_2","schreibon_prozenz_w_2","schreibon_prozentrang_w_2","schreibon_t_wert_w_2","graphemtreffer_richtige_2","graphemtreffer_prozent_2","graphemtreffer_prozentrang_2","graphemtreffer_t_wert_2","alphabetische_strategie_r_2","alphabetische_s_prozent_2","alphabetische_s_pr_2","alphabetische_s_twert_2","orthograph_s_r_2","orthograph_s_prozent_3","orthograph_s_pr_2","orthograph_s_twert_2","morphematische_strategie_r_2","morphemat_s_prozent_2","morphematische_s_pr_2","morphematische_s_twert_2",
               "ppvt_rohwert","ppvt_t_wert","ppvt_prozentrang","total_level_time","mean_response_time","total_trials","total_correct_trials","total_wrong_trials","correct_trial_percentage","pretest_complete","research_code_v2","total_level_time_v2","mean_response_time_v2","total_trials_v2","total_correct_trials_v2","total_wrong_trials_v2","correct_trial_percentage_v2","alter23","artificial_letter_training_complete")


D1trim <- D1[, names(D1) %in% cols2keep, drop = F] #i 
D2trim <- D2[, names(D2) %in% cols2keep, drop = F]
D3trim <- D3[, names(D3) %in% cols2keep, drop = F]
 
## RENAME VARIABLES 
#################################################################################################################################
# Translate some stuff to English
newVarsNames <- names(D1trim)
newVarsNames  <- gsub(pattern = 'vp',replacement = 'subject',newVarsNames)
newVarsNames  <- gsub(pattern = 'klasse',replacement = 'class',newVarsNames)
newVarsNames  <- gsub(pattern = 'geschlecht',replacement = 'sex',newVarsNames)
newVarsNames  <- gsub(pattern = 'fam_risiko',replacement = 'family_risk',newVarsNames)

newVarsNames  <- gsub(pattern = 'rias_twert_verbal',replacement = 'RIAS_verbal_tscore',newVarsNames)
newVarsNames  <- gsub(pattern = 'rias_twert_nonverbal',replacement = 'RIAS_nonverbal_tscore',newVarsNames)

newVarsNames  <- gsub(pattern = 'gesamtzeit',replacement = 'mean',newVarsNames)
newVarsNames  <- gsub(pattern = 'rohwert',replacement = 'raw',newVarsNames)
newVarsNames  <- gsub(pattern = 'twert',replacement = 'tscore',newVarsNames)


newVarsNames  <- gsub(pattern = 'slrt_w',replacement = 'SLRT_words',newVarsNames)
newVarsNames  <- gsub(pattern = 'slrt_pw',replacement = 'slrt_pseudo',newVarsNames)


newVarsNames  <- gsub(pattern = 'ran_objekte1_richtig',replacement = 'RAN_obj1_corr',newVarsNames)
newVarsNames  <- gsub(pattern = 'ran_objekte2_richtig',replacement = 'RAN_obj2_corr',newVarsNames)


newVarsNames  <- gsub(pattern = 'gesamtzeit',replacement = 'mean',newVarsNames)
newVarsNames  <- gsub(pattern = 'gesamt',replacement = 'mean',newVarsNames)
newVarsNames  <- gsub(pattern = 'rohwert',replacement = 'raw',newVarsNames)
newVarsNames  <- gsub(pattern = 'twert',replacement = 'tscore',newVarsNames)
# Add  time point information
colnames(D1trim)[-1] <- paste0(newVarsNames[-1],'_T1')
colnames(D2trim)[-1] <- paste0(newVarsNames[-1],'_T2') 
colnames(D3trim)[-1] <- paste0(newVarsNames[-1],'_T3')  

#MERGE
##############################################################################################################################
#Merging all Datasets rows with common denominator VP into wide format (what to do with Missing value?)
merged12 <- merge.data.frame(D1trim, D2trim, by = "vp", all.x = TRUE, all.y = TRUE, sort = TRUE) #Add columns NA for vp that don't overlap, sort by vp after merge
Dmerged<- merge.data.frame(merged12, D3trim, by = "vp", all.x = TRUE, all.y = TRUE, sort = TRUE)
 

#Save
###########################################################################################################################
# Export the cleaned and merged Dataset for SPSS or further R analysis (Masterdataset). Maybe changing variable structure in R?
write.xlsx(Dmerged,paste(diroutput,'/',outputfilename,sep=""))

 







