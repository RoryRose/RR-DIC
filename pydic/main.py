#!/usr/bin/env python
# -*- coding: utf-8 -*-

#####Modified from pydic by Phani Karamched, Universtity of Oxford
################NOTES###############################################
####Rewritten and corrected all equations from 
###Applications of Digital-Image-Correlation techniques to experimental mechanics
###Chu, Ranson, Sutton and Peters, Experimental Mechanics 1985
#strain_xx[i,j] = du_dx + .5*(du_dx**2 + dv_dx**2)
#strain_yy[i,j] = dv_dy + .5*(du_dy**2 + dv_dy**2)
#strain_xy[i,j] = .5*(du_dy + dv_dx + du_dx*du_dy + dv_dx*dv_dy)
#rotation_xy[i,j] = .5*(dv_dx - du_dy)
#This rotation equation assumes rigid body, hence might work for about 10deg or so only.
####################################################################

# ====== IMPORTING MODULES
from matplotlib import pyplot as plt
import numpy as np
from scipy import stats
import os
import cv2

# locate the pydic module and import it
import imp
pydic = imp.load_source('pydic', './pydic.py')


#  ====== RUN PYDIC TO COMPUTE DISPLACEMENT AND STRAIN FIELDS (STRUCTURED GRID)
correl_wind_size = (32,32) # the size in pixel of the correlation windows
correl_grid_size = (15,15) # the size in pixel of the interval (dx,dy) of the correlation grid


# read image series and write a separated result file 
pydic.init('Z:/RR/DIC/Example from Phani/pre-test calibration/XY disp/*.tif', correl_wind_size, correl_grid_size, "result.dic")


# and read the result file for computing strain and displacement field from the result file 
pydic.read_dic_file('result.dic', interpolation='cubic', save_image=True, scale_disp=1, scale_grid=1)
#pydic.read_dic_file('result.dic', interpolation='cubic', save_image=True, scale_disp=1, scale_grid=1)

#  ====== OR RUN PYDIC TO COMPUTE DISPLACEMENT AND STRAIN FIELDS (WITH UNSTRUCTURED GRID OPTION)
# note that you can't use the 'spline' or the 'raw' interpolation with unstructured grids 
# please uncomment the next lines if you want to use the unstructured grid options instead of the aligned grid
#pydic.init('C:/Users/shaz/Documents/DIC/20nov19_goldspeckletest/inlens/2kv/*.tif', correl_wind_size, correl_grid_size, "result.dic", unstructured_grid=(20,5))
#pydic.read_dic_file('result.dic', interpolation='raw', save_image=True, scale_disp=1, scale_grid=1)
#pydic.read_dic_file('result.dic', interpolation='cubic', save_image=True, scale_disp=1, scale_grid=1)


#  ====== RESULTS
# Now you can go in the 'img/pydic' directory to see the results :
# - the 'disp', 'grid' and 'marker' directories contain image files
# - the 'result' directory contain raw text csv file where displacement and strain fields are written  



# ======= STANDARD POST-TREATMENT : STRAIN FIELD MAP PLOTTING
# the pydic.grid_list is a list that contains all the correlated grids (one per image)
# the grid objects are the main objects of pydic  


last_grid = pydic.grid_list[-1]
last_grid.plot_field(last_grid.strain_xx, 'xx strain')
last_grid.plot_field(last_grid.strain_xy, 'xy strain')
last_grid.plot_field(last_grid.strain_yy, 'yy strain')
last_grid.plot_field(last_grid.rotation_xy,'xy rotation')

plt.show()



# enjoy !

