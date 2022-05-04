# MODEL WITH DRIFT RATE
#
# CHUNK FOR con_0006
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic("  S -29 10 -26 28 25; C -60 -75 -3 -39 3; A -45 -6 0 60 9")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_vpe////con_0006//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_vpe_withFWE_con_0006.png')
#
# MODEL WITH ASSOCIATION STRENGTH
#
# CHUNK FOR con_0006
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" S -11 16; C -87 -72; A -3 -12 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0006//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
#gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0006.png')
####

# CHUNK FOR con_0008
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" S -50 31 -8 -14 -17 -29 -17 7 28 -26 70 19; C -72 -33 42 9 27 42 -3 -54 -63 -45 -3 3; A 27 48 -12 -9 48 -12 -27 18 18 3 6 24 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0008//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
#gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0008.png')
####
# CHUNK FOR con_0009
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" S 37; C 24; A -9 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0009//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
#gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0009.png')
####



# CHUNK FOR con_0006
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic("  S -23 22; C -90 -93; A 3 3 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_B//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0006//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_B_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0006.png')
####
 
####
# CHUNK FOR con_0008
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic("  S 19 -44 -14 -35 -14 25 1; C 15 -75 9 -27 27 -9 51; A -15 36 -12 -12 -3 -24 -9 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_B//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0008//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_B_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0008.png')
####
# CHUNK FOR con_0009
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic("  S 4 49; C 6 21; A 63 3 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_B//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0009//spmT_0001_threshSPM.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_B_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0009.png')
####
