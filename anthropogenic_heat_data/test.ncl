load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

f1 = addfile("jun_sec_gahf_d01.nc", "r")   ; domain 
f2 = addfile("jun_sec_gahf_d02.nc", "r")   ; domain 
f3 = addfile("jun_sec_gahf_d03.nc", "r")   ; domain 
f4 = addfile("jun_sec_gahf_d04.nc", "r")   ; domain 
f5 = addfile("jun_sec_gahf_d05.nc", "r")   ; domain 
of = addfile("GAHF_seoul_yr_d01.nc.nc", "r")   ; domain 

gahf1 = f1->GAHF
gahf2 = f2->GAHF
gahf3 = f3->GAHF
gahf4 = f4->GAHF
orig_gahf = of->GAHF_JUN
Times1 = f1->Times
Times2 = f2->Times
Times3 = f3->Times
Times4 = f4->Times
Times5 = f5->Times

print(Times1(0,:))
print(Times2(0,:))
print(Times3(0,:))
print(Times4(0,:))
print(Times5(0,:))

end
