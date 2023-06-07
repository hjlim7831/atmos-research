load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

start_write_time = get_cpu_time()

setfileoption("nc","preFill",False)
setfileoption("nc","defineMode",True)
setfileoption("nc","Format","LargeFile")

fout_name2 = "CrossSectionDataDiur.nc"
system("rm -f " + fout_name2)

fout2 = addfile(fout_name2,"c")

;-------input Data path
 dir = "./"
 fileA  = "e2wrfout_d03_2018-07-14_12:00:00" ; change here!
 fileB  = "e7wrfout_d03_2018-07-14_12:00:00" ; 

  a1 = addfile(dir+fileA,"r") ;Urban
  a2 = addfile(dir+fileB,"r") ;No-Urban


;-------time variables
 diur = 24

var4dname = (/"z","th","ua","va","wa"/)
dv4d = dimsizes(var4dname)

dim_unlimited = (/False,False,False,False/)

do ii = 0, dv4d -1
var4d = wrf_user_getvar(a1,var4dname(ii),-1)
print(ii)
dimy = dimsizes(var4d(0,0,:,0))
dimx = dimsizes(var4d(0,0,0,:))
dimz = dimsizes(var4d(0,:,0,0))

dum1 = var4dname(ii)+"2"

var_d = new((/diur,dimz,dimy,dimx/),float)
do i = 0, diur -1
	var_d(i,:,:,:) = dim_avg_n(var4d(i::diur,:,:,:),0)
end do

delete([/var4d/])

dims2 = dimsizes(var_d)
dim_names2 = getvardims(var_d)

dum2 = var4dname(ii)+"d2"

filedimdef(fout2,dim_names2,dims2,dim_unlimited)
filevardef(fout2,dum2,typeof(var_d),dim_names2)

filevarattdef(fout2,dum2,var_d)

fout2->$dum2$ = var4d

delete([/var_d/])

end do

do ii = 0, dv4d -1
	print(ii)
var4d = wrf_user_getvar(a2,var4dname(ii),-1)

dimy = dimsizes(var4d(0,0,:,0))
dimx = dimsizes(var4d(0,0,0,:))
dimz = dimsizes(var4d(0,:,0,0))

dims = dimsizes(var4d)
dim_names = getvardims(var4d)

dum3 = var4dname(ii)+"7"

var_d = new((/diur,dimz,dimy,dimx/),float)
do i = 0, diur -1
    var_d(i,:,:,:) = dim_avg_n(var4d(i::diur,:,:,:),0)
end do

delete([/var4d/])

dims2 = dimsizes(var_d)
dim_names2 = getvardims(var_d)

dum4 = var4dname(ii)+"d7"
filedimdef(fout2,dim_names2,dims2,dim_unlimited)
filevardef(fout2,dum4,typeof(var_d),dim_names2)

filevarattdef(fout2,dum4,var_d)

fout2->$dum4$ = var4d

delete([/var_d/])

end do

end
