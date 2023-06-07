begin

sb = "em_seabreeze2d_x_3"
wrf = "WRF-4.1.3-3"

;fil = "main/sea_breeze/white_roof/"
;fil = "main/plain_surface/conv_roof/"
fil = "test/test5_per/"
system("mkdir "+fil+"option")
system("cp ~/"+wrf+"/WRF/test/"+sb+"/wrfinput* "+fil+"option/")
system("cp ~/"+wrf+"/WRF/test/"+sb+"/namelist.input "+fil+"option/")
system("cp ~/"+wrf+"/WRF/test/"+sb+"/input_sounding "+fil+"option/")
system("cp ~/"+wrf+"/WRF/dyn_em/module_initialize_ideal.F "+fil+"option/")
system("cp ~/"+wrf+"/WRF/run/URBPARM.TBL "+fil+"option/")

system("mv ~/"+wrf+"/WRF/test/"+sb+"/wrfout* "+fil)










end
