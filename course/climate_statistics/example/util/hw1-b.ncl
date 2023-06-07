begin

name = "hw1-b"

diro = "../results/"

pr = "ls "+diro+"csf_sic*.data"

wlis = systemfunc(pr)
nlis = dimsizes(wlis)
print(wlis)

lbtitle = (/"DJF","MAM","JJA","SON"/)

tit = (/"SIC","DLW","2 m T","q1000","q800","q825","q850","q875","q900","q925","q950","q975",\
	"SH","SST","t1000","t700","t750","t775","t800","t825","t850","t875","t900","t925","t950","t975",\
	"u1000","u700","u750","u775","u800","u825","u850","u875","u900","u925","u950","u975",\
	"ULW","v1000","v700","v750","v775","v800","v825","v850","v875","v900","v925","v950","v975",\
	"z1000","z700","z750","z775","z800","z825","z850","z875","z900","z925","z950","z975"/)
print(dimsizes(tit))

MaxF = (/9.,7e06,150.,0.03,0.03,0.03,0.03,0.03,0.03,0.03,0.03,0.03,\
	6e07,60.,130.,40.,50.,50.,50.,50.,60.,60.,70.,90.,100.,120.,\
	30.,60.,50.,50.,40.,40.,40.,40.,40.,30.,30.,30.,\
	9e06,30.,40.,40.,40.,40.,40.,40.,40.,40.,40.,40.,40.,\
	7000.,8000.,8000.,8000.,8000.,8000.,8000.,8000.,7000.,7000.,7000.,7000./)

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
vars(:,0,:,:) = (var(:,0,:,:)+var(:,1,:,:)+var(:,11,:,:))/3.
vars(:,1,:,:) = (var(:,2,:,:)+var(:,3,:,:)+var(:,4,:,:))/3.
vars(:,2,:,:) = (var(:,5,:,:)+var(:,6,:,:)+var(:,7,:,:))/3.
vars(:,3,:,:) = (var(:,8,:,:)+var(:,9,:,:)+var(:,10,:,:))/3.

; ============================================ Plotting Section ===============================================

;type = "x11"
type = "png"
;type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"MPL_RdBu")

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
mpres@lbLabelBarOn                      = False
mpres@gsnLeftStringFontHeightF		= 0.020

pres = True
pres@gsnPanelLabelBar = True
;pres@pmLabelBarWidthF = 0.5
;pres@lbLabelFontHeightF = 0.012

do ii = 0, nlis -1
	print(ii)
        print(max(vars(ii,:,:,:)))
        print(min(vars(ii,:,:,:)))
	mpres@cnMinLevelValF	= -MaxF(ii)
	mpres@cnMaxLevelValF	= MaxF(ii)
	pres@gsnPanelMainString = tit(ii)
	do nn = 0, 3
		pvar = vars(ii,nn,:,:)
		pvar!0 = "XLAT"
		pvar!1 = "XLONG"
		pvar&XLAT = xlat
		pvar&XLONG = xlon
		mpres@gsnLeftString = lbtitle(nn)
		plot(nn,ii) = gsn_csm_contour_map_polar(wks,pvar,mpres)
		delete([/pvar/])
	end do
	gsn_panel(wks,plot(:,ii),(/2,2/),pres)
end do







end
