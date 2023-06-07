load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

;f1 = addfile("./old_gahf/0802_gahf/0802_gahf_d01.nc", "r")   ; domain 
f1 = addfile("./0123/wrf_input/gahf_d01_0123-0124.nc","r")
gahf1 = f1->GAHF
time_former = f1->Times
print(time_former(:,:))

end
