load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

;f1 = addfile("./old_gahf/0802_gahf/0802_gahf_d01.nc", "r")   ; domain 
f1 = addfile("./0717_gahf/gahf_d01_0717.nc","r")
gahf1 = f1->GAHF
time_former = f1->Times
print(time_former(:,:))

end
