begin

name = "hw1-b_zuv"

diro = "../results/"

pr1 = "ls "+diro+"csf_sic-u*.data"
pr2 = "ls "+diro+"csf_sic-v*.data"
pr3 = "ls "+diro+"csf_sic-z*.data"

wlis1 = systemfunc(pr1)
wlis2 = systemfunc(pr2)
wlis3 = systemfunc(pr3)

nlis = dimsizes(wlis3)
print(wlis1)
print(wlis2)
print(wlis3)

lbtitle = (/"DJF","MAM","JJA","SON"/)

tit = (/"zuv1000","zuv700","zuv750","zuv775","zuv800","zuv825","zuv850","zuv875","zuv900","zuv925","zuv950","zuv975"/)
print(dimsizes(tit))

MaxF = (/7000.,8000.,8000.,8000.,8000.,8000.,8000.,8000.,7000.,7000.,7000.,7000./)

nlat = 48
nlon = 240
ntim = 24

xlon = fspan(0,358.5,240)
xlat = fspan(19.5,90,48)
xlon@units = "degrees_east"
xlat@units = "degrees_north"

;print(xlon)
;print(xlat)

UNDEF = -999.

var = new((/nlis,3,ntim,nlat,nlon/),float,UNDEF)
do ii = 0, nlis -1
	do nt = 0, ntim -1
		var(ii,0,nt,:,:) = fbindirread(wlis1(ii),nt,(/nlat,nlon/),"float")
		var(ii,1,nt,:,:) = fbindirread(wlis2(ii),nt,(/nlat,nlon/),"float")
		var(ii,2,nt,:,:) = fbindirread(wlis3(ii),nt,(/nlat,nlon/),"float")
	end do
end do

vars = new((/nlis,3,4,nlat,nlon/),float,UNDEF)
vars(:,:,0,:,:) = (var(:,:,0,:,:)+var(:,:,1,:,:)+var(:,:,11,:,:))/3.
vars(:,:,1,:,:) = (var(:,:,2,:,:)+var(:,:,3,:,:)+var(:,:,4,:,:))/3.
vars(:,:,2,:,:) = (var(:,:,5,:,:)+var(:,:,6,:,:)+var(:,:,7,:,:))/3.
vars(:,:,3,:,:) = (var(:,:,8,:,:)+var(:,:,9,:,:)+var(:,:,10,:,:))/3.

; ============================================ Plotting Section ===============================================

;type = "x11"
type = "png"
;type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"MPL_RdBu")

plot = new((/4,nlis/),graphic)
ov1 = new((/4,nlis/),graphic)
ov2 = new((/4,nlis/),graphic)

mpres                                   = True
mpres@gsnFrame				= False
mpres@gsnDraw				= False
;mpres@mpProjection                      = "PolarStereographic"
mpres@gsnPolar				= "NH"
mpres@mpMinLatF				= 19.5
mpres@mpFillOn                          = False
mpres@gsnLeftStringFontHeightF          = 0.020

cnres					= True
cnres@gsnFrame                          = False
cnres@gsnDraw                           = False
cnres@cnFillOn                          = True
cnres@cnLinesOn                         = False
cnres@cnInfoLabelOn			= False
cnres@cnLineLabelsOn			= False
cnres@cnLevelSelectionMode              = "ManualLevels"
cnres@lbLabelBarOn                      = False

vcres                                   = True
vcres@gsnDraw                           = False
vcres@gsnFrame                          = False
;vcres@stMinLineSpacingF                 = 0.005
vcres@stMinArrowSpacingF		= 0.05
vcres@stMinDistanceF			= 0.025
vcres@stArrowStride			= 1
vcres@stArrowLengthF			= 0.010
vcres@stLineThicknessF			= 2.0


pres = True
pres@gsnPanelLabelBar = True
;pres@pmLabelBarWidthF = 0.5
;pres@lbLabelFontHeightF = 0.012

do ii = 0, nlis -1
	print(ii)
	cnres@cnMinLevelValF	= -MaxF(ii)
	cnres@cnMaxLevelValF	= MaxF(ii)
	pres@gsnPanelMainString = tit(ii)
	do nn = 0, 3
		pz = vars(ii,2,nn,:,:)
		pu = vars(ii,0,nn,:,:)
		pv = vars(ii,1,nn,:,:)
		pz!0 = "XLAT"
		pz!1 = "XLONG"
		pz&XLAT = xlat
		pz&XLONG = xlon
                pu!0 = "XLAT"
                pu!1 = "XLONG"
                pu&XLAT = xlat
                pu&XLONG = xlon
                pv!0 = "XLAT"
                pv!1 = "XLONG"
                pv&XLAT = xlat
                pv&XLONG = xlon

		mpres@gsnLeftString = lbtitle(nn)
		plot(nn,ii) = gsn_csm_map_polar(wks,mpres)
		ov1(nn,ii) = gsn_csm_contour(wks,pz,cnres)
		ov2(nn,ii) = gsn_csm_streamline(wks,pu,pv,vcres)
		overlay(plot(nn,ii),ov1(nn,ii))
		overlay(plot(nn,ii),ov2(nn,ii))
		delete([/pz,pu,pv/])
	end do
	gsn_panel(wks,plot(:,ii),(/2,2/),pres)
end do







end
