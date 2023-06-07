begin

name = "hw1-b_t2_djf"

diro = "../results/"

pr1 = "ls "+diro+"csf_sic-t*.data"

wlis = systemfunc(pr1)
nlis = dimsizes(wlis)
print(wlis)

lbtitle = (/"DJF","MAM","JJA","SON"/)

tit = (/"t1000","t700","t750","t775","t800","t825","t850","t875","t900","t925","t950","t975"/)
MaxF = (/40.,30.,30.,30.,30.,30.,30.,40.,30.,30.,30.,30./)

print(dimsizes(tit))

print(dimsizes(MaxF))
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

var = new((/nlis,ntim,nlat,nlon/),float,UNDEF)
do ii = 0, nlis -1
	do nt = 0, ntim -1
		var(ii,nt,:,:) = fbindirread(wlis(ii),nt,(/nlat,nlon/),"float")
	end do
end do

vars = new((/nlis,4,nlat,nlon/),float,UNDEF)
vars(:,0,:,:) = (var(:,12,:,:)+var(:,13,:,:)+var(:,23,:,:))/3.
vars(:,1,:,:) = (var(:,14,:,:)+var(:,15,:,:)+var(:,16,:,:))/3.
vars(:,2,:,:) = (var(:,17,:,:)+var(:,18,:,:)+var(:,19,:,:))/3.
vars(:,3,:,:) = (var(:,20,:,:)+var(:,21,:,:)+var(:,22,:,:))/3.

; ============================================ Plotting Section ===============================================

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"NCV_blu_red")

plot = new((/4,nlis/),graphic)

mpres                                   = True
;mpres@mpProjection                      = "PolarStereographic"
mpres@gsnPolar				= "NH"
mpres@mpMinLatF				= 19.5
mpres@gsnFrame                          = False
mpres@gsnDraw                           = False
mpres@mpFillOn                          = False
mpres@cnFillOn                          = True
mpres@cnLinesOn                         = False
mpres@cnInfoLabelOn			= False
mpres@cnLineLabelsOn			= False
;mpres@mpLimitMode                       = "LatLon"
;mpres@mpMinLatF                         = 30.
;mpres@mpMaxLatF                         = 88.
;mpres@mpMinLonF                         = 0.
;mpres@mpMaxLonF                         = 358.
mpres@cnLevelSelectionMode              = "ManualLevels"
;mpres@mpShapeMode                       = "FreeAspect"
;mpres@lbLabelBarOn                      = False
mpres@gsnLeftStringFontHeightF		= 0.030
mpres@gsnPolarLabelFontHeightF          = 0.02
mpres@lbLabelFontHeightF                = 0.02


pres = True
;pres@gsnPanelLabelBar = True
;pres@pmLabelBarWidthF = 0.5
;pres@lbLabelFontHeightF = 0.012

do ii = 0, nlis -1
	print(ii)
        print(max(vars(ii,0,:,:)))
        print(min(vars(ii,0,:,:)))
	mpres@cnMinLevelValF	= -MaxF(ii)
	mpres@cnMaxLevelValF	= MaxF(ii)
	mpres@gsnLeftString = tit(ii)
	do nn = 0, 3
		pvar = -vars(ii,nn,:,:)
		pvar!0 = "XLAT"
		pvar!1 = "XLONG"
		pvar&XLAT = xlat
		pvar&XLONG = xlon
		plot(nn,ii) = gsn_csm_contour_map_polar(wks,pvar,mpres)
		delete([/pvar/])
	end do
end do

gsn_panel(wks,plot(0,:),(/4,3/),pres)





end
