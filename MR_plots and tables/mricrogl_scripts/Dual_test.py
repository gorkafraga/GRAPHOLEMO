# TASK A 

# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 

#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("L S -17 31 37 7 40 -38 13 ; C -90 3 -6 -6 -36 15 12;A -3 -36 12 54 72 24 -9; ");

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FeedbackLearning\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0002\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.327, 1836,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FeedbackLearning\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0003\spmT_thresholded.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
#gl.removesmallclusters(2,2268) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
#transparent? 
gl.opacity(1, 85)
gl.opacity(2, 85)

# position of color bar 
gl.colorbarposition(2)
gl.colorbarsize(0.03)
#save 
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\\dualcolor\MRICROGL_FBLA_thirds_stim_regionsFromCon3.png')
