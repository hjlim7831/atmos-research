undef("add_right_title")
function add_right_title(wks,plot,title)
local txres,font_height_txid,amres
begin

txres                   = True
txres@txAngleF          = 90.
txres@txFontHeightF     = 0.035

txid = gsn_create_text(wks,title, txres)

amres                   = True
amres@amParallelPosF    = -0.80

amres@amOrthogonalPosF  = 0.00
;amres@amJust            = "CenterCenter"

annoid = gsn_add_annotation(plot,txid,amres)
return(annoid)
end
;----------------------------------------------------------------------
; This function sets the gsnSpreadXXX resources necessary to correctly
; span a two-color colortable.
;
; lower  = cnMinLevelValF
; upper  = cnMaxLevelValF
; step   = cnLevelSpacingF
; center = The numerical value the colormap is centered on. For
;          anomalies or trends, it's common to use 0.0, so blue means
;          cold or cooling and red means warm or warming.
; color_end = The number of colors in colormap (ex. 97 for BlRe, 253
;             for BlueRed)
; center_color = Color value on the left of the "center" value
; (see above).
;----------------------------------------------------------------------

undef("gsnColorRange")
function gsnColorRange(lower:numeric, upper:numeric, step:numeric, \
                       center:numeric, color_end:integer, center_color:integer)
local nboxes_left, nboxes_right, ncolors_left, ncolors_right, output, \
      color_start
begin

 color_start = 2 ; All of the color maps begin with 2.
;
; Calculate the number of color bar boxes to the left and right of
; the "center" value.
;
tnum = tointeger((upper-lower)/step + 1) +1
ncolors_left = (center_color - color_start + 1)
ncolors_right = (color_end - center_color)

output = True

if(abs(lower) .lt. abs(upper))then
	nboxes_left  = (center - (lower - step))/step
	nboxes_right = ((upper + 2*step) - center)/step
	output@ColorStart = round(center_color - (ncolors_right/nboxes_right)*nboxes_left, 3)
	output@ColorEnd   = color_end

else if(abs(lower) .gt. abs(upper)) then
	nboxes_left = (center - (lower - 2*step))/step
	nboxes_right = ((upper + step) - center)/step
	output@ColorStart = 2
	output@ColorEnd = round(center_color + (ncolors_left/nboxes_left)*nboxes_right, 3)

else
	nboxes_left = (center - (lower - 2*step))/step
	nboxes_right = ((upper + step) - center)/step
	output@ColorStart = 2
	output@ColorEnd = color_end
end if
end if

  output@ColorIndex = round(fspan(output@ColorStart,output@ColorEnd,tnum),3)



 return(output)

end

;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------


begin

diro1 = "~/archive/ERA5_data/boxGRIB/monthly/70-40-0-170_1979-2019/"

fil5 = "ERA5monthly_SSTlarge_1979-2019.nc"
;fil1 : t2m, skt, fil2 : z(200, 500, 850)

tlat = 40
blat = 34
llon = 124
rlon = 130


varlen = 1

file5 = addfile(diro1+fil5,"r")
lon = file5->longitude
lat = file5->latitude
time = file5->time

li = ind(llon.eq.lon)
ri = ind(rlon.eq.lon)
tj = ind(tlat.eq.lat)
bj = ind(blat.eq.lat)


sst = file5->sst


dtime = dimsizes(sst(:,0,0))
dlat = dimsizes(sst(0,:,0))
dlon = dimsizes(sst(0,0,:))

varbox = new((/varlen,dtime,dlat,dlon/),double,-32767.)

sf = sst@scale_factor
ofs = sst@add_offset
varbox(0,:,:,:) = (sst*sf)+ofs-273.15


vTITLE = new((/varlen,3/),string)
vTITLE = " "
vTITLE(0,0) = "SST"

TITLE = new((/varlen,3/),string)

TITLE(0,0) = "(a)                2018"
TITLE(0,1) = "(b)          1979 - 2019"
TITLE(0,2) = "(c)             anomaly"

lbTITLE = new((/varlen,3/),string)

lbTITLE(0,:) = "(~S2~o  C)"


lRANGE = new((/3,varlen,3/),float)
;==============min, max, step
;== composite
lRANGE(:,0,0) = (/0.,36.,3./)

;== anomaly
lRANGE(:,0,2) = (/-2,2,0.2/)


lRANGE(:,0,1) = lRANGE(:,0,0)



;================== plot conditions ===============

plots = new(varlen*3,graphic)
plots_ov = new((/2,2/),graphic)
amid = new(varlen*3,graphic)

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,"Synoptic_SurfaceFor")

mpres                               = True
mpres@gsnFrame                      = False
mpres@gsnDraw                       = False
;mpres@gsnMaximize					= True

;mpres@mpProjection                  = "CylindricalEqualdistant"
mpres@mpFillOn                      = False
mpres@cnFillOn                      = True
mpres@cnLineLabelsOn                = False
mpres@cnLinesOn                     = False

mpres@gsnAddCyclic                  = False
mpres@mpLimitMode                   = "LatLon"

mpres@mpMinLatF                     = min(lat) +1
mpres@mpMaxLatF                     = max(lat) -5
mpres@mpMinLonF                     = min(lon) +40
mpres@mpMaxLonF                     = max(lon) -1
;mpres@mpMinLatF						 = 34
;mpres@mpMaxLatF						 = 40
;mpres@mpMinLonF						 = 124
;mpres@mpMaxLonF						 = 130

;mpres@mpNationalLineThicknessF     = 3.0
mpres@mpGeophysicalLineThicknessF   = 2.0
;mpres@mpLimbLineThicknessF         = 2.0
mpres@tmBorderThicknessF            = 2.0
mpres@tmXBMajorThicknessF           = 2.0
mpres@tmYLMajorThicknessF           = 2.0
mpres@lbBoxLineThicknessF           = 2.0


mpres@pmTickMarkDisplayMode         = "Always"
;mpres@tmXBOn                        = True
;mpres@tmYLOn                        = True

;mpres@tmXBMode                     = "Explicit"
;mpres@tmXBValues                   = ispan(40,170,20)
;mpres@tmXBLabels                   = ispan(40,170,20) + " E"
;mpres@tmYLValues                   = ispan(0,70,10)
;mpres@tmYLLabels                   = ispan(0,70,10) + " N"

mpres@pmLabelBarWidthF				= 0.15
mpres@pmLabelBarHeightF				= 0.6
mpres@lbLabelFontHeightF            = 0.030
mpres@pmLabelBarOrthogonalPosF		= 0.05
mpres@pmLabelBarParallelPosF		= 0.6
mpres@lbTitleFontHeightF			= 0.030
mpres@lbTitleJust					= "CenterLeft"
mpres@lbTitlePosition				= "Top"
;mpres@lbTitleDirection				= "Across"
mpres@lbOrientation					= "vertical"


mpres@gsnLeftStringParallelPosF		= 0.0
mpres@gsnLeftStringOrthogonalPosF	= 0.02


;================== varbox : varlen X dtime X dlat X dlon
;================= do loop section
do ii = 0, varlen -1

var = varbox(ii,:,:,:)

;printVarSummary(var)

mvar = new((/dlat,dlon/),double,-32767.)
mvar = 0.
n = 0
do i = 0, dtime -1
	if (mod(i,12) .eq. 6 .or. mod(i,12) .eq. 7) then
		mvar = mvar + var(i,:,:)
		n = n + 1
	end if
end do

mvar = mvar/tofloat(n)

tst = dtime -24
ted = dtime -13

mvar_2018 = new((/dlat,dlon/),double,-32767.)
mvar_2018 = 0.
n = 0
do i = tst, ted
	if (mod(i,12) .eq. 6 .or. mod(i,12) .eq. 7) then
		mvar_2018 = mvar_2018 + var(i,:,:)
		n = n + 1
	end if
end do

mvar_2018 = mvar_2018/tofloat(n)


mvar_ano = mvar_2018 - mvar

print(max(mvar_ano(bj:tj,li:ri)))
print(min(mvar_ano(bj:tj,li:ri)))

fvarbox = new((/3,dlat,dlon/),double,-32767.)

fvarbox(0,:,:) = mvar_2018
fvarbox(1,:,:) = mvar
fvarbox(2,:,:) = mvar_ano

do jj = 0, 2

fvar = fvarbox(jj,:,:)

grid_min = lRANGE(0,ii,jj)
grid_max = lRANGE(1,ii,jj)
grid_step = lRANGE(2,ii,jj)
grid_center = 0.0
w_num = (grid_max-grid_min)/grid_step +1

if (jj .eq. 2)   then

	gsn_range = gsnColorRange(grid_min,grid_max,grid_step,grid_center,101,52)
	cmap = read_colormap_file("BlWhRe")

	mpres@cnFillPalette	= cmap(gsn_range@ColorStart-2:gsn_range@ColorEnd-2,:)

else if ii .le. 3 then

	mpres@cnFillPalette = "MPL_YlOrRd"

else
	mpres@cnFillPalette = "cmocean_dense"

end if
end if

if jj .eq. 0 then
	mpres@lbLabelBarOn = False
;	mpres@gsnLeftStringOrthogonalPosF 	= 0.05
;	mpres@gsnLeftStringFontHeightF      = 0.044
	mpres@tmXBLabelFontHeightF          = 0.022
	mpres@tmYLLabelFontHeightF          = 0.022
else
	mpres@lbLabelBarOn = True
	mpres@gsnLeftStringOrthogonalPosF = -0.15
	mpres@gsnLeftStringFontHeightF      = 0.048
	mpres@tmXBLabelFontHeightF          = 0.030
	mpres@tmYLLabelFontHeightF          = 0.030

end if

i1 = mod(ii,6)
j1 = mod(jj,6)

mpres@cnLevelSelectionMode      = "ManualLevels"
mpres@cnMinLevelValF            = grid_min
mpres@cnMaxLevelValF            = grid_max
mpres@cnLevelSpacingF           = grid_step
;mpres@gsnLeftString				= TITLE(i1,j1)
mpres@lbTitleString				= lbTITLE(ii,jj)
mpres@lbTitleDirection			= "Across"



fvar!0 = "XLAT"
fvar!1 = "XLONG"

fvar&XLONG = lon
fvar&XLAT = lat

;============= plotting section 2 ===============

plot = gsn_csm_contour_map(wks,fvar,mpres)

getvalues plot@contour
 "cnLevels" : levels
end getvalues

mpres@lbLabelStrings	= sprintf("%g",levels)
plots(ii*3+jj) = gsn_csm_contour_map(wks,fvar,mpres)

amid(ii*3+jj) = add_right_title(wks,plots(ii*3+jj),vTITLE(ii,jj))

print(ii*3+jj)

sres								= True
sres@gsnFrame						= False
sres@gsnDraw						= False
sres@cnInfoLabelOn					= False
sres@cnLevelSelectionMode			= "ExplicitLevels"
sres@gsnContourLineThicknessesScale	= 2.0
sres@cnLineColor					= "White"
sres@cnLineLabelsOn					= True
sres@cnLinesOn						= True
sres@cnLevelFlags					= "LineAndLabel"
sres@cnLineLabelPlacementMode		= "Computed"
sres@cnLineLabelDensityF			= 2.5
sres@cnLabelDrawOrder				= "PostDraw"
sres@cnLineLabelFontColor			= "White"
sres@cnLabelMasking					= True
sres@cnLineLabelFontHeightF			= 0.025
sres@cnLineLabelBackgroundColor     = -1

n1 = 0
if ii .eq. 1 then
	if jj .ne. 2 then
		sres@cnLevels		= (/5880./)
		plots_ov(0,n1) = gsn_csm_contour(wks,fvar,sres)
		overlay(plots(ii*3+jj),plots_ov(0,n1))
		n1 = n1 + 1
	end if
end if

n2 = 0
if ii .eq. 2 then
	if jj .ne. 2 then
		sres@cnLevels		= (/12480./)
		plots_ov(1,n2) = gsn_csm_contour(wks,fvar,sres)
		overlay(plots(ii*3+jj),plots_ov(1,n2))
		n2 = n2 + 1
	end if
end if

delete([/fvar,mpres@cnFillPalette,levels,mpres@lbLabelStrings/])

end do

delete([/var/])
end do


plot1 = plots(::3)
plot2 = plots(1::3)
plot3 = plots(2::3)


plot_length = 1./3.

pres							= True
pres@gsnFrame					= False
pres@gsnDraw					= True
pres@gsnPanelLeft				= 0.123
pres@gsnPanelRight				= 0.365
pres@gsnPanelTop                = 0.965
pres@gsnPanelBottom             = 0.03
pres@gsnPanelYWhiteSpacePercent = 5.

gsn_panel(wks,plot1(:),(/varlen,1/),pres)

pres@gsnPanelLeft				= 0.35
pres@gsnPanelRight				= 0.63
pres@gsnPanelTop				= 1.0
pres@gsnPanelBottom				= 0.0
pres@gsnPanelYWhiteSpacePercent = 3.0

gsn_panel(wks,plot2(:),(/varlen,1/),pres)

pres@gsnPanelLeft				= 0.62
pres@gsnPanelRight				= 0.90
pres@gsnPanelTop                = 1.0
pres@gsnPanelBottom             = 0.0
pres@gsnPanelYWhiteSpacePercent = 3.0

gsn_panel(wks,plot3(:),(/varlen,1/),pres)

frame(wks)




end
