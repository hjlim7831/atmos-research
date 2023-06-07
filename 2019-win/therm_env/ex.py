from matplotlib import font_manager as fm, rcParams
from matplotlib import rc
import matplotlib as mpl
import matplotlib.pyplot as plt
import os
import sys

xx = [1,2,3,4,5]
yy = [4,1,3,2,5]

print(mpl.__file__)
print(mpl.get_configdir())
print(mpl.get_cachedir())

#font_list = fm.findSystemFonts(fontpaths=None,fontext='ttf')
#print(font_list)
#aa = [(f.name, f.fname) for f in fm.fontManager.ttflist if 'Helvetica' in f.name]
#print(fm.fontManager.ttflist)


#fm.get_fontconfig_fonts()
#font_location = '/home/hjlim/archive/font/Helvetica.ttf'
#font_name = fm.FontProperties(fname=font_location).get_name()
#rc('font',**{'family':'sans-serif','sans-serif':['Helvetica']})
#font_location = '/home/hjlim/archive/font/Helvetica.ttf'
#fpath = os.path.join(rcParams["datapath"], font_location)
#prop = fm.FontProperties(fname=fpath)
#fname = os.path.split(fpath)[1]
#rcParams["font.family"] = "Helvetica"

font_dirs = ['/home/hjlim/archive/font/',]
font_files = fm.findSystemFonts(fontpaths=font_dirs)
font_list = fm.createFontList(font_files)
fm.fontManager.ttflist.extend(font_list)
rcParams['font.family'] = 'Helvetica'

#rc('font',family=font_name)
plt.plot(xx,yy)
plt.xlabel("x axis")
plt.ylabel("y axis")
plt.show()




