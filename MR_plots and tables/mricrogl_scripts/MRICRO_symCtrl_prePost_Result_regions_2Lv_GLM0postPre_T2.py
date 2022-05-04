# CHUNK FOR con_0004
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S 31; C -63; A 33 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel_pairedTs//symCtrl_prePost//2Lv_GLM0//con_0004//spmT_0002.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1,3,7398,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl////symCtrl_prePost_Result_regions_2Lv_GLM0postPre_con_0004_T2.png')
####
# CHUNK FOR con_0005
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S 25 -29; C -66 -51; A 45 42 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel_pairedTs//symCtrl_prePost//2Lv_GLM0//con_0005//spmT_0002.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1,3,5373,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl////symCtrl_prePost_Result_regions_2Lv_GLM0postPre_con_0005_T2.png')
####
# CHUNK FOR con_0006
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -29 28; C -54 -54; A 42 45 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel_pairedTs//symCtrl_prePost//2Lv_GLM0//con_0006//spmT_0002.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1,3,4482,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl////symCtrl_prePost_Result_regions_2Lv_GLM0postPre_con_0006_T2.png')
####
# CHUNK FOR con_0010
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S -47; C -51; A 45 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel_pairedTs//symCtrl_prePost//2Lv_GLM0//con_0010//spmT_0002.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1,3,2808,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl////symCtrl_prePost_Result_regions_2Lv_GLM0postPre_con_0010_T2.png')
####
# CHUNK FOR con_0012
#Load basics
import gl
gl.resetdefaults()
gl.bmpzoom(1)
gl.loadimage("spm152")
gl.backcolor(255,255,255)
# Specify slides ,file to load and  formats
gl.mosaic(" L S 37 -29; C -96 -102; A -6 -6 ")
gl.overlayload("O://studies//grapholemo//analysis//LEMO_GFG//mri//2ndLevel_pairedTs//symCtrl_prePost//2Lv_GLM0//con_0012//spmT_0002.nii")
gl.minmax(1,0,10)
gl.colorname(1, "4hot")
gl.removesmallclusters(1,3,2457,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
gl.opacity(1,85)
gl.colorbarposition(1)
gl.savebmp('O://studies//grapholemo//analysis//LEMO_GFG//mri//visualizations_mricrogl////symCtrl_prePost_Result_regions_2Lv_GLM0postPre_con_0012_T2.png')
####
