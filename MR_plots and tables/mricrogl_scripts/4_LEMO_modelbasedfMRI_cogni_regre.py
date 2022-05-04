 
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" S -35; C -84; A -18")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_regreNeg_GLM0_mopa_aspe_rias_nix_pr////from_1Lv_con0006//spmT_0001_clusters.nii")
gl.minmax(1,0,8)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa_regressors////FBL_A_2Lv_regreNeg_GLM0_mopa_aspe_rias_nix_pr_con0006.png')

#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic("  S 58; C -12; A -12")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_regreNeg_GLM0_mopa_aspe_ran_object_time_raw////from_1Lv_con0008//spmT_0001_clusters.nii")
gl.minmax(1,0,8)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa_regressors////FBL_A_2Lv_regreNeg_GLM0_mopa_aspe_ran_object_time_raw_con0008.png')

#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic("  S -32 19; C -90 -9; A -24 -18")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_B//LEMO_rlddm_v32//2Lv_regrePos_GLM0_mopa_aspe_wais4_tot_span_raw////from_1Lv_con0008//spmT_0001_clusters.nii")
gl.minmax(1,0,8)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa_regressors////FBL_B_2Lv_regreNeg_GLM0_mopa_aspe_wais4_tot_span_raw_con0008.png')
