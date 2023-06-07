load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;========== Data input =================

diro1 = "./Data/"
filo1 = "u500.day.7918.nc"
filo2 = "v500.day.7918.nc"

a1 = addfile(diro1+filo1,"r")
a2 = addfile(diro1+filo2,"r")

u = a1->U(:,:,6:60-12,:)
v = a2->V(:,:,6:60-12,:)

;=========  Calculating MCI ==============

dimt = dimsizes(u(:,0,0,0))
dimy = dimsizes(u(0,0,:,0))
dimx = dimsizes(u(0,0,0,:))

v_bar = dim_avg_n(v,3)
printVarSummary(v)
printVarSummary(v_bar)

MCI = new((/dimt,dimy,dimx/),float)

do i = 0, dimx -1
	print(i)
	MCI(:,:,i) = (v(:,0,:,i) - v_bar(:,0,:)) * abs(v(:,0,:,i))/(u(:,0,:,i)^2+v(:,0,:,i)^2)
end do

;printVarSummary(u)

;======== Separating MCI ==============

;-------- Calculating Date -------------

tst = 1979

yearl = 2018 - 1979 + 1
ly = new(yearl,integer) ; if ly = 1, total days in a year : 366

ly = 0

do i = 0, yearl -1
    year = i + 1979
    if mod(year,4) .eq. 0 then
        ly(i) = 1
    end if
end do

do i = 0, yearl -1
    year = i + 1979
    if mod(year,100) .eq. 0 then
        ly(i) = 0
    end if
end do

do i = 0, yearl -1
    year = i + 1979
    if mod(year,400) .eq. 0 then
        ly(i) = 1
    end if
end do

print(ly)

;;case 1: 1995 - 2013

start_year1 = 1995
end_year1 = 2013

ist1 = 0
do i = 0, start_year1 - tst -1
	year = i + tst
	if ly(i) .eq. 1 then
		ist1 = ist1 + 366
	else
		ist1 = ist1 + 365
	end if
end do

iend1 = 0
do i = 0, end_year1 - tst
	year = i + tst
	if ly(i) .eq. 1 then
		iend1 = iend1 + 366
	else
		iend1 = iend1 + 365
	end if
end do


MCI1 = new((/4,dimy,dimx/),float,-999)
MCI2 = new((/4,dimy,dimx/),float,-999)
MCI1 = 0
MCI2 = 0

nn = new(4,integer)
nn = 0

ii = ist1
do i = start_year1 - tst, end_year1 - tst
	year = i + tst
	if ly(i) .eq. 1 then
	MCI1(0,:,:) = MCI1(0,:,:) + dim_sum_n(MCI(ii:ii+31+29+31-1,:,:),0)
	MCI1(1,:,:) = MCI1(1,:,:) + dim_sum_n(MCI(ii+91:ii+91+30+31+30-1,:,:),0)
	MCI1(2,:,:) = MCI1(2,:,:) + dim_sum_n(MCI(ii+182:ii+182+31+31+30-1,:,:),0)
	MCI1(3,:,:) = MCI1(3,:,:) + dim_sum_n(MCI(ii+274:ii+274+31+30+31-1,:,:),0)
	ii = ii + 366
	nn(0) = nn(0) + 31+29+31
	nn(1) = nn(1) + 30+31+30
	nn(2) = nn(2) + 31+31+30
	nn(3) = nn(3) + 31+30+31
	else 
    MCI1(0,:,:) = MCI1(0,:,:) + dim_sum_n(MCI(ii:ii+31+28+31-1,:,:),0)
    MCI1(1,:,:) = MCI1(1,:,:) + dim_sum_n(MCI(ii+90:ii+90+30+31+30-1,:,:),0)
    MCI1(2,:,:) = MCI1(2,:,:) + dim_sum_n(MCI(ii+181:ii+181+31+31+30-1,:,:),0)
    MCI1(3,:,:) = MCI1(3,:,:) + dim_sum_n(MCI(ii+273:ii+273+31+30+31-1,:,:),0)
	ii = ii + 365
    nn(0) = nn(0) + 31+28+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
	end if
end do
print(ii)
print(iend1)

do i = 0, 3
	MCI1(i,:,:) = MCI1(i,:,:)/tofloat(nn(i))
end do


;; case 2: 1981 - 2010

start_year2 = 1981
end_year2 = 2010

ist2 = 0
do i = 0, start_year2 - tst -1
    year = i + tst
    if ly(i) .eq. 1 then
        ist2 = ist2 + 366
    else
        ist2 = ist2 + 365
    end if
end do

iend2 = 0
do i = 0, end_year2 - tst
    year = i + tst
    if ly(i) .eq. 1 then
        iend2 = iend2 + 366
    else
        iend2 = iend2 + 365
    end if
end do

nn = new(4,integer)
nn = 0
ii = ist2
do i = start_year2 - tst, end_year2 - tst
    year = i + tst
    if ly(i) .eq. 1 then
    MCI2(0,:,:) = MCI2(0,:,:) + dim_sum_n(MCI(ii:ii+31+29+31-1,:,:),0)
    MCI2(1,:,:) = MCI2(1,:,:) + dim_sum_n(MCI(ii+91:ii+91+30+31+30-1,:,:),0)
    MCI2(2,:,:) = MCI2(2,:,:) + dim_sum_n(MCI(ii+182:ii+182+31+31+30-1,:,:),0)
    MCI2(3,:,:) = MCI2(3,:,:) + dim_sum_n(MCI(ii+274:ii+274+31+30+31-1,:,:),0)
    ii = ii + 366
    nn(0) = nn(0) + 31+29+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
    else 
    MCI2(0,:,:) = MCI2(0,:,:) + dim_sum_n(MCI(ii:ii+31+28+31-1,:,:),0)
    MCI2(1,:,:) = MCI2(1,:,:) + dim_sum_n(MCI(ii+90:ii+90+30+31+30-1,:,:),0)
    MCI2(2,:,:) = MCI2(2,:,:) + dim_sum_n(MCI(ii+181:ii+181+31+31+30-1,:,:),0)
    MCI2(3,:,:) = MCI2(3,:,:) + dim_sum_n(MCI(ii+273:ii+273+31+30+31-1,:,:),0)
    ii = ii + 365
    nn(0) = nn(0) + 31+28+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
    end if
	print(ii)
end do

do i = 0, 3
    MCI2(i,:,:) = MCI2(i,:,:)/tofloat(nn(i))
end do

print(ist1)
print(ist2)
print(iend1)
print(iend2)

dd = (abs(MCI1) - abs(MCI2)) * 100
dd!1 = "lat"
dd!2 = "lon"
dd&lat = u&lat
dd&lon = u&lon



;=============================== plotting ==========================

;type = "x11"
type = "png"

 wks = gsn_open_wks(type,"mci")

 gsn_define_colormap(wks,"MPL_coolwarm")

res_m = True

res_m@cnFillOn              	= True
res_m@cnLinesOn             	= False
res_m@cnLevelSelectionMode     	= "ExplicitLevels"

res_m@lbTitleOn             	= False
res_m@lbOrientation         	= "Horizontal"
res_m@pmLabelBarHeightF     	= 0.03
res_m@pmLabelBarOrthogonalPosF  = 0.4


res_m@mpLimitMode           	= "Corners"
res_m@mpLeftCornerLatF      	= 20
res_m@mpRightCornerLatF     	= 80

res_m@mpShapeMode           	= "FreeAspect"
res_m@vpWidthF              	= 0.5
res_m@vpHeightF             	= 0.1
res_m@tmXBlabelFontHeightF      = 0.004
res_m@tmYLLabelFontHeightF      = 0.010

res_m@gsnLeftString				= "JFM"

res_m@cnLevels              	= fspan(-6,6,13)
plot1 = gsn_csm_contour_map(wks,dd(0,:,:),res_m)

res_m@gsnLeftString         	= "AMJ"

res_m@cnLevels              	= fspan(-6,6,13)
plot2 = gsn_csm_contour_map(wks,dd(1,:,:),res_m)

res_m@gsnLeftString         	= "JAS"

res_m@cnLevels              	= fspan(-6,6,13)
plot3 = gsn_csm_contour_map(wks,dd(2,:,:),res_m)

res_m@gsnLeftString         	= "OND"

res_m@cnLevels              	= fspan(-6,6,13)
plot4 = gsn_csm_contour_map(wks,dd(3,:,:),res_m)





end
