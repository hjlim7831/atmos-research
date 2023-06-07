undef("add_right_title")
function add_right_title(wks,plot,title)
local txres,font_height_txid,amres
begin

txres                   = True
txres@txAngleF          = 90.
txres@txFontHeightF     = 0.045

txid = gsn_create_text(wks,title, txres)

amres                   = True
amres@amParallelPosF    = -0.80

amres@amOrthogonalPosF  = 0.05
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

fil1 = "ERA5monthly_sfc_1979-2019.nc"
fil2 = "ERA5monthly_multi_1973-2019.nc"
fil3 = "ERA5monthly_OLR_1979-2019.nc"
fil4 = "ERA5monthly_prc_1979-2019.nc"
fil5 = "ERA5monthly_SST_1979-2019.nc"
;fil1 : t2m, skt, fil2 : z(200, 500, 850)

tlat = 40
blat = 34
llon = 124
rlon = 130


varlen = 6+6

file1 = addfile(diro1+fil1,"r")
file3 = addfile(diro1+fil3,"r")
file4 = addfile(diro1+fil4,"r")
file5 = addfile(diro1+fil5,"r")
lon = file1->longitude
lat = file1->latitude
time = file1->time

li = ind(llon.eq.lon)
ri = ind(rlon.eq.lon)
tj = ind(tlat.eq.lat)
bj = ind(blat.eq.lat)


T2 = file1->t2m
skT = file1->skt
olr = file3->mtnlwrf
swv1 = file1->swvl1
swv2 = file1->swvl2
swv3 = file1->swvl3
swv4 = file1->swvl4
pr = file4->tp
sst = file5->sst

dtime = dimsizes(T2(:,0,0))
dlat = dimsizes(T2(0,:,0))
dlon = dimsizes(T2(0,0,:))

varbox = new((/varlen,dtime,dlat,dlon/),double,-32767.)

sf = T2@scale_factor
ofs = T2@add_offset
varbox(0,:,:,:) = (T2*sf)+ofs -273.15 ; T2

sf = skT@scale_factor
ofs = skT@add_offset

varbox(1,:,:,:) = (skT*sf)+ofs -273.15 ; skT

sf = olr@scale_factor
ofs = olr@add_offset

varbox(2,:,:,:) = -((olr*sf)+ofs) ; olr
;varbox(2,:,:,:) = olr

sf = swv1@scale_factor
ofs = swv1@add_offset
varbox(6,:,:,:) = (swv1*sf)+ofs

sf = swv2@scale_factor
ofs = swv2@add_offset
varbox(7,:,:,:) = (swv2*sf)+ofs

sf = swv3@scale_factor
ofs = swv3@add_offset
varbox(8,:,:,:) = (swv3*sf)+ofs

sf = swv4@scale_factor
ofs = swv4@add_offset
varbox(9,:,:,:) = (swv4*sf)+ofs

sf = pr@scale_factor
ofs = pr@add_offset
varbox(10,:,:,:) = ((pr*sf)+ofs)*1000.

sf = sst@scale_factor
ofs = sst@add_offset
varbox(11,:,:,:) = (sst*sf)+ofs-273.15


file2 = addfile(diro1+fil2,"r")

z = file2->z

sf = z@scale_factor
ofs = z@add_offset

varbox(3,:,:,:) = ((z(:,2,:,:)*sf)+ofs)/9.8 ; z850
varbox(4,:,:,:) = ((z(:,1,:,:)*sf)+ofs)/9.8 ; z500
varbox(5,:,:,:) = ((z(:,0,:,:)*sf)+ofs)/9.8 ; z200

vTITLE = new((/varlen,3/),string)
vTITLE = " "
vTITLE(0,0) = "2 m Temperature"
vTITLE(1,0) = "Skin Temperature"
vTITLE(2,0) = "OLR"
vTITLE(3,0) = "H850"
vTITLE(4,0) = "H500"
vTITLE(5,0) = "H200"
vTITLE(6,0) = "soil moisture L1"
vTITLE(7,0) = "soil moisture L2"
vTITLE(8,0) = "soil moisture L3"
vTITLE(9,0) = "soil moisture L4"
vTITLE(10,0) = "Total Precipitation"
vTITLE(11,0) = "SST"

TITLE = new((/varlen,3/),string)

TITLE(0,0) = "(a)                2018"
TITLE(0,1) = "(b)          1979 - 2019"
TITLE(0,2) = "(c)             anomaly"
TITLE(1,:) = (/"(d)","(e)","(f)"/)
TITLE(2,:) = (/"(g)","(h)","(i)"/)
TITLE(3,:) = (/"(j)","(k)","(l)"/)
TITLE(4,:) = (/"(m)","(n)","(o)"/)
TITLE(5,:) = (/"(p)","(q)","(r)"/)

lbTITLE = new((/varlen,3/),string)

lbTITLE(:1,:) = "(~S2~o  C)"
lbTITLE(2,:)  = "(W m~S2~-2  )"
lbTITLE(3:5,:) = "(m)"
lbTITLE(6:9,:) = "(m~S2~3  m~S2~-3  )"
lbTITLE(10,:) = "(mm)"
lbTITLE(11,:) = "(~S2~o  C)"


lRANGE = new((/3,varlen,3/),float)
;==============min, max, step
;== composite
;;;;;;;;one
lRANGE(:,0,0) = (/0.,36.,4./)
lRANGE(:,1,0) = (/0.,36.,4./)
lRANGE(:,2,0) = (/160.,280.,10./)
lRANGE(:,3,0) = (/1400.,1560.,20./)
lRANGE(:,4,0) = (/5550.,5900.,50./)
lRANGE(:,5,0) = (/11900.,12600.,100./)
;;;;;;;;two
lRANGE(:,6,0) = (/0.,0.8,0.1/)
lRANGE(:,7,0) = (/0.,0.8,0.1/)
lRANGE(:,8,0) = (/0.,0.8,0.1/)
lRANGE(:,9,0) = (/0.,0.8,0.1/)
lRANGE(:,10,0) = (/0.,28.,2./)
lRANGE(:,11,0) = (/0.,36.,3./)

;== anomaly
;;;;;;;;one
lRANGE(:,0,2) = (/-1.6,3.2,0.4/)
lRANGE(:,1,2) = (/-1.6,3.2,0.4/)
lRANGE(:,2,2) = (/-40.,30.,5./)
lRANGE(:,3,2) = (/-20.,36.,4./)
lRANGE(:,4,2) = (/-20.,70.,10./)
lRANGE(:,5,2) = (/-20.,140.,20./)
;;;;;;;two
lRANGE(:,6,2) = (/-0.14,0.08,0.02/)
lRANGE(:,7,2) = (/-0.14,0.08,0.02/)
lRANGE(:,8,2) = (/-0.18,0.08,0.02/)
lRANGE(:,9,2) = (/-0.14,0.18,0.02/)
lRANGE(:,10,2) = (/-4.,10.,1./)
lRANGE(:,11,2) = (/-2.,2.,0.2/)



lRANGE(:,0,1) = lRANGE(:,0,0)
lRANGE(:,1,1) = lRANGE(:,1,0)
lRANGE(:,2,1) = lRANGE(:,2,0)
lRANGE(:,3,1) = lRANGE(:,3,0)
lRANGE(:,4,1) = lRANGE(:,4,0)
lRANGE(:,5,1) = lRANGE(:,5,0)
lRANGE(:,6,1) = lRANGE(:,6,0)
lRANGE(:,7,1) = lRANGE(:,7,0)
lRANGE(:,8,1) = lRANGE(:,8,0)
lRANGE(:,9,1) = lRANGE(:,9,0)
lRANGE(:,10,1) = lRANGE(:,10,0)
lRANGE(:,11,1) = lRANGE(:,11,0)



;================== plot conditions ===============

plots = new(varlen*3,graphic)
plots_ov = new((/2,2/),graphic)
amid = new(varlen*3,graphic)

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,"Synoptic_Surface")

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

;mpres@mpMinLatF                     = min(lat) +5
;mpres@mpMaxLatF                     = max(lat) -5
;mpres@mpMinLonF                     = min(lon) +40
;mpres@mpMaxLonF                     = max(lon) -1
mpres@mpMinLatF                      = 34
mpres@mpMaxLatF                      = 40
mpres@mpMinLonF                      = 124
mpres@mpMaxLonF                      = 130


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
mpres@tmXBLabelFontHeightF          = 0.030
mpres@tmYLLabelFontHeightF          = 0.030

;mpres@tmXBMode                     = "Explicit"
;mpres@tmXBValues                   = ispan(40,170,20)
;mpres@tmXBLabels                   = ispan(40,170,20) + " E"
;mpres@tmYLValues                   = ispan(0,70,10)
;mpres@tmYLLabels                   = ispan(0,70,10) + " N"

mpres@pmLabelBarWidthF				= 0.8
mpres@pmLabelBarHeightF				= 0.15
mpres@lbLabelFontHeightF            = 0.030
mpres@pmLabelBarOrthogonalPosF		= 0.15
mpres@pmLabelBarParallelPosF		= 0.6
mpres@lbTitleFontHeightF			= 0.030
mpres@lbTitleJust					= "CenterLeft"
mpres@lbTitlePosition				= "Right"
mpres@lbTitleDirection				= "Across"

mpres@gsnLeftStringFontHeightF		= 0.040
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

else if ii .eq. 11 .or. ii .le. 5 then

	mpres@cnFillPalette = "MPL_YlOrRd"

else
	mpres@cnFillPalette = "cmocean_dense"

end if
end if

i1 = mod(ii,6)
j1 = mod(jj,6)

mpres@cnLevelSelectionMode      = "ManualLevels"
mpres@cnMinLevelValF            = grid_min
mpres@cnMaxLevelValF            = grid_max
mpres@cnLevelSpacingF           = grid_step
mpres@gsnLeftString				= TITLE(i1,j1)
mpres@lbTitleString				= lbTITLE(ii,jj)
mpres@lbTitleDirection			= "Across"



fvar!0 = "XLAT"
fvar!1 = "XLONG"

fvar&XLONG = lon
fvar&XLAT = lat


;============= plotting section 2 ===============

plots(ii*3+jj) = gsn_csm_contour_map(wks,fvar,mpres)
amid(ii*3+jj) = add_right_title(wks,plots(ii*3+jj),vTITLE(ii,jj))

print(ii*3+jj)

sres								= True
sres@gsnFrame						= False
sres@gsnDraw						= False
sres@cnInfoLabelOn					= False
sres@cnLevelSelectionMode			= "ExplicitLevels"
sres@gsnContourLineThicknessesScale	= 4.0
sres@cnLineColor					= "Green"
sres@cnLineLabelsOn					= True
sres@cnLinesOn						= True
sres@cnLevelFlags					= "LineAndLabel"
sres@cnLineLabelPlacementMode		= "Computed"
sres@cnLineLabelDensityF			= 2.5
sres@cnLabelDrawOrder				= "PostDraw"
sres@cnLineLabelFontHeightF			= 0.025
sres@cnLineLabelBackgroundColor     = "white"

n1 = 0
if ii .eq. 4 then
	if jj .ne. 2 then
		sres@cnLevels		= (/5880./)
		plots_ov(0,n1) = gsn_csm_contour(wks,fvar,sres)
		overlay(plots(ii*3+jj),plots_ov(0,n1))
		n1 = n1 + 1
	end if
end if

n2 = 0
if ii .eq. 5 then
	if jj .ne. 2 then
		sres@cnLevels		= (/12480./)
		plots_ov(1,n2) = gsn_csm_contour(wks,fvar,sres)
		overlay(plots(ii*3+jj),plots_ov(1,n2))
		n2 = n2 + 1
	end if
end if
		

delete([/fvar,mpres@cnFillPalette/])

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
pres@gsnPanelLeft				= 0.14
pres@gsnPanelRight				= pres@gsnPanelLeft + plot_length

gsn_panel(wks,plot1(:5),(/varlen/2,1/),pres)

pres@gsnPanelLeft				= plot_length
pres@gsnPanelRight				= pres@gsnPanelLeft + plot_length

gsn_panel(wks,plot2(:5),(/varlen/2,1/),pres)

pres@gsnPanelLeft				= plot_length *2-0.28
pres@gsnPanelRight				= 1.0

gsn_panel(wks,plot3(:5),(/varlen/2,1/),pres)

frame(wks)


pres@gsnPanelLeft				= 0.14
pres@gsnPanelRight				= pres@gsnPanelLeft + plot_length

gsn_panel(wks,plot1(6:),(/varlen/2,1/),pres)

pres@gsnPanelLeft				= plot_length
pres@gsnPanelRight				= pres@gsnPanelLeft + plot_length

gsn_panel(wks,plot2(6:),(/varlen/2,1/),pres)

pres@gsnPanelLeft				= plot_length *2-0.28
pres@gsnPanelRight				= 1.0

gsn_panel(wks,plot3(6:),(/varlen/2,1/),pres)
frame(wks)

;gsn_panel(wks,plots,(/varlen,3/),pres)

end
