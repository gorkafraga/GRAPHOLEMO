# CHUNK FOR con0007
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -35; C -87; A 33 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_B//2Lv_regreNeg_GLM0_thirds_exMiss_lgvt_speed_pr//from_1Lv_con0007//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5.5 ,1566,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_regressors////FBL_B_Result_regions_2Lv_regreNeg_GLM0_thirds_exMiss_lgvt_speed_pr_con0007.png')
####
