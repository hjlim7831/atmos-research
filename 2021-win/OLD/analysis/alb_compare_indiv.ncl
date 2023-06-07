begin

; ============================ We're going to change this part ========================

name = "ALB_IND" ; name of picture 

;type = "x11" ; picture type
type = "png"

opt = "MAX"
;opt = "DAYAVG"
;opt = 15

vopt = "T2"
;vopt = "TSK"
;vopt = "WSPD"

dir = "/home/hjlim/2021-win/model/"

datem = (/"01","01","01","01","01","01","08","08","08","08","08","08"/)
dated = (/"17","18","19","22","23","24","03","04","10","11","12","21"/) ; for input file name (UTC)
dateD = (/"18","19","20","23","24","25","04","05","11","12","13","22"/) ; for plotting (KST)

wcolor = (/"cyan3","lightsteelblue1","Blue","Green","darkolivegreen","forestgreen"/)
scolor = (/"deeppink","Red","lightsalmon3","Orange","darkorange4","gold"/)

t_start = 12
t_end = 36

;======================================================================================
;======================================================================================

;==================================== String Option ===================================
if opt .eq. "MAX" then
	sopt = 1
else if opt .eq. "DAYAVG" then
	sopt = 2
else if opt .ge. 0 .and. opt .le. 23 then
	sopt = 3
end if
end if
end if

if vopt .eq. "T2" then
	varname = "2 m temperature"
else if vopt .eq. "TSK" then
	varname = "skin temperature"
else if vopt .eq. "WSPD" then
	varname = "10 m wind speed"
end if
end if
end if
name = name + "_"+vopt


if vopt .ne. "WSPD" then
ytitle =  (/"daily maximum "+varname+" (K)",\
			"daytime average "+varname+" (K)",\
			varname+" at "+tostring(opt)+":00"/)
else
ytitle =  (/"daily maximum "+varname+" (m/s)",\
            "daytime average "+varname+" (m/s)",\
            varname+" at "+tostring(opt)+":00"/)
end if

;==================================== Data Processing ================================

nd = dimsizes(datem)

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(0)+"-"+dated(0)+"_03:00:00"

pathf = dir+datem(0)+dated(0)+albf

nfil = dimsizes(pathf)

a = addfile(pathf(0),"r")

if vopt .ne. "WSPD" then
t2 = a->$vopt$(t_start:t_end,:,:) - 273.15
else
t2 = (a->U10(t_start:t_end,:,:)^2.+a->V10(t_start:t_end,:,:)^2.)^0.5
end if


lu = a->LU_INDEX(0,:,:)
LAT = a->XLAT(0,:,:)
LON = a->XLONG(0,:,:)

nt = dimsizes(t2(:,0,0))
ny = dimsizes(t2(0,:,0))
nx = dimsizes(t2(0,0,:))

t2box = new((/nd,nfil,nt,ny,nx/),float)
ut2 = new((/nd,nfil,nt/),float)
ut2 = 0.


do jj = 0, nd -1

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(jj)+"-"+dated(jj)+"_03:00:00"
pathf = dir+datem(jj)+dated(jj)+albf

do ii = 0, nfil -1
	a1 = addfile(pathf(ii),"r")
	if vopt .ne. "WSPD" then
		t2box(jj,ii,:,:,:) = a1->$vopt$(t_start:t_end,:,:) - 273.15
	else
		t2box(jj,ii,:,:,:) = (a1->U10(t_start:t_end,:,:)^2.+a1->V10(t_start:t_end,:,:)^2.)^0.5
	end if
	delete([/a1/])
end do
end do

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)
BON = gc_inout(LAT,LON,sblat,sblon)
;print(BON)


nn = 0
do i = 0, ny -1
	do j = 0, nx -1
		if (lu(i,j) .eq. 13 .or. lu(i,j) .ge. 31) .and. BON(i,j) then
			ut2(:,:,:) = ut2(:,:,:) + t2box(:,:,:,i,j)
			nn = nn + 1
		end if
	end do
end do

ut2 = ut2/tofloat(nn)
;print(ut2)

tt = new((/nd,nfil/),float)

; ============================== Select Option (Max, Avg, specific time) ==================================


if sopt .eq. 1 then
do jj = 0, nd -1
	do ii = 0, nfil -1
		tt(jj,ii) = max(ut2(jj,ii,:))
		print(maxind(ut2(jj,ii,:))+1)
	end do
end do

name = name + "_"+opt

else if sopt .eq. 2 then
do jj = 0, nd -1
	do ii = 0, nfil -1
		tt(jj,ii) = avg(ut2(jj,ii,8:18))
	end do
end do
name = name + "_"+opt


else if sopt .eq. 3 then
do jj = 0, nd -1
	do ii = 0, nfil -1
		tt(jj,ii) = ut2(jj,ii,opt)
	end do
end do
name = name + "_"+tostring(opt)
end if
end if
end if

;=========================================================================================================

do jj = 0, nd -1
	tt(jj,:) = tt(jj,:) - tt(jj,nfil-1)
end do


alb = new((/nd,nfil/),float)

do ii = 0, nd -1
	alb(ii,:) = tofloat(ispan(1,9,1))/10.
end do


;========================================== Plotting Section =============================================

wks = gsn_open_wks(type,name)

thn = new(nd,float)
dpat = new(nd,integer)
mpat = new(nd,integer)
mpat = 16

thn = 4.0
do jj = 0, nd -1
	if datem(jj) .eq. "08" then
		dpat(jj) = 0
	else
		dpat(jj) = 1
	end if
end do

tcolor = array_append_record(wcolor,scolor,0)


res									= True
res@xyMarkLineMode					= "MarkLines"
res@xyLineThicknesses				= thn
res@xyDashPatterns					= dpat
res@xyMarkers						= mpat
res@xyLineColors					= tcolor
res@xyMarkerColors					= tcolor
res@tiXAxisString					= "albedo"
res@tiYAxisString					= ytitle(sopt-1)
res@trXMinF							= 0.1
res@trXMaxF							= 0.9

res@xyExplicitLegendLabels			= datem+dateD
res@pmLegendDisplayMode				= True
res@pmLegendWidthF					= 0.10
res@pmLegendHeightF					= 0.35
res@pmLegendParallelPosF			= 0.88
res@pmLegendOrthogonalPosF			= -1.15
res@lgPerimOn						= False

plot = gsn_csm_xy(wks,alb,tt,res)




end
