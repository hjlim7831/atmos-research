load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

f1 = addfile("gahf_d01.nc", "r")   ; domain 
f2 = addfile("gahf_d02.nc", "r")   ; domain 
f3 = addfile("gahf_d03.nc", "r")   ; domain 
f4 = addfile("gahf_d04.nc", "r")   ; domain 
of = addfile("GAHF_seoul_yr_d01.nc.nc", "r")   ; domain 

gahf1 = f1->GAHF
gahf2 = f2->GAHF
gahf3 = f3->GAHF
gahf4 = f4->GAHF
orig_gahf = of->GAHF_JUN
Times = f1->Times

delete(gahf1@_FillValue)
delete(gahf2@_FillValue)
delete(gahf3@_FillValue)
delete(gahf4@_FillValue)

copy_VarAtts(orig_gahf,gahf1)
copy_VarAtts(orig_gahf,gahf2)
copy_VarAtts(orig_gahf,gahf3)
copy_VarAtts(orig_gahf,gahf4)

gahf1!0 = "Time"
gahf1!1 = "south_north"
gahf1!2 = "west_east"
gahf2!0 = "Time"
gahf2!1 = "south_north"
gahf2!2 = "west_east"
gahf3!0 = "Time"
gahf3!1 = "south_north"
gahf3!2 = "west_east"
gahf4!0 = "Time"
gahf4!1 = "south_north"
gahf4!2 = "west_east"

FiAtt1 = True
FiAtt2 = True
FiAtt3 = True
FiAtt4 = True
copy_VarMeta(f1, FiAtt1)
copy_VarMeta(f2, FiAtt2)
copy_VarMeta(f3, FiAtt3)
copy_VarMeta(f4, FiAtt4)

FiAtt1@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt2@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt3@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt4@TITLE = "Hourly anthropogenic heat flux for Seoul"

setfileoption("nc","Format","LargeFile")
diro = "./"
filo1 = "new_gahf_d01.nc"
filo2 = "new_gahf_d02.nc"
filo3 = "new_gahf_d03.nc"
filo4 = "new_gahf_d04.nc"
system("/bin/rm -f "+diro+filo1)
system("/bin/rm -f "+diro+filo2)
system("/bin/rm -f "+diro+filo3)
system("/bin/rm -f "+diro+filo4)

fout1 = addfile(diro+filo1, "c" )
fout2 = addfile(diro+filo2, "c" )
fout3 = addfile(diro+filo3, "c" )
fout4 = addfile(diro+filo4, "c" )
fileattdef(fout1, FiAtt1)
fileattdef(fout2, FiAtt2)
fileattdef(fout3, FiAtt3)
fileattdef(fout4, FiAtt4)

fout1->GAHF = gahf1(0:89,:,:)
fout1->Times = Times(0:89,:)
fout2->GAHF = gahf2(0:89,:,:)
fout2->Times = Times(0:89,:)
fout3->GAHF = gahf3(0:89,:,:)
fout3->Times = Times(0:89,:)
fout4->GAHF = gahf4(0:89,:,:)
fout4->Times = Times(0:89,:)

end
