# CHUNK FOR con_0006
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -11 16; C -87 -72; A -3 -12 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0006//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0006.png')
####
# CHUNK FOR con_0007
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S ; C ; A  ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0007//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0007.png')
####
# CHUNK FOR con_0008
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -50 31 -8 -14 -17 -29 -17 7 28 -26 70 19; C -72 -33 42 9 27 42 -3 -54 -63 -45 -3 3; A 27 48 -12 -9 48 -12 -27 18 18 3 6 24 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0008//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
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
gl.mosaic(" L S 37; C 24; A -9 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v32//2Lv_GLM0_mopa_aspe////con_0009//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5 ,810,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0009.png')
####
