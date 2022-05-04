# load basics

import gl
gl.resetdefaults()
gl.loadimage('spm152')
gl.backcolor(255,255,255) 


#selected slides based on coordinates from SPM (Saggital, coronal and Axial planes with x , y z coordinates respectively
gl.mosaic("S -20 16 -53 -50 10 46 -29 -53 52 -2 43; \
	C -81 48 -54 29 -66 27 -60 12 12 24 24; \
	A 48 -15 -18 36 6 36 33 24 27 42 -6")\
#gl.mosaic("S -20 52	16 -53 64 28 -26 49 -14 -50 -26 10 46 46 10; \
#	C -81-48 48 -54 -42 -15 18 -21 -63 18 -9 -66 -39 27 -9; \
#	A 48 15 -15 -18 -21 3 3 39 -36 36 0 6 36 36 42")\

# Load layers (escape character '\' used to avoid error reading path
gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel_pairedTs\\2Lv_GLM0_thirds_exMiss\con_0008\spmT_0002.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"5winter")
gl.removesmallclusters(1, 3.32,1431, 1) # Cluster correction (layernumber, Tvalue, 3*voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))

gl.overlayload('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\2ndLevel_pairedTs\\2Lv_GLM0_thirds_exMiss\con_0009\spmT_0002.nii')
gl.minmax(2, 0, 8)
gl.colorname(2,"4hot")
gl.removesmallclusters(2, 3.32, 1647,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))
#transparent? 
gl.opacity(1, 85)
gl.opacity(2, 85)

# position of color bar 
gl.colorbarposition(3)
gl.colorbarsize(0.03)

#Save 
gl.savebmp('O:\studies\grapholemo\\analysis\LEMO_GFG\mri\\visualizations_mricrogl\MRICROGL_FBLBminusA_fb_thirds.png')
