import numpy as np
import Ngl, Nio
import os

f = Nio.open_file("geo_em.d03.nc","r")
var = f.variables["HGT_M"][0,:,:]
lat = f.variables["XLAT_M"][:]
lon = f.variables["XLONG_M"][:]

#typ = "png"
typ = "x11"

#-- start the graphics
wks = Ngl.open_wks(typ,os.path.basename(__file__).split('.')[0])

res						= Ngl.Resources()
res.nglFrame			= False
#res.sfXArray			= lon
#res.sfYArray			= lat

#res.mpFillOn			= True
plot = Ngl.contour_map(wks,var,res)


