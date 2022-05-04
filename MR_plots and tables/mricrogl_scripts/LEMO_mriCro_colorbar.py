# TASK A 

# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 

#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("S -17  ; C -90; A 2; ");

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0002\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.327, 1836,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0003\spmT_0001.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
gl.removesmallclusters(2, 3.321, 2268,1)

# position of color bar 
gl.colorbarposition(2)
gl.colorbarsize(0.1)
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\colorbar.png')


