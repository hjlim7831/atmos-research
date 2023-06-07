begin

; ============================ We're going to change this part ========================

name = "SCAT" ; name of output picture 

;type = "x11" ; picture type
type = "png"

;opt = "MAX"
;opt = "DAYAVG"
;opt = "AVG"
opt = 15

;dopt = "TOT"
;dopt = "SUM"
dopt = "WIN"


xvar = (/"T2","TSK","WSPD"/)
yvar = (/"T2","TSK","WSPD"/)

;DAYAVG
;xtitle = (/"daytime average 10 m wind speed (m/s)","daytime average 2 m temperature (~S2~o  C)"/)
;ytitle = (/"slope of daytime average 2 m temperature (~S2~o  C)","slope of daytime average skin temperature (~S2~o  C)","slope of daytime average 10 m wind speed (m/s)"/)

;AVG
;xtitle = (/"daily average 10 m wind speed (m/s)","daily average 2 m temperature (~S2~o  C)"/)
;ytitle = (/"slope of daily average 2 m temperature (~S2~o  C)","slope of daily average skin temperature (~S2~o  C)","slope of daily average 10 m wind speed (m/s)"/)


dir = "/home/hjlim/2021-win/model/"


t_start = 12
t_end = 36

;======================================================================================
;======================================================================================

;==================================== String Option ===================================
if opt .eq. "MAX" then
	sopt = 1
	xtitle = (/"maximum 2 m temperature (~S2~o  C)","maximum skin temperature (~S2~o  C)","maximum 10 m wind speed (~S2~o  C)"/)
	ytitle = (/"slope of maximum 2 m temperature (~S2~o  C)","slope of maximum skin temperature (~S2~o  C)", "slope of maximum 10 m wind speed (~S2~o  C)"/)
else if opt .eq. "DAYAVG" then
	sopt = 2
	xtitle = (/"daytime average 2 m temperature (~S2~o  C)","daytime average skin temperature (~S2~o  C)","daytime average 10 m wind speed (~S2~o  C)"/)
	ytitle = (/"slope of daytime average 2 m temperature (~S2~o  C)","slope of daytime average skin temperature (~S2~o  C)","slope of daytime average 10 m wind speed (~S2~o  C)"/)
else if opt .eq. "AVG" then
	sopt = 3
	xtitle = (/"average 2 m temperature (~S2~o  C)","average skin temperature (~S2~o  C)","average 10 m wind speed (~S2~o  C)"/)
	ytitle = (/"slope of average 2 m temperature (~S2~o  C)","slope of average skin temperature (~S2~o  C)","slope of average 10 m wind speed (~S2~o  C)"/)
else if opt .ge. 0 .and. opt .le. 23 then
	sopt = 4
	xtitle = (/"2 m temperature at "+opt+":00 LST (~S2~o  C)","skin temperature at "+opt+":00 LST (~S2~o  C)","10 m wind speed at "+opt+":00 LST (~S2~o  C)"/)
	ytitle = (/"slope of 2 m temperature at "+opt+":00 LST (~S2~o  C)","slope of skin temperature at "+opt+":00 LST (~S2~o  C)","slope of 10 m wind speed at "+opt+":00 LST (~S2~o  C)"/)
end if
end if
end if
end if

if dopt .eq. "TOT" then
	datem = (/"01","01","01","01","01","01","08","08","08","08","08","08"/)
	dated = (/"17","18","19","22","23","24","03","04","10","11","12","21"/)
	dateD = (/"18","19","20","23","24","25","04","05","11","12","13","22"/)
else if dopt .eq. "SUM" then
	datem = (/"08","08","08","08","08","08"/)
	dated = (/"03","04","10","11","12","21"/)
	dateD = (/"04","05","11","12","13","22"/)
else if dopt .eq. "WIN" then
	datem = (/"01","01","01","01","01","01"/)
	dated = (/"17","18","19","22","23","24"/)
	dateD = (/"18","19","20","23","24","25"/)
end if
end if
end if
	name = name + "_"+dopt


;if vopt .ne. "WSPD" then
;ytitle =  (/"daily maximum "+varname+" (K)",\
;			"daytime average "+varname+" (K)",\
;			varname+" at "+tostring(opt)+":00"/)
;else
;ytitle =  (/"daily maximum "+varname+" (m/s)",\
;            "daytime average "+varname+" (m/s)",\
;            varname+" at "+tostring(opt)+":00"/)
;end if

;==================================== Data Processing ================================

nd = dimsizes(datem)
xv = dimsizes(xvar)
yv = dimsizes(yvar)
tv = xv + yv

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(0)+"-"+dated(0)+"_03:00:00"

pathf = dir+datem(0)+dated(0)+albf

nfil = dimsizes(pathf)

a = addfile(pathf(0),"r")

t2 = a->T2(t_start:t_end,:,:) - 273.15

lu = a->LU_INDEX(0,:,:)
LAT = a->XLAT(0,:,:)
LON = a->XLONG(0,:,:)

nt = dimsizes(t2(:,0,0))
ny = dimsizes(t2(0,:,0))
nx = dimsizes(t2(0,0,:))


tvar = array_append_record(xvar,yvar,0)

tbox = new((/tv,nd,nfil,nt,ny,nx/),float)
utv = new((/tv,nd,nfil,nt/),float)
utv = 0.

do jj = 0, nd -1

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(jj)+"-"+dated(jj)+"_03:00:00"
pathf = dir+datem(jj)+dated(jj)+albf

do ii = 0, nfil -1
	a1 = addfile(pathf(ii),"r")
	do kk = 0, tv -1 
		if tvar(kk) .eq. "WSPD" then
			tbox(kk,jj,ii,:,:,:) = (a1->U10(t_start:t_end,:,:)^2.+a1->V10(t_start:t_end,:,:)^2.)^0.5
		else if (tvar(kk) .eq. "T2") .or. (tvar(kk) .eq. "TSK") then
			tbox(kk,jj,ii,:,:,:) = a1->$tvar(kk)$(t_start:t_end,:,:) - 273.15
		else
			tbox(kk,jj,ii,:,:,:) = a1->$tvar(kk)$(t_start:t_end,:,:)
		end if
		end if
	end do
	delete([/a1/])
end do
end do

xbox = tbox(:xv-1,:,:,:,:,:)
ybox = tbox(xv:tv-1,:,:,:,:,:)

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)
BON = gc_inout(LAT,LON,sblat,sblon)
;print(BON)

nn = 0
do i = 0, ny -1
	do j = 0, nx -1
		if (lu(i,j) .eq. 13 .or. lu(i,j) .ge. 31) .and. BON(i,j) then
			utv(:,:,:,:) = utv(:,:,:,:) + tbox(:,:,:,:,i,j)
			nn = nn + 1
		end if
	end do
end do

utv = utv/tofloat(nn)
;print(utv)

tt = new((/tv,nd,nfil/),float)

; ============================== Select Option (Max, Avg, specific time) ==================================


if sopt .eq. 1 then
do kk = 0, tv -1
	do jj = 0, nd -1
		do ii = 0, nfil -1
			tt(kk,jj,ii) = max(utv(kk,jj,ii,:))
			print(maxind(ut2(jj,ii,:)))
		end do
	end do
end do

name = name + "_"+opt

else if sopt .eq. 2 then

tt = dim_avg_n(utv(:,:,:,8:18),3)
name = name + "_"+opt

else if sopt .eq. 3 then
tt = dim_avg_n(utv,3)
name = name + "_"+opt

else if sopt .eq. 4 then
tt = utv(:,:,:,opt)
name = name + "_"+tostring(opt)
end if
end if
end if
end if

; variable X selected day X albedo
tx = tt(:xv-1,:,:)
ty = tt(xv:tv-1,:,:)


alb = tofloat(ispan(1,9,1))/10.

yreg = new((/yv,nd/),float)

do i = 0, yv -1
	do j = 0, nd -1
		yreg(i,j) = regline_stats(alb,ty(i,j,:))
	end do
end do

xx = dim_avg_n(tx,2)

;========================================== Plotting Section =============================================


res									= True
res@xyMarkLineModes					= (/"Markers","Lines"/)
res@xyMarkers						= (/16,16/)
res@xyLineThicknesses				= (/4.0,4.0/)
res@xyDashPatterns					= (/0,0/)
res@xyMarkerColors					= (/"black","black"/)
;res@trXMinF                         = 0.1
;res@trXMaxF                         = 0.9
res@gsnLeftStringOrthogonalPosF		= -0.1
res@gsnLeftStringParallelPosF		= 0.05

nameb = name

xf = new((/2,nd/),float)
yf = new((/2,nd/),float)

do ii = 0, yv -1
do jj = 0, xv -1
	name = nameb+"_"+xvar(jj)+"_"+yvar(ii)+"reg"
	wks = gsn_open_wks(type,name)
	res@tiYAxisString = ytitle(ii)
	res@tiXAxisString = xtitle(jj)
	xf(0,:) = xx(jj,:)
	yf(0,:) = yreg(ii,:)
	aa = regline_stats(xf(0,:),yf(0,:))
	xf(1,:) = xf(0,:)
	yf(1,:) = aa@b(0) + aa@b(1)*xf(1,:)
	res@gsnLeftString = "R~S2~2  = "+decimalPlaces(aa@r2,2,True)
	print(aa)
;	print(aa@r2)
	plot = gsn_csm_xy(wks,xf,yf,res)
	print(name)
end do
end do



end
