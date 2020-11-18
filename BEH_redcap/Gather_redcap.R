rm(list=ls(all=TRUE)) # remove all variables (!)
#install.packages('openxlsx')
library(openxlsx)
library(readr)
library(dplyr)
library(pracma)
#-----------------------------------------------------------------------------------------------------------------------------
# _____                       _     ____          _                       _       _        
# | ______  ___ __   ___  _ __| |_  |  _ \ ___  __| | ___ __ _ _ __     __| | __ _| |_ __ _ 
# |  _| \ \/ | '_ \ / _ \| '__| __| | |_) / _ \/ _` |/ __/ _` | '_ \   / _` |/ _` | __/ _` |
# | |___ >  <| |_) | (_) | |  | |_  |  _ |  __| (_| | (_| (_| | |_) | | (_| | (_| | || (_| |
# |_____/_/\_| .__/ \___/|_|   \__| |_| \_\___|\__,_|\___\__,_| .__/   \__,_|\__,_|\__\__,_|
#            |_|                                              |_|                           
#
# - REQUIRES SUBJECT IDENTIFIER TO BE THE FIRST VARIABLE! ! ! 
##-----------------------------------------------------------------------------------------------------------------------------
# EXPORT OPTIONS 
############################################################################################################################
mergeCases = 1 # if = 1 it will read cases from your master file
masterfile = 'O:/studies/allread/mri/analysis_GFG/Allread_MasterFile_GFG.xlsx'
#Set directories and output name 
#############################################################################################################################
dirinput <-'O:/studies/allread/mri/analysis_GFG/stats/cognitive_tests'
diroutput <-'O:/studies/allread/mri/analysis_GFG/stats/cognitive_tests'
outputfilename <- 'BehData_3TPs.xlsx'
setwd(dirinput)

# read data sets
D1 = read.delim("AllreaddataNEWREEVAL_DATA_2020-10-23_T1.csv", sep = "\t", header=TRUE)
D2 = read.delim("AllreaddataNEWREEVAL_DATA_2020-10-23_T2.csv", sep = "\t",header=TRUE)
D3 = read.delim("AllreaddataNEWREEVAL_DATA_2020-10-23_T3.csv",sep = "\t" , header=TRUE)

#read questionnaires
#Q1 =  read.delim("AllReadFragebogen_DATA_2020-05-27_1425_T1.csv", sep = "\t", header=TRUE)
#Q1_idList <- unlist(lapply(strsplit(Q1$email,'@'),'[[',1))
#Q1$subjID <- Q1_idList
##Q1trim <- Q1[grep('^VP*.[[:digit:]]{4}$',Q1$subjID),] #Take only those rows where the email user identifier is expectly "VP+4 numbers" (6 characters)
#Q1trim$subjID <- gsub("VP","AR",Q1trim$subjID)
#newQ1names  <- gsub(pattern = '^klasse_schulstufe$',replacement = 'class',colnames(Q1trim),ignore.case = FALSE, perl = TRUE)
#newQ1names  <- gsub(pattern = '^typ_der_klasse$',replacement = 'class_type',newQ1names,ignore.case = FALSE, perl = TRUE)
#newQ1names  <- gsub(pattern = '^kind_klasse_wiederholt$',replacement = 'class_repeat',newQ1names,ignore.case = FALSE, perl = TRUE)
#colnames(Q1trim) <- newQ1names#

#Q1trim[1,c("subjID"),with =FALSE]

#small fix in first variable name...
colnames(D1)[1] <-'vp'
colnames(D2)[1] <-'vp'
colnames(D3)[1] <-'vp'

# Variable name sanity check
allVarsNames <- colnames(D1) # use  D1 as reference variable names
if (length(setdiff(allVarsNames,colnames(D2)))==0 && length(setdiff(allVarsNames,colnames(D3)))==0) {
  print('yes, varnames are consistent!')
} else { print('check consistency of variable names')
}


# Select variables
##################################################################################################################################
#Deleting all unused Variables from Datasets
#cols2remove <- c("pre_test_research_code", "gl_research_code", "schreibon_code", "schreibon_code_2", "counterbalance_ablauf", "counterbalance_avc_condord", "counterbalance_avc_version","counterbalance_avc_lr"
               #     ,"counterbalance_fpvs_r1","counterbalance_fpvs_r2","counterbalance_visstring", "bemerkungen_5", "datum_erster_telefonkontak", "wer_k_rzel",
cols2keep <- c("vp","alter","dov","school_semester","school_class",
               "rias_twert_verbal","rias_twert_nonverbal","summe_twerte_tot","rias_vix","rias_nix","rias_gix","prozentrang_vix","prozentrang_nix","prozentrang_gix",
               "buchstabenlaute_richtige","buchstaben_namen_richtige","komplexe_buchstaben",
               "sls_total","sls_richtige_rohwert","sls_lesequotient","sls_total_2","sls_richtige_rohwert_2","sls_lesequotient_2",
               "ran_objekte1_richtig","ran_objekte1_fehler","ran_objekte1_a","ran_objekte1_gesamtzeit","ran_objekte2_richtige","ran_objekte2_fehler","ran_objekte2_a","ran_objekte2_gesamtzeit",
               "zn_lz_v","zn_v_rohwert","zn_lz_r","zn_r_rohwert","gesamtrohwert_zn",
               "slrt_w_corr_pr_mean","slrt_pw_corr_pr_mean","slrt_w_gesamt","slrt_w_fehler","slrt_w_auslassung","slrt_w_richtig","slrt_pw_gesamt","slrt_pw_fehler","slrt_pw_auslassung","slrt_pw_richtig",
               
               "elfe_gesamt","elfe_twert","elfe_pr",
               
               "trainingsliste_gesamtzeit","trainingsliste_richtige","transferliste_gesamtzeit","transferliste_richtige","kontrollliste_gesamtzeit","kontrolliste_richtige",
               "pw_gesamtzeit","pseudow_rterliste_anzahl_r","pseudow_rterliste_gesamtze","pw_2_r",
               "schreibon_w_rohwert","schreibon_prozenz_w","schreibon_prozentrang_w","schreibon_t_wert_w", "schreibon_w_rohwert_2","schreibon_prozenz_w_2","schreibon_prozentrang_w_2","schreibon_t_wert_w_2",
              
               "graphemtreffer_richtige","graphemtreffer_prozent","graphemtreffer_prozentrang","graphemtreffer_t_wert",
               "alphabetische_strategie_r","alphabetische_s_prozent","alphabetische_s_pr","alphabetische_s_twert",
               "orthograph_strategie_r","orthograph_s_prozent","orthograph_s_pr","orthograph_s_twert",
               "morphematische_strategie_r","morphemat_s_prozent","morphematische_s_pr","morphematische_s_twert",
              
              "graphemtreffer_richtige_2","graphemtreffer_prozent_2","graphemtreffer_prozentrang_2","graphemtreffer_t_wert_2",
              "alphabetische_strategie_r_2","alphabetische_s_prozent_2","alphabetische_s_pr_2","alphabetische_s_twert_2",
              "orthograph_s_r_2","orthograph_s_prozent_3","orthograph_s_pr_2","orthograph_s_twert_2",
              "morphematische_strategie_r_2","morphemat_s_prozent_2","morphematische_s_pr_2","morphematische_s_twert_2")
              #"ppvt_rohwert","ppvt_t_wert","ppvt_prozentrang","total_level_time",)


for(ii in 1:length(cols2keep)){
  if (  which(colnames(D1)==cols2keep[ii]) > 1) {
    disp(cols2keep[ii])
    disp(ii)
  }
}
# TRIM dataset. Select only variables in previous list
#-----------------------------------------------------
D1trim <- D1[, which(colnames(D1) %in% cols2keep), drop = FALSE]   
D2trim <- D2[, which(colnames(D1) %in% cols2keep), drop = FALSE]
D3trim <- D3[, which(colnames(D1) %in% cols2keep), drop = FALSE]
 
#D1trim <- D1[, colnames(D1) %in% cols2keep, drop = FALSE]   
#D2trim <- D2[, colnames(D2) %in% cols2keep, drop = FALSE]
#D3trim <- D3[, colnames(D3) %in% cols2keep, drop = FALSE]

if (length(D1trim) != length(cols2keep)){
  
  disp('STOP! Some variables from your list to keep were not in the data or you have duplicates on your variable selection list!!! ')
}
    
    
## RENAME VARIABLES 
#################################################################################################################################
newVarsNames <- colnames(D1trim)
newVarsNames  <- gsub(pattern = '^vp$',replacement = 'subject',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^geschlecht$',replacement = 'sex',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^fam_risiko$',replacement = 'family_risk',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^dov$',replacement = 'Date_beh',newVarsNames,ignore.case = FALSE, perl = TRUE)


newVarsNames  <- gsub(pattern = '^rias_twert_verbal$',replacement = 'RIAS_verbal_tscore',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^rias_twert_nonverbal$',replacement = 'RIAS_nonverbal_tscore',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^rias',replacement = 'RIAS',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^prozentrang_vix$',replacement = 'RIAS_vix_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^prozentrang_nix$',replacement = 'RIAS_nix_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^prozentrang_gix$',replacement = 'RIAS_gix_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^buchstabenlaute_richtige$',replacement = 'LETTERKNOW_sounds_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^buchstaben_namen_richtige$',replacement = 'LETTERKNOW_names_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^komplexe_buchstaben$',replacement = 'LETTERKNOW_complex',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^sls_richtige_rohwert_2',replacement = 'SLS_class1to4_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^sls_lesequotient_2$',replacement = 'SLS_class1to4_readingQ',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^sls_total_2$',replacement = 'SLS_class1to4_total',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^sls_richtige_rohwert$',replacement = 'SLS_class2to9_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^sls_lesequotient$',replacement = 'SLS_class2to9_readingQ',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^sls_total$',replacement = 'SLS_class2to9_total',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^ran_objekte1_richtig$',replacement = 'RAN_obj1_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^ran_objekte2_richtige$',replacement = 'RAN_obj2_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^ran_objekte1_fehler$',replacement = 'RAN_obj1_inc',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^ran_objekte2_fehler$',replacement = 'RAN_obj2_inc',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames <- gsub(pattern = '^zn_lz_v$',replacement = 'DIGITS_span_forward',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames <- gsub(pattern = '^zn_v_rohwert$',replacement = 'DIGITS_sum_forward',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames <- gsub(pattern = '^zn_lz_r$',replacement = 'DIGITS_span_backwards',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames <- gsub(pattern = '^zn_r_rohwert$',replacement = 'DIGITS_sum_backwards',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames <- gsub(pattern = '^gesamtrohwert_zn$',replacement = 'DIGITS_mean',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^slrt_w_richtig$',replacement = 'SLRT_words_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^slrt_pw_richtig$',replacement = 'SLRT_pseudo_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^slrt_w_fehler$',replacement = 'SLRT_words_inc',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^slrt_pw_fehler$',replacement = 'SLRT_pseudo_inc',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^slrt_w_corr_pr_mean$',replacement = 'SLRT_words_corr_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^slrt_pw_corr_pr_mean$',replacement = 'SLRT_pseudo_corr_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^elfe_gesamt$',replacement = 'ELFE_mean',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^elfe_twert$',replacement = 'ELFE_tscore',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^elfe_pr$',replacement = 'ELFE_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^trainingsliste_gesamtzeit$',replacement = 'ListTraining_mean_secs',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^trainingsliste_richtige$',replacement = 'ListTraining_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^transferliste_gesamtzeit$',replacement = 'ListTransfer_mean_secs',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^transferliste_richtige$',replacement = 'ListTransfer_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^kontrollliste_gesamtzeit$',replacement = 'ListControl_mean_secs',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^kontrolliste_richtige$',replacement = 'ListControl_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^pw_gesamtzeit$',replacement = 'ListPseudo1_mean_secs',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^pseudow_rterliste_anzahl_r$',replacement = 'ListPseudo1_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = 'vpw_2_r$',replacement = 'ListPseudo2_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^pseudow_rterliste_gesamtze$',replacement = 'ListPseudo2_mean_secs',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^schreibon_w_rohwert_2$',replacement = 'SCHREIBON_words_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^schreibon_prozenz_w_2$',replacement = 'SCHREIBON_words_perCorr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^schreibon_prozentrang_w_2$',replacement = 'SCHREIBON_words_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^schreibon_t_wert_w_2$',replacement = 'SCHREIBON_Other_words_tscore',newVarsNames,ignore.case = FALSE, perl = TRUE)

newVarsNames  <- gsub(pattern = '^schreibon_w_rohwert$',replacement = 'SCHREIBON_Class2_words_corr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^schreibon_prozenz_w$',replacement = 'SCHREIBON_Class2_words_perCorr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^schreibon_prozentrang_w$',replacement = 'SCHREIBON_Class2_words_pr',newVarsNames,ignore.case = FALSE, perl = TRUE)
newVarsNames  <- gsub(pattern = '^schreibon_t_wert_w$',replacement = 'SCHREIBON_Class2_words_tscore',newVarsNames,ignore.case = FALSE, perl = TRUE)

 
# TRIM dataset. Select only variables 
#-----------------------------------------------------
#`%!in%` = Negate(`%in%`)
colnames(D1trim)<-newVarsNames
colnames(D2trim)<-newVarsNames
colnames(D3trim)<-newVarsNames

colnames(D1trim)[-1]<- paste0(newVarsNames[-1],'_T1')
colnames(D2trim)[-1] <- paste0(newVarsNames[-1],'_T2') 
colnames(D3trim)[-1] <- paste0(newVarsNames[-1],'_T3')  

#MERGE
##############################################################################################################################
#Merging all Datasets rows with common denominator VP into wide format (what to do with Missing value?)
merged12 <- merge.data.frame(D1trim, D2trim, by = "subject", all.x = TRUE, all.y = TRUE, sort = TRUE) #Add columns NA for vp that don't overlap, sort by vp after merge
Dmerged<- merge.data.frame(merged12, D3trim, by = "subject", all.x = TRUE, all.y = TRUE, sort = TRUE)
 

#COMMON CASES MERGE
##############################################################################################################################
#Merging all Datasets rows with common denominator VP into wide format (what to do with Missing value?)
if (mergeCases  == 1){
  masterData <- read.xlsx(masterfile,sheet = 1,detectDates = TRUE)
  Dmerged$subjID <- paste("AR",Dmerged$subject,sep="")
  Dmerged <- merge.data.frame(masterData,Dmerged, by = "subjID", all.x = TRUE, all.y = TRUE, sort = TRUE)
  #Dmerged <- merge.data.frame(Dmerged,Q1trim, by = "subjID", all.x = TRUE, all.y = TRUE, sort = TRUE)
  outputfilename <- gsub('.xlsx','_merged.xlsx',outputfilename)
}
#Save
###########################################################################################################################
# Export the cleaned and merged Dataset for SPSS or further R analysis (Master-data-set). Maybe changing variable structure in R?
write.xlsx(Dmerged,paste(diroutput,'/',outputfilename,sep=""))

 







