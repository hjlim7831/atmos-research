begin

name = "hw1-b_djf"

diro = "../results/"


wfile = "csf_sic"+(/"","-rt2m_reg","-dlw_reg","-ulw_reg","-shf_reg","-lhf_reg","-sst_reg"/)+".data"

wlis = diro+wfile
nlis = dimsizes(wlis)
print(wlis)

lbtitle = (/"DJF","MAM","JJA","SON"/)

tit = (/"SIC","2 m T","DLW","ULW","SH","LH","SST","SH+LH"/)
MaxF = (/9.,150.,7e06,9e06,6e07,6e07,60.,8e07/)

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
vars(:,0,:,:) = (var(:,0,:,:)+var(:,1,:,:)+var(:,11,:,:))/3.
vars(:,1,:,:) = (var(:,2,:,:)+var(:,3,:,:)+var(:,4,:,:))/3.
vars(:,2,:,:) = (var(:,5,:,:)+var(:,6,:,:)+var(:,7,:,:))/3.
vars(:,3,:,:) = (var(:,8,:,:)+var(:,9,:,:)+var(:,10,:,:))/3.

; ============================================ Plotting Section ===============================================

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"NCV_blu_red")

plot = new((/4,nlis+1/),graphic)

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
mpres@gsnLeftStringFontHeightF          = 0.030
mpres@gsnPolarLabelFontHeightF          = 0.02
mpres@lbLabelFontHeightF		= 0.02


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
	if ii .eq. 0 .or. ii .eq. 3 then
		pvar = vars(ii,nn,:,:)
	else
		pvar = -vars(ii,nn,:,:)
	end if
		pvar!0 = "XLAT"
		pvar!1 = "XLONG"
		pvar&XLAT = xlat
		pvar&XLONG = xlon
		plot(nn,ii) = gsn_csm_contour_map_polar(wks,pvar,mpres)
		delete([/pvar/])
	end do
end do

mpres@cnMinLevelValF = -MaxF(7)
mpres@cnMaxLevelValF = MaxF(7)
mpres@gsnLeftString = tit(7)

pvar = (vars(4,0,:,:) + vars(5,0,:,:))
pvar!0 = "XLAT"
pvar!1 = "XLONG"
pvar&XLAT = xlat
pvar&XLONG = xlon
print(max(pvar))
print(min(pvar))

plot(0,7) = gsn_csm_contour_map_polar(wks,pvar,mpres)

gsn_panel(wks,plot(0,:),(/4,2/),pres)





end
