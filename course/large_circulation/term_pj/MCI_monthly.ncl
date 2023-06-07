load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

diro1 = "./Data/"
filo1 = "u.mon.7918.nc"
filo2 = "v.mon.7918.nc"

a1 = addfile(diro1+filo1,"r")
a2 = addfile(diro1+filo2,"r")

u = a1->U(:,15,6:60-12,:)
v = a2->V(:,15,6:60-12,:)

dimt = dimsizes(u(:,0,0))
dimy = dimsizes(u(0,:,0))
dimx = dimsizes(u(0,0,:))

v_bar = dim_avg_n(v,2)

;printVarSummary(v_st)

MCI = new((/dimt,dimy,dimx/),float)

do i = 0, dimx -1
	print(i)
	MCI(:,:,i) = (v(:,:,i) - v_bar) * abs(v(:,:,i))/(u(:,:,i)^2+v(:,:,i)^2)
end do

;printVarSummary(u)


MCI1 = new((/4,dimy,dimx/),float,-999)
MCI2 = new((/4,dimy,dimx/),float,-999)
MCI1 = 0
MCI2 = 0

ts = (1995-1979) *12
te = (2013-1979) *12-1
n = 0
do i = 0, 2
	do j = ts+i, te, 12
	MCI1(0,:,:) = MCI1(0,:,:) + MCI(j,:,:)
	MCI1(1,:,:) = MCI1(1,:,:) + MCI(j+3,:,:)
	MCI1(2,:,:) = MCI1(2,:,:) + MCI(j+6,:,:)
	MCI1(3,:,:) = MCI1(3,:,:) + MCI(j+9,:,:)
	n = n + 1
	end do
end do

MCI1 = MCI1 / tofloat(n)

ts = (1981-1979) *12
te = (2010-1979) *12-1
n = 0
do i = 0, 2
    do j = ts+i, te, 12
    MCI2(0,:,:) = MCI2(0,:,:) + MCI(j,:,:)
    MCI2(1,:,:) = MCI2(1,:,:) + MCI(j+3,:,:)
    MCI2(2,:,:) = MCI2(2,:,:) + MCI(j+6,:,:)
    MCI2(3,:,:) = MCI2(3,:,:) + MCI(j+9,:,:)
    n = n + 1
    end do
end do

MCI2 = MCI2 / tofloat(n) 

dd = (abs(MCI1) - abs(MCI2)) * 100
dd!1 = "lat"
dd!2 = "lon"
dd&lat = u&lat
dd&lon = u&lon



;=============================== plotting ==========================

;type = "x11"
type = "png"

 wks = gsn_open_wks(type,"mci_monthly")

 gsn_define_colormap(wks,"MPL_coolwarm")

res_m = True

res_m@cnFillOn              	= True
res_m@cnLinesOn             	= False
res_m@cnLevelSelectionMode      = "ExplicitLevels"
;res_m@cnLevels              	= fspan(-2,2,9)

res_m@lbTitleOn             	= False
res_m@lbOrientation         	= "Horizontal"
res_m@pmLabelBarHeightF     	= 0.03
res_m@pmLabelBarOrthogonalPosF	= 0.4


res_m@mpLimitMode           	= "Corners"
res_m@mpLeftCornerLatF      	= 20
res_m@mpRightCornerLatF     	= 80

res_m@mpShapeMode           	= "FreeAspect"
res_m@vpWidthF              	= 0.5
res_m@vpHeightF             	= 0.1
res_m@tmXBlabelFontHeightF		= 0.004
res_m@tmYLLabelFontHeightF		= 0.010
;res_m@tmXBMode					= "Manual"
;res_m@tmXBTickSpacingF			= 60

res_m@gsnLeftString             = "JFM"
res_m@cnLevels             		= fspan(-14,14,9)
plot1 = gsn_csm_contour_map(wks,dd(0,:,:),res_m)

res_m@cnLevels             		= fspan(-14,14,9)
plot2 = gsn_csm_contour_map(wks,dd(1,:,:),res_m)

res_m@cnLevels             		= fspan(-18,18,9)
plot3 = gsn_csm_contour_map(wks,dd(2,:,:),res_m)

res_m@cnLevels             		= fspan(-14,14,9)
plot4 = gsn_csm_contour_map(wks,dd(3,:,:),res_m)






















end
