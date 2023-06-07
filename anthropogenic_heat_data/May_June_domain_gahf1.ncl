load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

f = addfile("./original_heat_data/GAHF_seoul_yr_d01.nc", "r")   ; domain 4, 5    change
of = addfile("./original_heat_data/GAHF_seoul_yr_d01.nc", "r") ; for the attributes    change

orig_gahf = of->GAHF_JUL ;don't matter

ii = addfile("./wrfinput_d01", "r")      ;   change

ldm = 31
start_day = 30
end_day = start_day + 2

dimtimes = 54
;;; total anthropogenic heat data time in hour

GAHF1 = f->GAHF_MAY*1.
GAHF2 = f->GAHF_JUN*1.

dimdata = 1
start_time = 12

makeNew = 1	
if (makeNew.eq.1) then
;; ------------------------------------------------
 g = addfile ("./geo_em.d01.nc","r")    ;  change (for CLAT, CLONG)

 xlatd = f->XLAT(:,:)
 xlond = f->XLON(:,:)     ; AH file

 glatd = g->CLAT(0,:,:)
 glond = g->CLONG(0,:,:)   ; geo

dimx = dimsizes(glatd(0,:))
dimy = dimsizes(glatd(:,0))

beta1 = new((/4,dimy,dimx/),float,-9999)
orig_xy1 = new((/2,dimy,dimx/),integer,-9999)
tmp_xy1 = new((/2,dimy,dimx/),integer,-9999)

new_GAHF1 = new((/24,dimy,dimx/),float)
new_GAHF2 = new((/24,dimy,dimx/),float)

do i = 0, dimy-1
   do j = 0, dimx-1
      nm = getind_latlon2d (xlatd, xlond, glatd(i,j), glond(i,j))
      orig_xy1(1,i,j) = nm(0,1)   ;;; x ind.
      orig_xy1(0,i,j) = nm(0,0)   ;;; y ind.

      if ( nm(0,1) .eq. 0 .or. nm(0,0) .eq. 0 ) then
         beta1(:,i,j) = 0.
		 orig_xy1(:,i,j) = 0
		 tmp_xy1(:,i,j) = 0
      end if


	  if ( nm(0,1) .ne. 0 .and. nm(0,0) .ne. 0 ) then

      if ( xlatd(nm(0,0),nm(0,1)) - glatd(i,j) .ge. 0. ) then
         y1 = xlatd(nm(0,0),nm(0,1)) - glatd(i,j)
         y2 = glatd(i,j) - xlatd(nm(0,0)-1,nm(0,1))
         tmp_xy1(0,i,j) = nm(0,0) - 1
      end if

      if ( xlatd(nm(0,0),nm(0,1)) - glatd(i,j) .lt. 0. ) then
         if ( nm(0,0)+1 .ge. dimsizes(xlond(:,0)-1) ) then
            y2 = xlatd(nm(0,0),nm(0,1)) - glatd(i,j)
            y1 = glatd(i,j) - xlatd(nm(0,0),nm(0,1))
            tmp_xy1(0,i,j) = nm(0,0) 
         end if

         if ( nm(0,0)+1 .lt. dimsizes(xlond(:,0)-1) ) then
            y2 = xlatd(nm(0,0)+1,nm(0,1)) - glatd(i,j)
            y1 = glatd(i,j) - xlatd(nm(0,0),nm(0,1))
            tmp_xy1(0,i,j) = nm(0,0) + 1
         end if
      end if

      if ( xlond(nm(0,0),nm(0,1)) - glond(i,j) .ge. 0. ) then
         x1 = (xlond(nm(0,0),nm(0,1)) - glond(i,j))*cos(glatd(i,j)*3.141592/180.)
         x2 = (glond(i,j) - xlond(nm(0,0),nm(0,1)-1))*cos(glatd(i,j)*3.141592/180.)
         tmp_xy1(1,i,j) = nm(0,1) - 1
      end if

      if ( xlond(nm(0,0),nm(0,1)) - glond(i,j) .lt. 0. ) then
         if ( nm(0,1)+1 .ge. dimsizes(xlond(0,:)-1) ) then 
            x2 = (xlond(nm(0,0),nm(0,1)) - glond(i,j))*cos(glatd(i,j)*3.141592/180.)
            x1 = (glond(i,j) - xlond(nm(0,0),nm(0,1)))*cos(glatd(i,j)*3.141592/180.)
            tmp_xy1(1,i,j) = nm(0,1)
         end if

         if ( nm(0,1)+1 .lt. dimsizes(xlond(0,:)-1) ) then 
            x2 = (xlond(nm(0,0),nm(0,1)+1) - glond(i,j))*cos(glatd(i,j)*3.141592/180.)
            x1 = (glond(i,j) - xlond(nm(0,0),nm(0,1)))*cos(glatd(i,j)*3.141592/180.)
            tmp_xy1(1,i,j) = nm(0,1) + 1
         end if
      end if

      dis1 = sqrt(x1^2.+y1^2.)
      dis2 = sqrt(x1^2.+y2^2.)
      dis3 = sqrt(x2^2.+y1^2.)
      dis4 = sqrt(x2^2.+y2^2.)

      alp1 = dis2*dis3*dis4
      alp2 = dis1*dis3*dis4
      alp3 = dis1*dis2*dis4
      alp4 = dis1*dis2*dis3
      numalp = alp1+alp2+alp3+alp4

      beta1(0,i,j) = alp1/numalp
      beta1(1,i,j) = alp2/numalp
      beta1(2,i,j) = alp3/numalp
      beta1(3,i,j) = alp4/numalp

      end if
   end do
end do

;No Gahf input


do j = 0, dimy-1
   do k = 0, dimx-1
      new_GAHF1(:,j,k) = GAHF1(:,orig_xy1(0,j,k),orig_xy1(1,j,k))*beta1(0,j,k) + \
                         GAHF1(:,orig_xy1(0,j,k),tmp_xy1(1,j,k))*beta1(1,j,k) + \
                         GAHF1(:,tmp_xy1(0,j,k),orig_xy1(1,j,k))*beta1(2,j,k) + \
                         GAHF1(:,tmp_xy1(0,j,k),tmp_xy1(1,j,k))*beta1(3,j,k)
      new_GAHF2(:,j,k) = GAHF2(:,orig_xy1(0,j,k),orig_xy1(1,j,k))*beta1(0,j,k) + \
                         GAHF2(:,orig_xy1(0,j,k),tmp_xy1(1,j,k))*beta1(1,j,k) + \
                         GAHF2(:,tmp_xy1(0,j,k),orig_xy1(1,j,k))*beta1(2,j,k) + \
                         GAHF2(:,tmp_xy1(0,j,k),tmp_xy1(1,j,k))*beta1(3,j,k)
   end do
end do

end if

;I have new_GAHF1, new_GAHF2
;cl
GAHF_d01 = new((/dimtimes,dimy,dimx/),float)
Times = new((/dimtimes,19/),character)

delete(GAHF_d01@_FillValue)
GAHF_d01@coordinates = "XLONG XLAT"

 do i= start_time, dimtimes+start_time-1
  s = "2010-08-88_99:00:00"
  if (i .lt. 24) then
   s = str_sub_str(s, "88", "01")
   s = str_sub_str(s, "99", sprinti("%0.2i",i))
   else if (i .lt. 48) then
    s = str_sub_str(s, "88", "02")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-24))
   else if (i .lt. 72) then
    s = str_sub_str(s, "88", "03")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-48))
   else if (i .lt. 96) then
    s = str_sub_str(s, "88", "04")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-72))
   else if (i .lt. 120) then
    s = str_sub_str(s, "88", "05")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-96))
   else if (i .lt. 144) then
    s = str_sub_str(s, "88", "06")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-120))
   else if (i .lt. 168) then
    s = str_sub_str(s, "88", "07")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-144))
   else if (i .lt. 192) then
    s = str_sub_str(s, "88", "08")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-168))
   else if (i .lt. 216) then
    s = str_sub_str(s, "88", "09")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-192))
   else if (i .lt. 240) then
    s = str_sub_str(s, "88", "10")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-216))
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
  end if
  ch = stringtochar(s)
  Times(i-start_time,:) = ch(0:18)
 end do

Times!0 = "Time"
Times!1 = "DateStrLen"

FiAtt1 = True
copy_VarMeta(ii, FiAtt1)

FiAtt1@TITLE = "Hourly anthropogenic heat flux for Seoul"


fact = (ldm-start_day)*24 + 24 - start_time

; start_time ~ start_time + dimtimes -1 , if i .ge. fact -> August


if( start_time .ne. 0 ) then

	head = 24-start_time
	rest = mod(dimtimes-(24-head),24)
	quot = floattoint((dimtimes-head-rest)/24.) ; total days
	PAR1 = ldm - (start_day + 1); if this is greater than 0, you have to put in new_GAHF1 data
	PAR2 = end_day - ldm ; if month changes, quot1 > 0
	quot1 = end_day - (start_day + 1)

	GAHF_d01(0:23-start_time,:,:) = new_GAHF1(start_time:23,:,:)  ;; put head data in GAHF_d01
	if (quot .gt. 0) then
		if (PAR2  .gt. 0) then
			do i = 0, quot1 -1
				GAHF_d01(23-start_time+1+i*24:23-start_time+1+(i+1)*24-1,:,:) = new_GAHF1
			end do
			do i = quot1, quot -1
				GAHF_d01(23-start_time+1+i*24:23-start_time+1+(i+1)*24-1,:,:) = new_GAHF2
			end do
			GAHF_d01(23-start_time+1+24*quot:23-start_time+1+24*quot+rest-1,:,:) = new_GAHF2(0:rest-1,:,:)
		end if
		if (PAR1 .gt. 0) then
			do i = 0, quot -1
				GAHF_d01(23-start_time+1+i*24:23-start_time+1+(i+1)*24-1,:,:) = new_GAHF1
			end do
			GAHF_d01(23-start_time+1+24*quot:23-start_time+1+24*quot+rest-1,:,:) = new_GAHF1(0:rest-1,:,:)
		end if
	end if
	if (quot .eq. 0) then
	   GAHF_d01(23-start_time+1:23-start_time+1+rest-1,:,:) = new_GAHF1(0:rest-1,:,:)
	end if
end if

if ( start_time .eq. 0 ) then

rest = mod(dimtimes,24)
quot = floattoint((dimtimes-rest)/24.)

	do i = 0, quot-1
	   GAHF_d01(i*24:(i+1)*24-1,:,:) = new_GAHF1
	end do

	if ( rest .ne. 0 ) then
	   GAHF_d01(quot*24:quot*24+rest-1,:,:) = new_GAHF1(0:rest-1,:,:)
	end if

end if

copy_VarAtts(orig_gahf,GAHF_d01) ;from orig_gahf, to GAHF_d01

GAHF_d01!0 = "Time"
GAHF_d01!1 = "south_north"
GAHF_d01!2 = "west_east"

setfileoption("nc","Format","LargeFile")
diro = "./"
filo1 = "gahf_d01_20180530.nc"    ; change
system("/bin/rm -f "+diro+filo1)

fout1 = addfile(diro+filo1, "c" )
fileattdef(fout1, FiAtt1)

fout1->GAHF = GAHF_d01
fout1->Times = Times

do i = 0, dimtimes-1
print(" "+Times(i,0)+Times(i,1)+Times(i,2)+Times(i,3)+Times(i,4)+Times(i,5)+Times(i,6)+Times(i,7)+Times(i,8)+Times(i,9)+Times(i,10)+Times(i,11)+Times(i,12)+Times(i,13)+Times(i,14)+Times(i,15)+Times(i,16)+Times(i,17)+Times(i,18))
end do

end
