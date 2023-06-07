begin

diri1 = "../results/"
fili1 = "avg_sce.d"

name = "hw2-1_sce_monthly"

fName1 = diri1+fili1

lbtitle = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

nlat = 30
mlon = 180

year = 1979
ntim2 = 432
ntim = 4
nmos = 12

UNDEF = -999.

data = asciiread(fName1,(/10800,6/),"float")

avgsce = reshape(data,(/nmos,nlat,mlon/))

print("min(avgsce)="+min(avgsce))
print("max(avgsce)="+max(avgsce))

xlon = ispan(0,358,2)
xlat = ispan(30,88,2)


;==================== Plotting Section ================================

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,name)

;cmap = read_colormap_file("hotcold_18lev")
;cmap = cmap(::-1,:)
cmap = read_colormap_file("MPL_RdBu")

plot = new(nmos,graphic)
plot_ov = new((/2,nmos/),graphic)

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
mpres@cnFillPalette			= cmap

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


do ii = 0, nmos -1
var = avgsce(ii,:,:) - dim_avg_n(avgsce,0)
print("max:"+max(var))
print("min:"+min(var))

var!0 = "XLAT"
var!1 = "XLONG"

xlon@units = "degrees_east"
xlat@units = "degrees_north"

mpres@gsnLeftString = lbtitle(ii)

var&XLAT = xlat
var&XLONG = xlon

mpres@cnMinLevelValF    = -1.
mpres@cnMaxLevelValF    = 1.
mpres@cnLevelSpacingF   = 0.1
mpres@vpWidthF		= 0.4
mpres@vpHeightF		= 0.2
;mpres@gsnLeftString     = " "

plot(ii) = gsn_csm_contour_map(wks,var,mpres)

end do

pres = True
pres@gsnPanelLabelBar = True
pres@pmLabelBarWidthF = 0.5
pres@lbLabelFontHeightF = 0.006

gsn_panel(wks,plot,(/6,2/),pres)











;/
end
