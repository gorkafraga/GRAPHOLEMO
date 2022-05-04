# TASK A 

# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 

#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("S -17 31 37 7 40 -38 13 ; C -90 3 -6 -6 -36 15 12;A -3 -36 12 54 72 24 -9; ");

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0002\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.327, 1836,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0003\spmT_0001.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
gl.removesmallclusters(2, 3.321, 2268,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
#transparent? 
gl.opacity(1, 85)
gl.opacity(2, 85)

# position of color bar 
gl.colorbarposition(2)
gl.colorbarsize(0.03)
#save 
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLA_thirds_stim_regionsFromCon3.png')

gl.mosaic("S 22	43	61	-17	37	67 ; C 6 48	-60	12	48	-24;A 21 -9 33 21 30 -9; ");
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLA_thirds_stim_regionsFromCon2.png')


#############################################
# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 

#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("S -29 28	-20	-29	-8 34 16; C -30	-57	-93	9 -84 0 48; A 75 75 3 -33 60 -36 -12; ");

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0004\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.3, 1944,1)

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_A\\2Lv_GLM0_thirds_exMiss\con_0005\spmT_0001.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
gl.removesmallclusters(2, 3.3, 1458,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
#transparent? 
gl.opacity(1, 85)
gl.opacity(2, 85)

# position of color bar 
gl.colorbarposition(2)
gl.colorbarsize(0.03)
#save 
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLA_thirds_feedback_regionsFromCon5.png')

gl.mosaic("S 40	-41	40	37	43	55; C 45 -54 21	18 -51 -21;A 18 -45 42 -3 30 -9;");
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLA_thirds_feedback_regionsFromCon4.png')



# TASK B 
#############################################
# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 

#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("S 22	-5	-38	43	-8	-11	34	-14	13; C -93	-3	-30	-21	12	-84	24	0	0; A 0	48	51	42	-3	57	6	-9	3; ");

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_B\\2Lv_GLM0_thirds_exMiss\con_0002\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.32, 2268,1)

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_B\\2Lv_GLM0_thirds_exMiss\con_0003\spmT_0001.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
gl.removesmallclusters(2, 3.32, 1809,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
#transparent? 
gl.opacity(1, 85)
gl.opacity(2, 85)

# position of color bar 
gl.colorbarposition(2)
gl.colorbarsize(0.03)
#save 
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLB_thirds_stim.png')


#############################################
# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 

#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("S 19 -17; C -90 -90;A -3 0; ");

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_B\\2Lv_GLM0_thirds_exMiss\con_0004\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.3190, 2268,1)

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel\FBL_B\\2Lv_GLM0_thirds_exMiss\con_0005\spmT_0001.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
gl.removesmallclusters(2, 3.3190, 2268,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
#transparent? 
gl.opacity(1, 85)
gl.opacity(2, 85)

# position of color bar 
gl.colorbarposition(2)
gl.colorbarsize(0.03)
#save 
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLB_thirds_feedback.png')


