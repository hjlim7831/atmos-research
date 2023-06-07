begin

name = "hw1-d_zuv_djf"

diro = "../results/"

pr1 = "ls "+diro+"csf_sic-u*.data"
pr2 = "ls "+diro+"csf_sic-v*.data"
pr3 = "ls "+diro+"csf_sic-z*.data"

llev = (/"850","875","900","925","950","975","1000"/)

wdata1 = "csf_sic-u"+llev+"_reg.data"
wdata2 = "csf_sic-v"+llev+"_reg.data"
wdata3 = "csf_sic-z"+llev+"_reg.data"

wlis1 = diro+wdata1
wlis2 = diro+wdata2
wlis3 = diro+wdata3

nlis = dimsizes(wlis3)
print(wlis1)
print(wlis2)
print(wlis3)

tit = (/"MODE 1","MODE 2"/)
print(dimsizes(tit))

MaxF = (/7000.,3000./)

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

vars = new((/nlis,3,2,nlat,nlon/),float,UNDEF)
vars(:,:,0,:,:) = (var(:,:,0,:,:)+var(:,:,1,:,:)+var(:,:,11,:,:))/3.
vars(:,:,1,:,:) = (var(:,:,12,:,:)+var(:,:,13,:,:)+var(:,:,23,:,:))/3.

fvars = dim_avg_n(vars,0)

; ============================================ Plotting Section ===============================================

;type = "x11"
type = "png"
;type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"NCV_blu_red")

plot = new((/2/),graphic)
ov1 = new((/2/),graphic)
ov2 = new((/2/),graphic)

mpres                                   = True
mpres@gsnFrame				= False
mpres@gsnDraw				= False
;mpres@mpProjection                      = "PolarStereographic"
mpres@gsnPolar				= "NH"
mpres@mpMinLatF				= 19.5
mpres@mpFillOn                          = False
mpres@gsnLeftStringFontHeightF          = 0.030
mpres@gsnPolarLabelFontHeightF		= 0.02

cnres					= True
cnres@gsnFrame                          = False
cnres@gsnDraw                           = False
cnres@cnFillOn                          = True
cnres@cnLinesOn                         = False
cnres@cnInfoLabelOn			= False
cnres@cnLineLabelsOn			= False
cnres@cnLevelSelectionMode              = "ManualLevels"
;cnres@lbLabelBarOn                      = False
cnres@lbLabelFontHeightF		= 0.02

vcres                                   = True
vcres@gsnDraw                           = False
vcres@gsnFrame                          = False
;vcres@stMinLineSpacingF                 = 0.005
vcres@stMinArrowSpacingF		= 0.07
vcres@stMinDistanceF			= 0.05
vcres@stArrowStride			= 1
vcres@stArrowLengthF			= 0.010
vcres@stLineThicknessF			= 0.7


pres = True
;pres@gsnPanelLabelBar = True
;pres@pmLabelBarWidthF = 0.5

do ii = 0, 1
	print(ii)
	cnres@cnMinLevelValF	= -MaxF(ii)
	cnres@cnMaxLevelValF	= MaxF(ii)
	mpres@gsnLeftString = tit(ii)
		pz = -fvars(2,ii,:,:)
		pu = -fvars(0,ii,:,:)
		pv = -fvars(1,ii,:,:)
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
		print(max(pz))
		print(min(pz))
		plot(ii) = gsn_csm_map_polar(wks,mpres)
		ov1(ii) = gsn_csm_contour(wks,pz,cnres)
		ov2(ii) = gsn_csm_streamline(wks,pu,pv,vcres)
		overlay(plot(ii),ov1(ii))
		overlay(plot(ii),ov2(ii))
		delete([/pz,pu,pv/])
end do

gsn_panel(wks,plot(:),(/1,2/),pres)





end
