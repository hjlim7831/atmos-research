load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

f1 = addfile("GAHF_seoul_yr_d01.nc", "r")   ; domain 1
f2 = addfile("GAHF_seoul_yr_d03.nc", "r")   ; domain 2, 3
f3 = addfile("GAHF_seoul_yr_d04.nc", "r")   ; domain 4, 5

ii1 = addfile("./wrfinput_d01", "r")
ii2 = addfile("./wrfinput_d02", "r")
ii3 = addfile("./wrfinput_d03", "r")
ii4 = addfile("./wrfinput_d04", "r")

dimtimes = 48
;;; total anthropogenic heat data time in hour

GAHF1 = f1->GAHF_JUN
GAHF2 = f2->GAHF_JUN
GAHF3 = f3->GAHF_JUN

dimdata = 4

makeNew = 1	;1-make smaller domain data
if (makeNew.eq.1) then
;; ------------------------------------------------
 g1 = addfile ("./geo_em.d01.nc","r")
 g2 = addfile ("./geo_em.d02.nc","r")
 g3 = addfile ("./geo_em.d03.nc","r")
 g4 = addfile ("./geo_em.d04.nc","r")

 xlatd1 = f1->XLAT(:,:)
 xlond1 = f1->XLON(:,:)
 xlatd2 = f2->XLAT(:,:)
 xlond2 = f2->XLON(:,:)
 xlatd3 = f3->XLAT(:,:)
 xlond3 = f3->XLON(:,:)     ; AH file

 glatd1 = g1->CLAT(0,:,:)
 glond1 = g1->CLONG(0,:,:)
 glatd2 = g2->CLAT(0,:,:)
 glond2 = g2->CLONG(0,:,:)
 glatd3 = g3->CLAT(0,:,:)
 glond3 = g3->CLONG(0,:,:)
 glatd4 = g4->CLAT(0,:,:)
 glond4 = g4->CLONG(0,:,:)   ; geo

dimx1 = dimsizes(glatd1(0,:))
dimy1 = dimsizes(glatd1(:,0))
dimx2 = dimsizes(glatd2(0,:))
dimy2 = dimsizes(glatd2(:,0))
dimx3 = dimsizes(glatd3(0,:))
dimy3 = dimsizes(glatd3(:,0))
dimx4 = dimsizes(glatd4(0,:))
dimy4 = dimsizes(glatd4(:,0))

beta1 = new((/dimdata,dimy1,dimx1/),float,-9999)
orig_xy1 = new((/2,dimy1,dimx1/),integer,-9999)
tmp_xy1 = new((/2,dimy1,dimx1/),integer,-9999)
beta2 = new((/dimdata,dimy2,dimx2/),float,-9999)
orig_xy2 = new((/2,dimy2,dimx2/),integer,-9999)
tmp_xy2 = new((/2,dimy2,dimx2/),integer,-9999)
beta3 = new((/dimdata,dimy3,dimx3/),float,-9999)
orig_xy3 = new((/2,dimy3,dimx3/),integer,-9999)
tmp_xy3 = new((/2,dimy3,dimx3/),integer,-9999)
beta4 = new((/dimdata,dimy4,dimx4/),float,-9999)
orig_xy4 = new((/2,dimy4,dimx4/),integer,-9999)
tmp_xy4 = new((/2,dimy4,dimx4/),integer,-9999)

new_GAHF1 = new((/24,dimy1,dimx1/),float)
new_GAHF2 = new((/24,dimy2,dimx2/),float)
new_GAHF3 = new((/24,dimy3,dimx3/),float)
new_GAHF4 = new((/24,dimy4,dimx4/),float)

do i = 0, dimy1-1
   do j = 0, dimx1-1
      nm = getind_latlon2d (xlatd1, xlond1, glatd1(i,j), glond1(i,j))
      orig_xy1(1,i,j) = nm(0,1)   ;;; x ind.
      orig_xy1(0,i,j) = nm(0,0)   ;;; y ind.

      if ( xlatd1(nm(0,0),nm(0,1)) - glatd1(i,j) .ge. 0. ) then
         y1 = xlatd1(nm(0,0),nm(0,1)) - glatd1(i,j)
         y2 = glatd1(i,j) - xlatd1(nm(0,0)-1,nm(0,1))
         tmp_xy1(0,i,j) = nm(0,0) - 1
      end if

      if ( xlatd1(nm(0,0),nm(0,1)) - glatd1(i,j) .lt. 0. ) then
         if ( nm(0,0)+1 .ge. dimsizes(xlond1(:,0)-1) ) then
            y2 = xlatd1(nm(0,0),nm(0,1)) - glatd1(i,j)
            y1 = glatd1(i,j) - xlatd1(nm(0,0),nm(0,1))
            tmp_xy1(0,i,j) = nm(0,0) 
         end if

         if ( nm(0,0)+1 .lt. dimsizes(xlond1(:,0)-1) ) then
            y2 = xlatd1(nm(0,0)+1,nm(0,1)) - glatd1(i,j)
            y1 = glatd1(i,j) - xlatd1(nm(0,0),nm(0,1))
            tmp_xy1(0,i,j) = nm(0,0) + 1
         end if
      end if

      if ( xlond1(nm(0,0),nm(0,1)) - glond1(i,j) .ge. 0. ) then
         x1 = (xlond1(nm(0,0),nm(0,1)) - glond1(i,j))*cos(glatd1(i,j)*3.141592/180.)
         x2 = (glond1(i,j) - xlond1(nm(0,0),nm(0,1)-1))*cos(glatd1(i,j)*3.141592/180.)
         tmp_xy1(1,i,j) = nm(0,1) - 1
      end if

      if ( xlond1(nm(0,0),nm(0,1)) - glond1(i,j) .lt. 0. ) then
         if ( nm(0,1)+1 .ge. dimsizes(xlond1(0,:)-1) ) then 
            x2 = (xlond1(nm(0,0),nm(0,1)) - glond1(i,j))*cos(glatd1(i,j)*3.141592/180.)
            x1 = (glond1(i,j) - xlond1(nm(0,0),nm(0,1)))*cos(glatd1(i,j)*3.141592/180.)
            tmp_xy1(1,i,j) = nm(0,1)
         end if

         if ( nm(0,1)+1 .lt. dimsizes(xlond1(0,:)-1) ) then 
            x2 = (xlond1(nm(0,0),nm(0,1)+1) - glond1(i,j))*cos(glatd1(i,j)*3.141592/180.)
            x1 = (glond1(i,j) - xlond1(nm(0,0),nm(0,1)))*cos(glatd1(i,j)*3.141592/180.)
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

   end do
end do


do j = 0, dimy1-1
   do k = 0, dimx1-1
      new_GAHF1(:,j,k) = GAHF1(:,orig_xy1(0,j,k),orig_xy1(1,j,k))*beta1(0,j,k) + \
                         GAHF1(:,orig_xy1(0,j,k),tmp_xy1(1,j,k))*beta1(1,j,k) + \
                         GAHF1(:,tmp_xy1(0,j,k),orig_xy1(1,j,k))*beta1(2,j,k) + \
                         GAHF1(:,tmp_xy1(0,j,k),tmp_xy1(1,j,k))*beta1(3,j,k)
   end do
end do

delete(nm)

do i = 0, dimy2-1
   do j = 0, dimx2-1
      nm = getind_latlon2d (xlatd2, xlond2, glatd2(i,j), glond2(i,j))
      orig_xy2(1,i,j) = nm(0,1)   ;;; x ind.
      orig_xy2(0,i,j) = nm(0,0)   ;;; y ind.

      if ( xlatd2(nm(0,0),nm(0,1)) - glatd2(i,j) .ge. 0. ) then
         y1 = xlatd2(nm(0,0),nm(0,1)) - glatd2(i,j)
         y2 = glatd2(i,j) - xlatd2(nm(0,0)-1,nm(0,1))
         tmp_xy2(0,i,j) = nm(0,0) - 1
      end if

      if ( xlatd2(nm(0,0),nm(0,1)) - glatd2(i,j) .lt. 0. ) then
         if ( nm(0,0)+1 .ge. dimsizes(xlond2(:,0)-1) ) then
            y2 = xlatd2(nm(0,0),nm(0,1)) - glatd2(i,j)
            y1 = glatd2(i,j) - xlatd2(nm(0,0),nm(0,1))
            tmp_xy2(0,i,j) = nm(0,0) 
         end if

         if ( nm(0,0)+1 .lt. dimsizes(xlond2(:,0)-1) ) then
            y2 = xlatd2(nm(0,0)+1,nm(0,1)) - glatd2(i,j)
            y1 = glatd2(i,j) - xlatd2(nm(0,0),nm(0,1))
            tmp_xy2(0,i,j) = nm(0,0) + 1
         end if
      end if

      if ( xlond2(nm(0,0),nm(0,1)) - glond2(i,j) .ge. 0. ) then
         x1 = (xlond2(nm(0,0),nm(0,1)) - glond2(i,j))*cos(glatd2(i,j)*3.141592/180.)
         x2 = (glond2(i,j) - xlond2(nm(0,0),nm(0,1)-1))*cos(glatd2(i,j)*3.141592/180.)
         tmp_xy2(1,i,j) = nm(0,1) - 1
      end if

      if ( xlond2(nm(0,0),nm(0,1)) - glond2(i,j) .lt. 0. ) then
         if ( nm(0,1)+1 .ge. dimsizes(xlond2(0,:)-1) ) then
            x2 = (xlond2(nm(0,0),nm(0,1)) - glond2(i,j))*cos(glatd2(i,j)*3.141592/180.)
            x1 = (glond2(i,j) - xlond2(nm(0,0),nm(0,1)))*cos(glatd2(i,j)*3.141592/180.)
            tmp_xy2(1,i,j) = nm(0,1) 
         end if

         if ( nm(0,1)+1 .lt. dimsizes(xlond2(0,:)-1) ) then
            x2 = (xlond2(nm(0,0),nm(0,1)+1) - glond2(i,j))*cos(glatd2(i,j)*3.141592/180.)
            x1 = (glond2(i,j) - xlond2(nm(0,0),nm(0,1)))*cos(glatd2(i,j)*3.141592/180.)
            tmp_xy2(1,i,j) = nm(0,1) + 1
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

      beta2(0,i,j) = alp1/numalp
      beta2(1,i,j) = alp2/numalp
      beta2(2,i,j) = alp3/numalp
      beta2(3,i,j) = alp4/numalp

   end do
end do


do j = 0, dimy2-1
   do k = 0, dimx2-1
      new_GAHF2(:,j,k) = GAHF2(:,orig_xy2(0,j,k),orig_xy2(1,j,k))*beta2(0,j,k) + \
                         GAHF2(:,orig_xy2(0,j,k),tmp_xy2(1,j,k))*beta2(1,j,k) + \
                         GAHF2(:,tmp_xy2(0,j,k),orig_xy2(1,j,k))*beta2(2,j,k) + \
                         GAHF2(:,tmp_xy2(0,j,k),tmp_xy2(1,j,k))*beta2(3,j,k)
   end do
end do

delete(nm)

do i = 0, dimy3-1
   do j = 0, dimx3-1
      nm = getind_latlon2d (xlatd2, xlond2, glatd3(i,j), glond3(i,j))
      orig_xy3(1,i,j) = nm(0,1)   ;;; x ind.
      orig_xy3(0,i,j) = nm(0,0)   ;;; y ind.

      if ( xlatd2(nm(0,0),nm(0,1)) - glatd3(i,j) .ge. 0. ) then
         y1 = xlatd2(nm(0,0),nm(0,1)) - glatd3(i,j)
         y2 = glatd3(i,j) - xlatd2(nm(0,0)-1,nm(0,1))
         tmp_xy3(0,i,j) = nm(0,0) - 1
      end if

      if ( xlatd2(nm(0,0),nm(0,1)) - glatd3(i,j) .lt. 0. ) then
         if ( nm(0,0)+1 .ge. dimsizes(xlond2(:,0)-1) ) then
            y2 = xlatd2(nm(0,0),nm(0,1)) - glatd3(i,j)
            y1 = glatd3(i,j) - xlatd2(nm(0,0),nm(0,1))
            tmp_xy3(0,i,j) = nm(0,0) 
         end if

         if ( nm(0,0)+1 .lt. dimsizes(xlond2(:,0)-1) ) then
            y2 = xlatd2(nm(0,0)+1,nm(0,1)) - glatd3(i,j)
            y1 = glatd3(i,j) - xlatd2(nm(0,0),nm(0,1))
            tmp_xy3(0,i,j) = nm(0,0) + 1
         end if
      end if

      if ( xlond2(nm(0,0),nm(0,1)) - glond3(i,j) .ge. 0. ) then
         x1 = (xlond2(nm(0,0),nm(0,1)) - glond3(i,j))*cos(glatd3(i,j)*3.141592/180.)
         x2 = (glond3(i,j) - xlond2(nm(0,0),nm(0,1)-1))*cos(glatd3(i,j)*3.141592/180.)
         tmp_xy3(1,i,j) = nm(0,1) - 1
      end if

      if ( xlond2(nm(0,0),nm(0,1)) - glond3(i,j) .lt. 0. ) then
         if ( nm(0,1)+1 .ge. dimsizes(xlond2(0,:)-1) ) then
            x2 = (xlond2(nm(0,0),nm(0,1)) - glond3(i,j))*cos(glatd3(i,j)*3.141592/180.)
            x1 = (glond3(i,j) - xlond2(nm(0,0),nm(0,1)))*cos(glatd3(i,j)*3.141592/180.)
            tmp_xy3(1,i,j) = nm(0,1) 
         end if

         if ( nm(0,1)+1 .lt. dimsizes(xlond2(0,:)-1) ) then
            x2 = (xlond2(nm(0,0),nm(0,1)+1) - glond3(i,j))*cos(glatd3(i,j)*3.141592/180.)
            x1 = (glond3(i,j) - xlond2(nm(0,0),nm(0,1)))*cos(glatd3(i,j)*3.141592/180.)
            tmp_xy3(1,i,j) = nm(0,1) + 1
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

      beta3(0,i,j) = alp1/numalp
      beta3(1,i,j) = alp2/numalp
      beta3(2,i,j) = alp3/numalp
      beta3(3,i,j) = alp4/numalp

   end do
end do


do j = 0, dimy3-1
   do k = 0, dimx3-1
      new_GAHF3(:,j,k) = GAHF2(:,orig_xy3(0,j,k),orig_xy3(1,j,k))*beta3(0,j,k) + \
                         GAHF2(:,orig_xy3(0,j,k),tmp_xy3(1,j,k))*beta3(1,j,k) + \
                         GAHF2(:,tmp_xy3(0,j,k),orig_xy3(1,j,k))*beta3(2,j,k) + \
                         GAHF2(:,tmp_xy3(0,j,k),tmp_xy3(1,j,k))*beta3(3,j,k)
   end do
end do

delete(nm)

do i = 0, dimy4-1
   do j = 0, dimx4-1
      nm = getind_latlon2d (xlatd3, xlond3, glatd4(i,j), glond4(i,j))
      orig_xy4(1,i,j) = nm(0,1)   ;;; x ind.
      orig_xy4(0,i,j) = nm(0,0)   ;;; y ind.

      if ( xlatd3(nm(0,0),nm(0,1)) - glatd4(i,j) .ge. 0. ) then
         y1 = xlatd3(nm(0,0),nm(0,1)) - glatd4(i,j)
         y2 = glatd4(i,j) - xlatd3(nm(0,0)-1,nm(0,1))
         tmp_xy4(0,i,j) = nm(0,0) - 1
      end if

      if ( xlatd3(nm(0,0),nm(0,1)) - glatd4(i,j) .lt. 0. ) then
         if ( nm(0,0)+1 .ge. dimsizes(xlond3(:,0)-1) ) then
            y2 = xlatd3(nm(0,0),nm(0,1)) - glatd4(i,j)
            y1 = glatd4(i,j) - xlatd3(nm(0,0),nm(0,1))
            tmp_xy4(0,i,j) = nm(0,0)
         end if
 
         if ( nm(0,0)+1 .lt. dimsizes(xlond3(:,0)-1) ) then
            y2 = xlatd3(nm(0,0)+1,nm(0,1)) - glatd4(i,j)
            y1 = glatd4(i,j) - xlatd3(nm(0,0),nm(0,1))
            tmp_xy4(0,i,j) = nm(0,0) + 1
         end if
      end if

      if ( xlond3(nm(0,0),nm(0,1)) - glond4(i,j) .ge. 0. ) then
         x1 = (xlond3(nm(0,0),nm(0,1)) - glond4(i,j))*cos(glatd4(i,j)*3.141592/180.)
         x2 = (glond4(i,j) - xlond3(nm(0,0),nm(0,1)-1))*cos(glatd4(i,j)*3.141592/180.)
         tmp_xy4(1,i,j) = nm(0,1) - 1
      end if

      if ( xlond3(nm(0,0),nm(0,1)) - glond4(i,j) .lt. 0. ) then
         if ( nm(0,1)+1 .ge. dimsizes(xlond3(0,:)-1) ) then
            x2 = (xlond3(nm(0,0),nm(0,1)) - glond4(i,j))*cos(glatd4(i,j)*3.141592/180.)
            x1 = (glond4(i,j) - xlond3(nm(0,0),nm(0,1)))*cos(glatd4(i,j)*3.141592/180.)
            tmp_xy4(1,i,j) = nm(0,1) 
         end if

         if ( nm(0,1)+1 .lt. dimsizes(xlond3(0,:)-1) ) then
            x2 = (xlond3(nm(0,0),nm(0,1)+1) - glond4(i,j))*cos(glatd4(i,j)*3.141592/180.)
            x1 = (glond4(i,j) - xlond3(nm(0,0),nm(0,1)))*cos(glatd4(i,j)*3.141592/180.)
            tmp_xy4(1,i,j) = nm(0,1) + 1
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

      beta4(0,i,j) = alp1/numalp
      beta4(1,i,j) = alp2/numalp
      beta4(2,i,j) = alp3/numalp
      beta4(3,i,j) = alp4/numalp

   end do
end do


do j = 0, dimy4-1
   do k = 0, dimx4-1
      new_GAHF4(:,j,k) = GAHF3(:,orig_xy4(0,j,k),orig_xy4(1,j,k))*beta4(0,j,k) + \
                         GAHF3(:,orig_xy4(0,j,k),tmp_xy4(1,j,k))*beta4(1,j,k) + \
                         GAHF3(:,tmp_xy4(0,j,k),orig_xy4(1,j,k))*beta4(2,j,k) + \
                         GAHF3(:,tmp_xy4(0,j,k),tmp_xy4(1,j,k))*beta4(3,j,k)
   end do
end do

end if

GAHF_d01 = new((/dimtimes,dimy1,dimx1/),float)
GAHF_d02 = new((/dimtimes,dimy2,dimx2/),float)
GAHF_d03 = new((/dimtimes,dimy3,dimx3/),float)
GAHF_d04 = new((/dimtimes,dimy4,dimx4/),float)
Times = new((/dimtimes,19/),character)

delete(GAHF_d01@_FillValue)
delete(GAHF_d02@_FillValue)
delete(GAHF_d03@_FillValue)
delete(GAHF_d04@_FillValue)
GAHF_d01@coordinates = "XLONG XLAT"
GAHF_d02@coordinates = "XLONG XLAT"
GAHF_d03@coordinates = "XLONG XLAT"
GAHF_d04@coordinates = "XLONG XLAT"

 do i= 0, dimtimes-1
  s = "2010-06-88_99:00:00"
  if (i .lt. 24) then
   s = str_sub_str(s, "88", "22")
   s = str_sub_str(s, "99", sprinti("%0.2i",i))
   else if (i .lt. 48) then
    s = str_sub_str(s, "88", "23")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-24))
   else if (i .lt. 72) then
    s = str_sub_str(s, "88", "24")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-48))
   else if (i .lt. 96) then
    s = str_sub_str(s, "88", "25")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-72))
   else if (i .lt. 120) then
    s = str_sub_str(s, "88", "26")
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
FiAtt3 = True
FiAtt4 = True
copy_VarMeta(ii1, FiAtt1)
copy_VarMeta(ii2, FiAtt2)
copy_VarMeta(ii3, FiAtt3)
copy_VarMeta(ii4, FiAtt4)

FiAtt1@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt2@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt3@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt4@TITLE = "Hourly anthropogenic heat flux for Seoul"

rest = mod(dimtimes,24)
quot = floattoint((dimtimes-rest)/24.)

do i = 0, quot-1
   GAHF_d01(i*24:(i+1)*24-1,:,:) = new_GAHF1
   GAHF_d02(i*24:(i+1)*24-1,:,:) = new_GAHF2
   GAHF_d03(i*24:(i+1)*24-1,:,:) = new_GAHF3
   GAHF_d04(i*24:(i+1)*24-1,:,:) = new_GAHF4
end do

if ( rest .ne. 0 ) then
   GAHF_d01(quot*24:quot*24+rest-1,:,:) = new_GAHF1(0:rest-1,:,:)
   GAHF_d02(quot*24:quot*24+rest-1,:,:) = new_GAHF2(0:rest-1,:,:)
   GAHF_d03(quot*24:quot*24+rest-1,:,:) = new_GAHF3(0:rest-1,:,:)
   GAHF_d04(quot*24:quot*24+rest-1,:,:) = new_GAHF4(0:rest-1,:,:)
end if

setfileoption("nc","Format","LargeFile")
diro = "./"
filo1 = "gahf_d01.nc"
filo2 = "gahf_d02.nc"
filo3 = "gahf_d03.nc"
filo4 = "gahf_d04.nc"
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

fout1->GAHF = GAHF_d01
fout1->Times = Times
fout2->GAHF = GAHF_d02
fout2->Times = Times
fout3->GAHF = GAHF_d03
fout3->Times = Times
fout4->GAHF = GAHF_d04
fout4->Times = Times

do i = 0, dimtimes-1
print(" "+Times(i,0)+Times(i,1)+Times(i,2)+Times(i,3)+Times(i,4)+Times(i,5)+Times(i,6)+Times(i,7)+Times(i,8)+Times(i,9)+Times(i,10)+Times(i,11)+Times(i,12)+Times(i,13)+Times(i,14)+Times(i,15)+Times(i,16)+Times(i,17)+Times(i,18))
end do

end
