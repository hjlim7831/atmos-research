begin

diri1 = "../results/"
diri2 = "../data/"
fili3 = "csf_sce.data"

name = "hw2-1_sce"

fName3 = diri1+fili3

lbtitle = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

nlat = 30
mlon = 180

year = 1979
ntim2 = 36
nmos = 12

UNDEF = -999.

pred = new((/ntim2,nlat,mlon/),float,UNDEF)
do nt = 0, ntim2 -1
        pred(nt,:,:) = fbindirread(fName3,nt,(/nlat,mlon/),"float")
end do

printVarSummary(pred)
print("min(pred)="+min(pred))
print("max(pred)="+max(pred))

xlon = ispan(0,358,2)
xlat = ispan(30,88,2)


;==================== Plotting Section ================================

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"MPL_RdBu")

plot = new(ntim2,graphic)

mpres                                   = True
;mpres@mpProjection			= "CylindricalEqualArea"
mpres@gsnFrame				= False
mpres@gsnDraw				= False
mpres@mpFillOn                          = False
mpres@cnFillOn                          = True
mpres@cnLinesOn                         = False
mpres@mpLimitMode                       = "LatLon"
mpres@mpMinLatF                         = 30.
mpres@mpMaxLatF                         = 85.
mpres@mpMinLonF                         = 0.
mpres@mpMaxLonF                         = 180.
mpres@cnLevelSelectionMode              = "ManualLevels"
mpres@mpShapeMode			= "FreeAspect"

mpres@lbLabelBarOn                      = False
mpres@lbOrientation                     = "vertical"
mpres@pmLabelBarWidthF                  = 0.05
mpres@pmLabelBarHeightF                 = 0.15
mpres@lbLabelFontHeightF                = 0.004
mpres@tmXBLabelFontHeightF              = 0.008
mpres@tmYLLabelFontHeightF              = 0.008
mpres@gsnLeftStringHeightF		= 0.01

sres = True
sres@gsnFrame                       = False
sres@gsnDraw                        = False
sres@cnInfoLabelOn                  = False
sres@cnLevelSelectionMode           = "ExplicitLevels"
sres@gsnContourLineThicknessesScale = 2.
;sres@cnLineColor                    = "White"
sres@cnLineLabelsOn                 = False
sres@cnLinesOn                      = True
;sres@cnLevelFlags                   = "LineAndLabel"
;sres@cnLineLabelPlacementMode       = "Computed"
;sres@cnLineLabelDensityF            = 2.5
sres@cnLabelDrawOrder               = "PostDraw"
sres@cnLineLabelFontColor           = "White"
sres@cnLabelMasking                 = True
sres@cnLineLabelFontHeightF         = 0.025
sres@cnLineLabelBackgroundColor     = -1


do ii = 0, ntim2 -1
ij = mod(ii,12)
var = -pred(ii,:,:)
print("max:"+max(var))
print("min:"+min(var))

var!0 = "XLAT"
var!1 = "XLONG"

xlon@units = "degrees_east"
xlat@units = "degrees_north"

mpres@gsnLeftString = lbtitle(ij)

var&XLAT = xlat
var&XLONG = xlon

mpres@cnMinLevelValF    = -8.
mpres@cnMaxLevelValF    = 8.
mpres@cnLevelSpacingF   = 0.8
mpres@vpWidthF		= 0.4
mpres@vpHeightF		= 0.2
;mpres@gsnLeftString     = " "

plot(ii) = gsn_csm_contour_map(wks,var,mpres)

end do

pres = True
pres@gsnPanelLabelBar = True
pres@pmLabelBarWidthF = 0.5
pres@lbLabelFontHeightF = 0.006

;gsn_panel(wks,plot(0:11),(/6,2/),pres)
;gsn_panel(wks,plot(12:23),(/6,2/),pres)
gsn_panel(wks,plot(24:35),(/6,2/),pres)












end
