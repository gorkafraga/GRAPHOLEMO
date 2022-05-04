 
# Template
#-------------------------------------------------------------------
# load basics
import gl
gl.resetdefaults()
gl.loadimage('spm152') 
gl.backcolor(255,255,255) 

# Selected slides SPM (Saggital, coronal and Axial are  x, y z coordinates  
gl.mosaic("S -17 31 37 7 40 -38 13 ; C -90 3 -6 -6 -36 15 12;A -3 -36 12 54 72 24 -9; ");

# Load (escape character '\' used to avoid error reading path
#1
gl.overlayload('xxxxxxx\spmT_0001.nii')
gl.minmax(1, 0, 8)
gl.colorname(1,"1red")
gl.removesmallclusters(1, 3.327, 1836,1) # Cluster correction (layernumber, Tvalue, voxelsixe*number of voxels, then option: 1=faces(6),2=faces+edges(18),3=faces+edges+corners(26))


# Opacity
gl.opacity(1, 95)

# Position
gl.colorbarposition(2)
gl.colorbarsize(0.03)

#save 
gl.savebmp('XXXX\myoutputimage.png')
