begin

name = "hw2-b_seasonal"

diro = "../results/"


wfile = "csf_sce"+(/"-rt2m_reg","-sic_reg","-z850_reg","-u850_reg","-v850_reg"/)+".data"

wlis = diro+wfile
nlis = dimsizes(wlis)
print(wlis)

lbtitle = (/"DJF","MAM","JJA","SON"/)

tit = (/"SCE","2 m T","SIC","zuv850"/)
ntit = dimsizes(tit)

MaxF = (/12.,120.,8.,7000./)

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


sce = new((/ntim,30,180/),float,UNDEF)
do nt = 0, ntim -1
	sce(nt,:,:) = fbindirread(diro+"csf_sce.data",nt,(/30,180/),"float")
end do

xlat1 = ispan(30,88,2)
xlon1 = ispan(0,358,2)
xlat1@units = "degrees_north"
xlon1@units = "degrees_east"

vars = new((/nlis,4,nlat,nlon/),float,UNDEF)
vars(:,0,:,:) = (var(:,0,:,:)+var(:,1,:,:)+var(:,11,:,:))/3.
vars(:,1,:,:) = (var(:,2,:,:)+var(:,3,:,:)+var(:,4,:,:))/3.
vars(:,2,:,:) = (var(:,5,:,:)+var(:,6,:,:)+var(:,7,:,:))/3.
vars(:,3,:,:) = (var(:,8,:,:)+var(:,9,:,:)+var(:,10,:,:))/3.

sces = new((/4,30,180/),float,UNDEF)
sces(0,:,:) = (sce(0,:,:)+sce(1,:,:)+sce(11,:,:))/3.
sces(1,:,:) = (sce(2,:,:)+sce(3,:,:)+sce(4,:,:))/3.
sces(2,:,:) = (sce(5,:,:)+sce(6,:,:)+sce(7,:,:))/3.
sces(3,:,:) = (sce(8,:,:)+sce(9,:,:)+sce(10,:,:))/3.


; ============================================ Plotting Section ===============================================

;type = "x11"
type = "png"
;type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"NCV_blu_red")

plot = new((/4,ntit/),graphic)

mpres                                   = True
mpres@gsnFrame                          = False
mpres@gsnDraw                           = False
mpres@mpFillOn                          = False
mpres@cnFillOn                          = True
mpres@cnLinesOn                         = False
mpres@cnInfoLabelOn			= False
mpres@cnLineLabelsOn			= False
mpres@mpLimitMode                       = "LatLon"
mpres@mpMinLatF                         = 30.
mpres@mpMaxLatF                         = 85.
mpres@mpMinLonF                         = 0.
mpres@mpMaxLonF                         = 180.
mpres@cnLevelSelectionMode              = "ManualLevels"
;mpres@mpShapeMode                       = "FreeAspect"
;mpres@vpWidthF				= 0.4
;mpres@vpHeightF			= 0.3
;mpres@lbLabelBarOn                      = False
mpres@gsnLeftStringFontHeightF          = 0.020
mpres@gsnRightStringFontHeightF          = 0.020
mpres@lbLabelFontHeightF		= 0.010
mpres@lbLabelBarOn                      = False
mpres@tmXBLabelFontHeightF		= 0.015
mpres@tmYLLabelFontHeightF		= 0.015

pres = True
pres@gsnPanelLabelBar = True
;pres@pmLabelBarWidthF = 0.5
pres@lbLabelFontHeightF = 0.010




        print(max(sce(0,:,:)))
        print(min(sce(0,:,:)))

mpres@cnMinLevelValF    = -MaxF(0)
mpres@cnMaxLevelValF    = MaxF(0)
mpres@gsnRightString = tit(0)
do nn = 0, 3
	mpres@gsnLeftString = lbtitle(nn)
	pvar = -sce(nn,:,:)
        pvar!0 = "XLAT"
        pvar!1 = "XLONG"
        pvar&XLAT = xlat1
        pvar&XLONG = xlon1
        plot(nn,0) = gsn_csm_contour_map(wks,pvar,mpres)
        delete([/pvar/])
end do


do ii = 1, ntit -2
	iv = ii -1
	print(ii)
        print(max(vars(iv,0,:,:)))
        print(min(vars(iv,0,:,:)))
	mpres@cnMinLevelValF	= -MaxF(ii)
	mpres@cnMaxLevelValF	= MaxF(ii)
	mpres@gsnRightString = tit(ii)
	do nn = 0, 3
	mpres@gsnLeftString = lbtitle(nn)
;	if ii .eq. 0 .or. ii .eq. 3 then
;		pvar = vars(iv,nn,:,:)
;	else
		pvar = vars(iv,nn,:,:)
;	end if
		pvar!0 = "XLAT"
		pvar!1 = "XLONG"
		pvar&XLAT = xlat
		pvar&XLONG = xlon
		plot(nn,ii) = gsn_csm_contour_map(wks,pvar,mpres)
		delete([/pvar/])
	end do
end do

mpres@cnMinLevelValF = -MaxF(3)
mpres@cnMaxLevelValF = MaxF(3)
mpres@gsnLeftString = tit(3)

vcres                                   = True
vcres@gsnDraw                           = False
vcres@gsnFrame                          = False
;vcres@stMinLineSpacingF                 = 0.005
vcres@stMinArrowSpacingF                = 0.07
vcres@stMinDistanceF                    = 0.05
vcres@stArrowStride                     = 1
vcres@stArrowLengthF                    = 0.010
vcres@stLineThicknessF                  = 0.7

ov1 = new(4,graphic)
ov2 = new(4,graphic)

mres = mpres
mres@gsnLeftString = ""
mres@gsnRightString = ""

mpres@gsnRightString = tit(3)
do nn = 0, 3
mpres@gsnLeftString = lbtitle(nn)
pvar = -vars(2,nn,:,:)
pvar!0 = "XLAT"
pvar!1 = "XLONG"
pvar&XLAT = xlat
pvar&XLONG = xlon
pu = -vars(3,nn,:,:)
pv = -vars(4,nn,:,:)
pu!0 = "XLAT"
pu!1 = "XLONG"
pu&XLAT = xlat
pu&XLONG = xlon
pv!0 = "XLAT"
pv!1 = "XLONG"
pv&XLAT = xlat
pv&XLONG = xlon
plot(nn,3) = gsn_csm_map(wks,mpres)
ov1(nn) = gsn_csm_contour(wks,pvar,mres)
ov2(nn) = gsn_csm_streamline(wks,pu,pv,vcres)
overlay(plot(nn,3),ov1(nn))
overlay(plot(nn,3),ov2(nn))
delete([/pvar,pu,pv/])
end do



do ii = 0, ntit -1
	gsn_panel(wks,plot(:,ii),(/2,2/),pres)
end do





end
