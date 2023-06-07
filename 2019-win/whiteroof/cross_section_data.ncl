load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

start_write_time = get_cpu_time()
setfileoption("nc","preFill",False)
setfileoption("nc","defineMode",True)
;setfileoption("nc","Format","LargeFile")
setfileoption("nc","Format","NetCDF4Classic")

fout_name1 = "CrossSectionData.nc"
fout_name2 = "CrossSectionDataDiur.nc"
system("rm -f " + fout_name1)

fout1 = addfile(fout_name1,"c")

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

dimt = dimsizes(var4d(:,0,0,0))
dimy = dimsizes(var4d(0,0,:,0))
dimx = dimsizes(var4d(0,0,0,:))
dimz = dimsizes(var4d(0,:,0,0))

if ii .eq. 0 then
	dims = dimsizes(var4d)
	dim_names = getvardims(var4d)
	filedimdef(fout1,dim_names,dims,dim_unlimited)
end if

printVarSummary(var4d)
dum1 = var4dname(ii)+"2"
filevardef(fout1,dum1,typeof(var4d),dim_names)

filevarattdef(fout1,dum1,var4d)

fout1->$dum1$ = var4d

delete([/var4d/])

end do

do ii = 0, dv4d -1
	print(ii)
var4d = wrf_user_getvar(a2,var4dname(ii),-1)

dimy = dimsizes(var4d(0,0,:,0))
dimx = dimsizes(var4d(0,0,0,:))
dimz = dimsizes(var4d(0,:,0,0))
/;
dims = dimsizes(var4d)
dim_names = getvardims(var4d)
filedimdef(fout1,dim_names,dims,dim_unlimited)
;/
dum3 = var4dname(ii)+"7"
filevardef(fout1,dum3,typeof(var4d),dim_names)

filevarattdef(fout1,dum3,var4d)

fout1->$dum3$ = var4d

delete([/var4d/])

end do

end
