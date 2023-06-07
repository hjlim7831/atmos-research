load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

diro1 = "./Data/"
filo1 = "z.mon.7918.nc"  ; 1979 ~ 2018

a = addfile(diro1+filo1,"r")
 u = a->Z(:,15,6:60-12,:) ; 60 -> 0 degree, "1" -> 1.5 degree

; u = dim_sum_n(uu,1)

dimt = dimsizes(u(:,0,0))
dimy = dimsizes(u(0,:,0))
dimx = dimsizes(u(0,0,:))


 printVarSummary(u)

;;; case 1: winter, 1995 - 2013

ts = (1995-1979)*12
te = (2013-1979)*12-1

u1 = new((/4,dimy,dimx/),float,-999)
u1 = 0
n = 0
do i = 0, 2
	do j = ts+i, te, 12
		u1(0,:,:) = u1(0,:,:) + u(j,:,:)
		u1(1,:,:) = u1(1,:,:) + u(j+3,:,:)
		u1(2,:,:) = u1(2,:,:) + u(j+6,:,:)
		u1(3,:,:) = u1(3,:,:) + u(j+9,:,:)
		n = n + 1
	end do
end do
print(n)
u1 = u1 / tofloat(n)


;;; case 2: winter, 1981 - 2010

ts = (1981-1979)*12
te = (2010-1979)*12-1

u2 = new((/4,dimy,dimx/),float,-999)
u2 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u2(0,:,:) = u2(0,:,:) + u(j,:,:)
		u2(1,:,:) = u2(1,:,:) + u(j+3,:,:)
		u2(2,:,:) = u2(2,:,:) + u(j+6,:,:)
		u2(3,:,:) = u2(3,:,:) + u(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u2 = u2 / tofloat(n)

dd = (u1 - u2)/9.8

dd!1 = "lat"
dd!2 = "lon"
;dd@units = "m s**-1"
dd&lat = u&lat
dd&lon = u&lon

printVarSummary(dd)

type = "x11"
;type = "png"

 wks = gsn_open_wks(type,"Zonal")

 gsn_define_colormap(wks,"ViBlGrWhYeOrRe")

res_m = True

res_m@cnFillOn 				= True
res_m@cnLinesOn 			= False
res_m@cnLevelSelectionMode 	= "ExplicitLevels"
res_m@cnLevels				= fspan(-10,10,21)
;res_m@cnLevels              = fspan(-2,2,9)

res_m@lbTitleOn 			= False
res_m@lbOrientation 		= "Horizontal"
res_m@pmLabelBarHeightF 	= 0.03
res_m@pmLabelBarOrthogonalPosF  = 0.4


res_m@mpLimitMode			= "Corners"
res_m@mpLeftCornerLatF		= 20
res_m@mpRightCornerLatF		= 80

res_m@mpShapeMode			= "FreeAspect"
res_m@vpWidthF				= 0.5
res_m@vpHeightF				= 0.1
res_m@tmXBlabelFontHeightF      = 0.004
res_m@tmYLLabelFontHeightF      = 0.010


plot1 = gsn_csm_contour_map(wks,dd(0,:,:),res_m)
plot2 = gsn_csm_contour_map(wks,dd(1,:,:),res_m)
plot3 = gsn_csm_contour_map(wks,dd(2,:,:),res_m)
plot4 = gsn_csm_contour_map(wks,dd(3,:,:),res_m)

;plot1 = gsn_csm_contour_map(wks,u1(0,:,:),res_m)
;plot2 = gsn_csm_contour_map(wks,u2(0,:,:),res_m)


;plot1 = gsn_csm_contour_map(wks,u(0,:,:),res_m)

;print(u1-u2)
end

