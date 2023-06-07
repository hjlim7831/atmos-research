begin

; ============================ We're going to change this part ========================

name = "SCAT" ; name of output picture 

;type = "x11" ; picture type
type = "png"

;opt = "MAX"
opt = "DAYAVG"
;opt = "AVG"
;opt = 15

;dopt = "TOT"
;dopt = "SUM"
dopt = "WIN"


tvar = (/"T2","TSK","WSPD"/)

;DAYAVG
ttitle = (/"daytime average 2 m temperature (~S2~o  C)","daytime average skin temperature (~S2~o  C)","daytime average 10 m wind speed (m/s)"/)

;AVG
;ttitle = (/"daily average 2 m temperature (~S2~o  C)","daily average skin temperature (~S2~o  C)","daily average 10 m wind speed (m/s)"/)


dir = "/home/hjlim/2021-win/model/"

t_start = 12
t_end = 36

;======================================================================================
;======================================================================================

;==================================== String Option ===================================
if opt .eq. "MAX" then
	sopt = 1
else if opt .eq. "DAYAVG" then
	sopt = 2
else if opt .eq. "AVG" then
	sopt = 3
else if opt .ge. 0 .and. opt .le. 23 then
	sopt = 4
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
tv = dimsizes(tvar)

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

tf = dim_avg_n(tt,2)

;========================================== Plotting Section =============================================


res									= True
res@xyMarkLineMode					= "Markers"
res@xyMarkers						= 16
res@xyMarkerColors					= (/"black"/)
;res@trXMinF                         = 0.1
;res@trXMaxF                         = 0.9

nameb = name

do ii = 0, tv -1
do jj = 0, tv -1
	if ii .ne. jj then
	name = nameb+"_"+tvar(jj)+"_"+tvar(ii)
	wks = gsn_open_wks(type,name)
	res@tiYAxisString = ttitle(ii)
	res@tiXAxisString = ttitle(jj)
	plot = gsn_csm_xy(wks,tf(jj,:),tf(ii,:),res)
	print(name)
	aa = regline_stats(tf(jj,:),tf(ii,:))
	print(aa)
	end if
end do
end do



end
