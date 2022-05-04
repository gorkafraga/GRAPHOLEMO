# CHUNK FOR con_0002
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -53 58 -47 34 -5 34 -32 43 37 16 -44 1 -23 -35 43 22 1 16 10 19 43 16; C -24 0 -42 21 -21 -75 -84 6 -48 3 39 -42 -21 -6 42 -39 -51 -93 -6 -36 27 -72; A 6 -6 45 0 -6 -12 0 24 42 -6 9 -39 -6 -9 -39 18 -9 -6 -12 21 24 54 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v31//2Lv_GLM0_mopa_aspe////con_0002//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5.7 ,27,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_a_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0002.png')
####
# CHUNK FOR con_0003
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -47 40 46 -44 -47 43 13 -41 -35 -35 -35 -38 43; C -57 -75 48 42 39 -54 -96 21 -24 -51 -69 -51 -45; A 48 -15 6 15 -12 51 9 -12 -9 6 57 -6 -21 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel//FeedbackLearning//FBL_A//LEMO_rlddm_v31//2Lv_GLM0_mopa_aspe////con_0003//spmT_0001.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1, 5.7 ,27,2) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl//fbl_a_mopa////FBL_A_Result_regions_2Lv_GLM0_mopa_aspe_withFWE_con_0003.png')
