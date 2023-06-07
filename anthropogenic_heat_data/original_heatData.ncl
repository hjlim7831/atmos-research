load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

f1 = addfile("GAHF_seoul_yr_d02.nc", "r")
f2 = addfile("GAHF_seoul_yr_d04.nc", "r")

ii1 = addfile("./wrfinput_d01", "r")
ii2 = addfile("./wrfinput_d03", "r")

dimtimes = 120
;;; in hour

GAHF1 = f1->GAHF_JUN
GAHF2 = f2->GAHF_JUN
makeNew = 0	;1-make smaller domain data
if (makeNew.eq.1) then
;; ------------------------------------------------
 g1 = addfile ("./geo_em.d01.nc","r")
 g2 = addfile ("./geo_em.d02.nc","r")
 g3 = addfile ("./geo_em.d03.nc","r")
 g4 = addfile ("./geo_em.d04.nc","r")

 xlatd3 = f1->XLAT(:,:)
 xlond3 = f1->XLON(:,:)
 xlatd4 = f2->XLAT(:,:)
 xlond4 = f2->XLON(:,:)

 glatd1 = g1->CLAT(0,:,:)
 glond1 = g1->CLONG(0,:,:)
 glatd2 = g2->CLAT(0,:,:)
 glond2 = g2->CLONG(0,:,:)
 glatd3 = g3->CLAT(0,:,:)
 glond3 = g3->CLONG(0,:,:)
 glatd4 = g4->CLAT(0,:,:)
 glond4 = g4->CLONG(0,:,:)

 dimlx3 = dimsizes(xlatd3)
 dimlx4 = dimsizes(xlatd4)
 dimlg1 = dimsizes(glatd3)
 dimlg2 = dimsizes(glatd4)
 dimlg3 = dimsizes(glatd3)
 dimlg4 = dimsizes(glatd4)

; gahf_sm3 = new((/dimtimes,dimlg3(0),dimlg3(1)/),float)
; gahf_sm4 = new((/dimtimes,dimlg4(0),dimlg4(1)/),float)

 lg3_loc = (/glatd3(0,0),glond3(0,0)/)
 print(lg3_loc)
 ll3 = getind_latlon2d(xlatd3,xlond3, glatd3(0,0),glond3(0,0))
 print(ll3+"")
 gahf_sm3 = GAHF1(:,ll3(0,0):ll3(0,0)+dimlg3(0),ll3(0,1):ll3(0,1)+dimlg3(1))

 print(" 444:   "+dimsizes(glatd4))
 ll4 = getind_latlon2d(xlatd4,xlond4, glatd4(0,0),glond4(0,0))
 print(ll4+"")
 gahf_sm4 = GAHF2(:,ll4(0,0):ll4(0,0)+dimlg4(0),ll4(0,1):ll4(0,1)+dimlg4(1))
 print(dimsizes(gahf_sm4))

 ;; ------------------------------------------------
 delete(GAHF1)
 delete(GAHF2)
 GAHF1 = gahf_sm3
 GAHF2 = gahf_sm4
end if

dimx1 = dimsizes(GAHF1(0,0,:))
dimy1 = dimsizes(GAHF1(0,:,0))
dimx2 = dimsizes(GAHF2(0,0,:))
dimy2 = dimsizes(GAHF2(0,:,0))

GAHF_d01 = new((/dimtimes,dimy1,dimx1/),float)
GAHF_d03 = new((/dimtimes,dimy2,dimx2/),float)
Times = new((/dimtimes,19/),character)

delete(GAHF_d01@_FillValue)
delete(GAHF_d03@_FillValue)
GAHF_d01@coordinates = "XLONG XLAT"
GAHF_d03@coordinates = "XLONG XLAT"

 do i= 0, dimtimes-1
  s = "2010-06-88_99:00:00"
  if (i .lt. 24) then
   s = str_sub_str(s, "88", "03")
   s = str_sub_str(s, "99", sprinti("%0.2i",i))
   else if (i .lt. 48) then
    s = str_sub_str(s, "88", "04")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-24))
   else if (i .lt. 72) then
    s = str_sub_str(s, "88", "05")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-48))
   else if (i .lt. 96) then
    s = str_sub_str(s, "88", "06")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-72))
   else if (i .lt. 120) then
    s = str_sub_str(s, "88", "07")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-96))
;   else
;    s = str_sub_str(s, "88", "07")
;    s = str_sub_str(s, "99", sprinti("%0.2i",i-120))
   end if
   end if
   end if
   end if
  end if
  ch = stringtochar(s)
  Times(i,:) = ch(0:18)
 end do

Times!0 = "Time"
Times!1 = "DateStrLen"

FiAtt1 = True
FiAtt2 = True
copy_VarMeta(ii1, FiAtt1)
copy_VarMeta(ii2, FiAtt2)

FiAtt1@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt2@TITLE = "Hourly anthropogenic heat flux for Seoul"

rest = mod(dimtimes,24)
quot = floattoint((dimtimes-rest)/24.)

do i = 0, quot-1
   GAHF_d01(i*24:(i+1)*24-1,:,:) = GAHF1
   GAHF_d03(i*24:(i+1)*24-1,:,:) = GAHF2
end do

if ( rest .ne. 0 ) then
   GAHF_d01(quot*24:quot*24+rest-1) = GAHF1(0:rest-1,:,:)
   GAHF_d03(quot*24:quot*24+rest-1) = GAHF2(0:rest-1,:,:)
end if

setfileoption("nc","Format","LargeFile")
diro = "./"
filo1 = "gahf_d01.nc"
filo2 = "gahf_d03.nc"
system("/bin/rm -f "+diro+filo1)
system("/bin/rm -f "+diro+filo2)

fout1 = addfile(diro+filo1, "c" )
fout2 = addfile(diro+filo2, "c" )
fileattdef(fout1, FiAtt1)
fileattdef(fout2, FiAtt2)

fout1->GAHF = GAHF_d01
fout1->Times = Times
fout2->GAHF = GAHF_d03
fout2->Times = Times

do i = 0, dimtimes-1
print(" "+Times(i,0)+Times(i,1)+Times(i,2)+Times(i,3)+Times(i,4)+Times(i,5)+Times(i,6)+Times(i,7)+Times(i,8)+Times(i,9)+Times(i,10)+Times(i,11)+Times(i,12)+Times(i,13)+Times(i,14)+Times(i,15)+Times(i,16)+Times(i,17)+Times(i,18))
end do

end
