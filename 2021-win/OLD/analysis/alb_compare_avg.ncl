begin

; ============================ We're going to change this part ========================

name = "ALB_AVG" ; name of picture 

datacheck = True ; extracting processed data as a netCDF file.
dataname = "DATA"

;type = "x11" ; picture type
type = "png"

opt = "MAX"
;opt = "DAYAVG"
;opt = "AVG"
;opt = 15

;vopt = "T2"
;vopt = "TSK"
;vopt = "WSPD"
;vopt = "WDCH" ; only for Winter
vopt = "WBGT" ; only for Summer

dir = "/home/hjlim/2021-win/model/"

wcolor = (/"lightsteelblue2","lightsteelblue2","lightsteelblue2","lightsteelblue2","lightsteelblue2","lightsteelblue2"/)
scolor = (/"lightpink2","lightpink2","lightpink2","lightpink2","lightpink2","lightpink2"/)
acolor = (/"Blue","Red"/)

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

if vopt .eq. "T2" then
	varname = "2 m temperature"
else if vopt .eq. "TSK" then
	varname = "skin temperature"
else if vopt .eq. "WSPD" then
	varname = "10 m wind speed"
else if vopt .eq. "WDCH" then
	varname = "wind chill"
else if vopt .eq. "WBGT" then
	varname = "Wet-bulb globe temperature"
end if
end if
end if
end if
end if
name = name + "_"+vopt


if vopt .eq. "WSPD" then
ytitle =  (/"daily maximum "+varname+" (m/s)",\
            "daytime average "+varname+" (m/s)",\
			"daily average "+varname+" (m/s)",\
            varname+" at "+tostring(opt)+":00"/)
else if vopt .eq. "WDCH" then
ytitle = (/"daily maximum "+varname+" (~S2~o  C)",\
		   "daytime average "+varname+" (~S2~o  C)",\
		   "daily average "+varname+" (~S2~o  C)",\
		   varname+" at "+tostring(opt)+":00"/)
else if vopt .eq. "WBGT" then
ytitle = (/"daily maximum "+varname+" (~S2~o  C)",\
           "daytime average "+varname+" (~S2~o  C)",\
           "daily average "+varname+" (~S2~o  C)",\
           varname+" at "+tostring(opt)+":00"/)
else
ytitle =  (/"daily maximum "+varname+" (K)",\
			"daytime average "+varname+" (K)",\
			"daily average "+varname+" (K)",\
			varname+" at "+tostring(opt)+":00"/)
end if
end if
end if

if vopt .eq. "WDCH" then
datem = (/"01","01","01","01","01","01"/)
dated = (/"17","18","19","22","23","24"/) ; for input file name (UTC)
dateD = (/"18","19","20","23","24","25"/) ; for plotting (KST)
print("Note: WindChill can be calculated only for Winter")

else if vopt .eq. "WBGT" then
datem = (/"08","08","08","08","08","08"/)
dated = (/"03","04","10","11","12","21"/) ; for input file name (UTC)
dateD = (/"04","05","11","12","13","22"/) ; for plotting (KST)
print("Note: Wet-bulb globe temperature can be calculated only for Summer")

else
datem = (/"01","01","01","01","01","01","08","08","08","08","08","08"/)
dated = (/"17","18","19","22","23","24","03","04","10","11","12","21"/) ; for input file name (UTC)
dateD = (/"18","19","20","23","24","25","04","05","11","12","13","22"/) ; for plotting (KST)

end if
end if


;==================================== Data Processing ================================

nd = dimsizes(datem)

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(0)+"-"+dated(0)+"_03:00:00"

pathf = dir+datem(0)+dated(0)+albf

nfil = dimsizes(pathf)

a = addfile(pathf(0),"r")

lu = a->LU_INDEX(0,:,:)
LAT = a->XLAT(0,:,:)
LON = a->XLONG(0,:,:)

nt = t_end - t_start + 1
ny = dimsizes(lu(:,0))
nx = dimsizes(lu(0,:))


if vopt .eq. "WSPD" then
t2 = (a->U10(t_start:t_end,:,:)^2.+a->V10(t_start:t_end,:,:)^2.)^0.5

else if vopt .eq. "WDCH" then
Ti = a->T2(t_start:t_end,:,:) - 273.15 ;deg
Vi = (a->U10(t_start:t_end,:,:)^2.+a->V10(t_start:t_end,:,:)^2.)^0.5*3.6 ;km/h

t2 = new((/nt,ny,nx/),float)
do k = 0, nt -1
	do j = 0, ny -1
		do i = 0, nx -1
			Te = Ti(k,j,i)
			Ve = Vi(k,j,i)
			if Te .ge. 10. .and. Ve .le. 4.8 then
				t2(k,j,i) = 13.12+0.6215*Te-11.37*Ve^0.16+0.3965*Ve^0.16*Te
			else
				t2(k,j,i) = Te
			end if
		end do
	end do
end do

else if vopt .eq. "WBGT" then
Tai = a->T2(t_start:t_end,:,:) - 273.15
RHi = wrf_rh(a->Q2(t_start:t_end,:,:),a->PSFC(t_start:t_end,:,:),Tai) / 100.
Twi = Tai*atan(0.151977*(RHi+8.313659)^0.5)+atan(Tai+RHi)-atan(RHi-1.676331)+0.00391838*RHi^1.5*atan(0.023101*RHi)-4.686035
t2 = 3.255820 + 0.553991*Twi + 0.455346*Tai - 0.002170 * Twi^2. + 0.002782*Twi*Tai

else
t2 = a->$vopt$(t_start:t_end,:,:) - 273.15
end if
end if
end if

t2box = new((/nd,nfil,nt,ny,nx/),float)
ut2 = new((/nd,nfil,nt/),float)
ut2 = 0.


do jj = 0, nd -1

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(jj)+"-"+dated(jj)+"_03:00:00"
pathf = dir+datem(jj)+dated(jj)+albf

do ii = 0, nfil -1
	a1 = addfile(pathf(ii),"r")
	print(pathf(ii))
	if vopt .eq. "WSPD" then
		t2box(jj,ii,:,:,:) = (a1->U10(t_start:t_end,:,:)^2.+a1->V10(t_start:t_end,:,:)^2.)^0.5
	else if vopt .eq. "WDCH" then
		T = a1->T2(t_start:t_end,:,:) - 273.15 ;deg
		V = (a1->U10(t_start:t_end,:,:)^2.+a1->V10(t_start:t_end,:,:)^2.)^0.5*3.6 ;km/h
		do k = 0, nt -1
			do j = 0, ny -1
			    do i = 0, nx -1
			        Te = T(k,j,i)
		            Ve = V(k,j,i)
		            if Te .le. 10. .and. Ve .ge. 4.8 then
		                t2box(jj,ii,k,j,i) = 13.12+0.6215*Te-11.37*Ve^0.16+0.3965*Ve^0.16*Te
					else
						t2box(jj,ii,k,j,i) = Te
		            end if
		        end do
		    end do
	    end do
	else if vopt .eq. "WBGT" then
		Ta = a1->T2(t_start:t_end,:,:) - 273.15
		RH = wrf_rh(a1->Q2(t_start:t_end,:,:),a1->PSFC(t_start:t_end,:,:),Ta) / 100.
		Tw = Ta*atan(0.151977*(RH+8.313659)^0.5)+atan(Ta+RH)-atan(RH-1.676331)+0.00391838*RH^1.5*atan(0.023101*RH)-4.686035
		t2box(jj,ii,:,:,:) = 3.255820 + 0.553991*Tw + 0.455346*Ta - 0.002170 * Tw^2. + 0.002782*Tw*Ta
	else
		t2box(jj,ii,:,:,:) = a1->$vopt$(t_start:t_end,:,:) - 273.15
	end if
	end if
	end if
	delete([/a1/])
end do
end do

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)
BON = gc_inout(LAT,LON,sblat,sblon)
;print(BON)

if datacheck then
setfileoption("nc","Format","LargeFile")
filo = dataname+"_"+vopt+"_"+opt+".nc"
system("/bin/rm -f "+filo)
fout = addfile(filo,"c")
fout->$vopt$ = t2box

nbon = dimsizes(BON)
bonc = new(nbon,integer)
do i = 0, nbon(0) -1
	do j = 0, nbon(1) -1
		if BON(i,j) then
			bonc(i,j) = 1
		end if
	end do
end do

fout->BON = bonc
end if

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

tt = new((/nd+2,nfil/),float)

; ============================== Select Option (Max, Avg, specific time) ==================================


if sopt .eq. 1 then
do jj = 0, nd -1
	do ii = 0, nfil -1
		tt(jj,ii) = max(ut2(jj,ii,:))
		print(maxind(ut2(jj,ii,:)))
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
        tt(jj,ii) = avg(ut2(jj,ii,:))
    end do
end do
name = name + "_"+opt


else if sopt .eq. 4 then
do jj = 0, nd -1
	do ii = 0, nfil -1
		tt(jj,ii) = ut2(jj,ii,opt)
	end do
end do
name = name + "_"+tostring(opt)
end if
end if
end if
end if

if vopt .eq. "WDCH" .or. vopt .eq. "WBGT" then
tt(nd,:) = dim_avg_n(tt(:5,:),0)
else
tt(nd,:) = dim_avg_n(tt(:5,:),0)
tt(nd+1,:) = dim_avg_n(tt(6:11,:),0)
end if
print(tt(nd,:))
print(tt(nd+1,:))


;=========================================================================================================

do jj = 0, nd+2 -1
	tt(jj,:) = tt(jj,:) - tt(jj,nfil-1)
end do


alb = new((/nd+2,nfil/),float)

do ii = 0, nd+2 -1
	alb(ii,:) = tofloat(ispan(1,9,1))/10.
end do


;========================================== Plotting Section =============================================

wks = gsn_open_wks(type,name)

thn = new(nd+2,float)
dpat = new(nd+2,integer)
mpat = new(nd+2,integer)
opa = new(nd+2,float)

dpat = 0
mpat = 16

opa(:nd-1) = 0.6
opa(nd:nd+1) = 1.0

thn = 4.0

if vopt .eq. "WDCH" then
tcolor = array_append_record(wcolor,acolor,0)
else if vopt .eq. "WBGT" then
tcolor = array_append_record(scolor,acolor,0)
else
tcolor1 = array_append_record(wcolor,scolor,0)
tcolor = array_append_record(tcolor1,acolor,0)
end if
end if


res									= True
res@xyMarkLineMode					= "MarkLines"
res@xyLineThicknesses				= thn
res@xyDashPatterns					= dpat
res@xyMarkers						= mpat
res@xyLineColors					= tcolor
res@xyMarkerColors					= tcolor
res@xyLineOpacities					= opa
res@tiXAxisString					= "albedo"
res@tiYAxisString					= ytitle(sopt-1)
res@trXMinF                         = 0.1
res@trXMaxF                         = 0.9


;res@xyExplicitLegendLabels			= datem+dateD
;res@pmLegendDisplayMode				= True
;res@pmLegendWidthF					= 0.12
;res@pmLegendHeightF					= 0.20
;res@pmLegendParallelPosF			= 0.85
;res@pmLegendOrthogonalPosF			= -1.15
;res@lgPerimOn						= False

plot = gsn_csm_xy(wks,alb,tt,res)




end
