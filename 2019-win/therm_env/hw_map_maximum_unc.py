import Ngl
import os
import matplotlib.pyplot as plt
import numpy as np

#type = 'png'
type = 'x11'

wks = Ngl.open_wks(type,os.path.basename(__file__).split('.')[0])

res								= Ngl.Resources()
res.nglDraw						= False
res.nglFrame					= False

res.mpFillOn					= True
res.mpOutlineOn					= False
res.mpOceanFillColor			= "Transparent"
res.mpLandFillColor				= "Gray80"
res.mpInlandWaterFillColor 		= "Gray80"
res.mpGridAndLimbOn				= False
res.pmTickMarkDisplayMode		= "Always"

map = Ngl.map(wks,res)

pmres							= Ngl.Resources()
pmres.gsMarkerColor				= 



Ngl.draw(map)
Ngl.frame(wks)





