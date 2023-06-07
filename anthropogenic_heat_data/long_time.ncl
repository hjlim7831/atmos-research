load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

f1 = addfile("gahf_d01.nc", "r")   ; domain 
f2 = addfile("gahf_d02.nc", "r")   ; domain 
f3 = addfile("gahf_d03.nc", "r")   ; domain 
;f4 = addfile("gahf_d04.nc", "r")   ; domain 
of = addfile("GAHF_seoul_yr_d01.nc.nc", "r")   ; domain 

ii1 = addfile("./wrfinput_d01", "r")
ii2 = addfile("./wrfinput_d02", "r")
ii3 = addfile("./wrfinput_d03", "r")
;ii4 = addfile("./wrfinput_d04", "r")

gahf1 = f1->GAHF
gahf2 = f2->GAHF
gahf3 = f3->GAHF
;gahf4 = f4->GAHF
orig_gahf = of->GAHF_JUN
Times = f1->Times


dimtimes = 786
dimx1 = dimsizes(gahf1(0,0,:))
dimy1 = dimsizes(gahf1(0,:,0))
dimx2 = dimsizes(gahf2(0,0,:))
dimy2 = dimsizes(gahf2(0,:,0))
dimx3 = dimsizes(gahf3(0,0,:))
dimy3 = dimsizes(gahf3(0,:,0))
;dimx4 = dimsizes(gahf4(0,0,:))
;dimy4 = dimsizes(gahf4(0,:,0))

new_gahf1 = new((/dimtimes,dimy1,dimx1/),float)
new_gahf2 = new((/dimtimes,dimy2,dimx2/),float)
new_gahf3 = new((/dimtimes,dimy3,dimx3/),float)
;new_gahf4 = new((/dimtimes,dimy4,dimx4/),float)
new_times = new((/dimtimes,19/),character)

tmp_dim = (dimtimes-mod(dimtimes,24))/24+1

do i = 0, dimtimes-1
   s = "2010-77-88_99:00:00"
   tmp_dim1 = i/24
   tmp_dim2 = i-tmp_dim1*24
   if ( tmp_dim1 .lt. 3 ) then
       s = str_sub_str(s, "77", "05")
       tmp_dim3 = tmp_dim1+29 
       s = str_sub_str(s, "88", sprinti("%0.2i",tmp_dim3))
       s = str_sub_str(s, "99", sprinti("%0.2i",tmp_dim2))
   end if

   if ( tmp_dim1 .ge. 3 ) then
       s = str_sub_str(s, "77", "06")
       tmp_dim3 = tmp_dim1-2
       s = str_sub_str(s, "88", sprinti("%0.2i",tmp_dim3))
       s = str_sub_str(s, "99", sprinti("%0.2i",tmp_dim2))
   end if
   ch = stringtochar(s)
   new_times(i,:) = ch(0:18)
end do

new_times!0 = "Time"
new_times!1 = "DateStrLen"

rest = mod(dimtimes,24)
quot = floattoint((dimtimes-rest)/24.)

do i = 0, quot-1
   new_gahf1(i*24:(i+1)*24-1,:,:) = gahf1(0:23,:,:)
   new_gahf2(i*24:(i+1)*24-1,:,:) = gahf2(0:23,:,:)
   new_gahf3(i*24:(i+1)*24-1,:,:) = gahf3(0:23,:,:)
;   new_gahf4(i*24:(i+1)*24-1,:,:) = gahf4(0:23,:,:)
end do

if ( rest .ne. 0 ) then
   new_gahf1(quot*24:quot*24+rest-1,:,:) = gahf1(0:rest-1,:,:)
   new_gahf2(quot*24:quot*24+rest-1,:,:) = gahf2(0:rest-1,:,:)
   new_gahf3(quot*24:quot*24+rest-1,:,:) = gahf3(0:rest-1,:,:)
;   new_gahf4(quot*24:quot*24+rest-1,:,:) = gahf4(0:rest-1,:,:)
end if

delete(new_gahf1@_FillValue)
delete(new_gahf2@_FillValue)
delete(new_gahf3@_FillValue)
;delete(new_gahf4@_FillValue)

copy_VarAtts(orig_gahf,new_gahf1)
copy_VarAtts(orig_gahf,new_gahf2)
copy_VarAtts(orig_gahf,new_gahf3)
;copy_VarAtts(orig_gahf,new_gahf4)

new_gahf1!0 = "Time"
new_gahf1!1 = "south_north"
new_gahf1!2 = "west_east"
new_gahf2!0 = "Time"
new_gahf2!1 = "south_north"
new_gahf2!2 = "west_east"
new_gahf3!0 = "Time"
new_gahf3!1 = "south_north"
new_gahf3!2 = "west_east"
;new_gahf4!0 = "Time"
;new_gahf4!1 = "south_north"
;new_gahf4!2 = "west_east"

FiAtt1 = True
FiAtt2 = True
FiAtt3 = True
;FiAtt4 = True
copy_VarMeta(ii1, FiAtt1)
copy_VarMeta(ii2, FiAtt2)
copy_VarMeta(ii3, FiAtt3)
;copy_VarMeta(ii4, FiAtt4)

FiAtt1@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt2@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt3@TITLE = "Hourly anthropogenic heat flux for Seoul"
;FiAtt4@TITLE = "Hourly anthropogenic heat flux for Seoul"

setfileoption("nc","Format","LargeFile")
diro = "./"
filo1 = "one_month_gahf_d01.nc"
filo2 = "one_month_gahf_d02.nc"
filo3 = "one_month_gahf_d03.nc"
;filo4 = "one_month_gahf_d04.nc"
system("/bin/rm -f "+diro+filo1)
system("/bin/rm -f "+diro+filo2)
system("/bin/rm -f "+diro+filo3)
;system("/bin/rm -f "+diro+filo4)

fout1 = addfile(diro+filo1, "c" )
fout2 = addfile(diro+filo2, "c" )
fout3 = addfile(diro+filo3, "c" )
;fout4 = addfile(diro+filo4, "c" )
fileattdef(fout1, FiAtt1)
fileattdef(fout2, FiAtt2)
fileattdef(fout3, FiAtt3)
;fileattdef(fout4, FiAtt4)

fout1->GAHF = new_gahf1(:,:,:)
fout1->Times = new_times(:,:)
fout2->GAHF = new_gahf2(:,:,:)
fout2->Times = new_times(:,:)
fout3->GAHF = new_gahf3(:,:,:)
fout3->Times = new_times(:,:)
;fout4->GAHF = new_gahf4(:,:,:)
;fout4->Times = new_times(:,:)

end
