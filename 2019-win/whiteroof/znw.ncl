begin

diri = "~/2019-win/whiteroof/model/ERA5/wrf_out_alb0.2/"
diri2 = "~/2019-win/test_model/wrf_input/"
fili = "wrfout_d03_2018-07-14_12:00:00"
fili2 = "wrfinput_d03"

a1 = addfile(diri+fili,"r")
a2 = addfile(diri2+fili2,"r")

znw = a1->ZNW(0,:)
znw2 = a2->ZNW(0,:)

print(znw)
print(znw2)






end
