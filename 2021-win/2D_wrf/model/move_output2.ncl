begin

fil = "main/"
sb = "em_seabreeze2d_x"
wrf = "WRF-4.1.3-3"

if wrf .eq. "WRF-4.1.3-2" then
	fil = fil + "plain_surface/"
else
	fil = fil + "sea_breeze/"
end if

if sb .eq. "em_seabreeze2d_x" then
	fil = fil + "conv_roof/"
else
	fil = fil + "white_roof/"
end if


system("mkdir "+fil+"option")
system("cp ~/"+wrf+"/WRF/test/"+sb+"/wrfinput* "+fil+"option/")
system("cp ~/"+wrf+"/WRF/test/"+sb+"/namelist.input "+fil+"option/")
system("cp ~/"+wrf+"/WRF/test/"+sb+"/input_sounding "+fil+"option/")
system("cp ~/"+wrf+"/WRF/dyn_em/module_initialize_ideal.F "+fil+"option/")
system("cp ~/"+wrf+"/WRF/run/URBPARM.TBL "+fil+"option/")

system("mv ~/"+wrf+"/WRF/test/"+sb+"/wrfout* "+fil)










end
