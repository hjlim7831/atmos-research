function create_legend_from_plot(wks:graphic,plot:graphic,opt:logical)
local lgres, classname
begin

;---Make sure we have an XY plot!
  classname = NhlClassName(plot)
  if(classname.ne."xyPlotClass") then
    print("create_legend_from_plot: input must be an XY plot")
    return(new(1,graphic))
  end if

  lgres = True

;---Retrieve some resource values from the XY plot.
  getvalues plot@dataspec
    "xyMonoDashPattern"     : mono_dashindex
    "xyMonoMarkLineMode"    : mono_itemtype
    "xyMonoLineColor"       : mono_linecolor
    "xyMonoLineThickness"   : mono_linethickness
    "xyMonoMarkerColor"     : mono_markercolor
    "xyMonoMarker"          : mono_markerindex
    "xyMonoMarkerSize"      : mono_markersize
    "xyMonoMarkerThickness" : mono_markerthickness

    "xyDashPattern"         : DashIndex
    "xyDashPatterns"        : DashIndexes
    "xyMarkLineMode"        : ItemType
    "xyMarkLineModes"       : ItemTypes
    "xyLineColor"           : LineColor
    "xyLineColors"          : LineColors
    "xyLineThicknessF"      : LineThicknessF
    "xyLineThicknesses"     : LineThicknesses
    "xyMarkerColor"         : MarkerColor
    "xyMarkerColors"        : MarkerColors
    "xyMarker"              : MarkerIndex
    "xyMarkers"             : MarkerIndexes
    "xyMarkerSizeF"         : MarkerSizeF
    "xyMarkerSizes"         : MarkerSizes
    "xyMarkerThicknessF"    : MarkerThicknessF
    "xyMarkerThicknesses"   : MarkerThicknesses
  end getvalues

  if(mono_dashindex.or.all(ismissing(DashIndexes))) then
    lgres@lgDashIndex     = DashIndex
    lgres@lgMonoDashIndex = True
  else
    lgres@lgDashIndexes   = DashIndexes
    lgres@lgMonoDashIndex = False
  end if
  if(mono_itemtype.or.all(ismissing(ItemTypes))) then
    lgres@lgItemType     = ItemType
    lgres@lgMonoItemType = True
  else
    lgres@lgItemTypes    = ItemTypes
    lgres@lgMonoItemType = False
  end if
  if(mono_linecolor.or.all(ismissing(LineColors))) then
    lgres@lgLineColor     = LineColor
    lgres@lgMonoLineColor = True
  else
    lgres@lgLineColors    = LineColors
    lgres@lgMonoLineColor = False
  end if
  if(mono_linethickness.or.all(ismissing(LineThicknesses))) then
    lgres@lgLineThicknessF    = LineThicknessF
    lgres@lgMonoLineThickness = True
  else
    lgres@lgLineThicknesses   = LineThicknesses
    lgres@lgMonoLineThickness = False
  end if
  if(mono_markercolor.or.all(ismissing(MarkerColors))) then
    lgres@lgMarkerColor     = MarkerColor
    lgres@lgMonoMarkerColor = True
  else
    lgres@lgMarkerColors    = MarkerColors
    lgres@lgMonoMarkerColor = False
  end if
  if(mono_markerindex.or.all(ismissing(MarkerIndexes))) then
    lgres@lgMarkerIndex     = MarkerIndex
    lgres@lgMonoMarkerIndex = True
  else
    lgres@lgMarkerIndexes   = MarkerIndexes
    lgres@lgMonoMarkerIndex = False
  end if
  if(mono_markersize.or.all(ismissing(MarkerSizes))) then
    lgres@lgMarkerSizeF    = MarkerSizeF
    lgres@lgMonoMarkerSize = True
  else
    lgres@lgMarkerSizes    = MarkerSizes
    lgres@lgMonoMarkerSize = False
  end if
  if(mono_markerthickness.or.all(ismissing(MarkerThicknesses))) then
    lgres@lgMarkerThicknessF    = MarkerThicknessF
    lgres@lgMonoMarkerThickness = True
  else
    lgres@lgMarkerThicknesses   = MarkerThicknesses
    lgres@lgMonoMarkerThickness = False
  end if

;---Get possible labels for legend
  getvalues plot@dataspec
    "xyExplicitLegendLabels" : exp_legend_labels
    "xyExplicitLabels"       : exp_labels
  end getvalues

;---Figure out which legend labels to use.
  if(.not.all(ismissing(exp_legend_labels))) then
    legend_labels = exp_legend_labels
  else if(.not.all(ismissing(exp_labels))) then
    legend_labels = exp_labels
  else if(opt.and.isatt(opt,"LegendLabels")) then
    legend_labels = opt@LegendLabels
  else
    print("create_legend_from_plot: warning: no labels provided for legend")
    legend_labels = ""
  end if
  end if
  end if

;---Set the width and height of legend based on XY plot size
  getvalues plot
    "vpWidthF"  : vpw
    "vpHeightF" : vph
  end getvalues
  lgres@vpWidthF  = vpw/3.5
  lgres@vpHeightF = vph/7.
  lgres@lgPerimOn = False

  lgres@lgLabelFontHeightF = 0.20

;---Get desired number of legend items
  nitems = dimsizes(legend_labels)
  if(opt.and.isatt(opt,"NumberLegendItems")) then
    if(opt@NumberLegendItems.gt.dimsizes(legend_labels)) then
      print("create_legend_from_plot: you don't have enough legend labels specified. Resetting.")
    else
      nitems = opt@NumberLegendItems
    end if
  end if

;---Create the legend
  lbid = gsn_create_legend(wks,nitems,legend_labels,lgres)         ; create legend
;---Attach lower right corner of legend to lower right corner of XY plot.
  amres                  = True
  amres@amParallelPosF   = -0.44    ; move legend to the right
  amres@amOrthogonalPosF = -0.48    ; move the legend down
  amres@amJust           = "TopLeft"

;---Add the legend to the plot
  annoid = gsn_add_annotation(plot,lbid,amres)   ; add legend to plot

;---Return the id so it "lives" outside this function.
  return(annoid)
end

;========================= Main Code ========================
begin
st = get_cpu_time()

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"e2wrfout_d03_2018-07-14_12:00:00","r")
a2 = addfile(diro+"e7wrfout_d03_2018-07-14_12:00:00","r")

RAIN_JUL = (/28/)
RAIN_AUG = (/5,6,9/)

Sdate = 27
EndOfM = 31

INDEX_JUL = RAIN_JUL -Sdate
INDEX_AUG = RAIN_AUG -Sdate +EndOfM

INDEX = array_append_record(INDEX_JUL,INDEX_AUG,0)

dimi = dimsizes(INDEX)

tstart = 3
tend = 890
intt = 1
dimt = (tend-tstart+1)/intt
diur = 24
tm = fspan(0,diur-1,diur)

sHF_2 = a1->HFX(tstart:tend:intt,:,:)
sHF_7 = a2->HFX(tstart:tend:intt,:,:)
LH_2 = a1->LH(tstart:tend:intt,:,:)
LH_7 = a2->LH(tstart:tend:intt,:,:)
PBL_2 = a1->PBLH(tstart:tend:intt,:,:)/1000
PBL_7 = a2->PBLH(tstart:tend:intt,:,:)/1000
T_2 = a1->T2(tstart:tend:intt,:,:) -273.15
T_7 = a2->T2(tstart:tend:intt,:,:) -273.15
Q_2 = a1->Q2(tstart:tend:intt,:,:)*1000.
Q_7 = a2->Q2(tstart:tend:intt,:,:)*1000.
UST_2 = a1->UST(tstart:tend:intt,:,:)
UST_7 = a2->UST(tstart:tend:intt,:,:)
wspd10_2 = (a1->U10(tstart:tend:intt,:,:)^2.+a1->V10(tstart:tend:intt,:,:)^2.)^0.5
wspd10_7 = (a2->U10(tstart:tend:intt,:,:)^2.+a2->V10(tstart:tend:intt,:,:)^2.)^0.5
SWD_2 = a1->SWDOWN(tstart:tend:intt,:,:)
SWD_7 = a2->SWDOWN(tstart:tend:intt,:,:)
LWD_2 = a1->GLW(tstart:tend:intt,:,:)
LWD_7 = a2->GLW(tstart:tend:intt,:,:)




LAT = a1->XLAT(0,:,:)
LON = a1->XLONG(0,:,:)

print("Data Input Time: "+ (get_cpu_time() - st))

lui = a1->LU_INDEX(tstart:tend:intt,:,:)

dimx = dimsizes(lui(0,0,:))
dimy = dimsizes(lui(0,:,0))

tsHF = new((/3,dimt/),float)
tLH = new((/3,dimt/),float)
tPBL = new((/3,dimt/),float)
tT = new((/3,dimt/),float)
tQ = new((/3,dimt/),float)
tUST = new((/3,dimt/),float)
twspd = new((/3,dimt/),float)
tSWD = new((/3,dimt/),float)
tLWD = new((/3,dimt/),float)

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

BON = gc_inout(LAT,LON,sblat,sblon)

tsHF = 0
tLH = 0
tPBL = 0
tQ(:1,:) = 0
tT(:1,:) = 0
tUST(:1,:) = 0
twspd(:1,:) = 0
tSWD = 0
tLWD(:1,:) = 0
do i = 0, dimt -1
	n = 0
	do j = 0, dimy -1
		do k = 0, dimx -1
			if (lui(i,j,k) .eq. 13 .or. lui(i,j,k) .gt. 30).and. BON(j,k) then
				n = n + 1
				tsHF(0,i) = tsHF(0,i) + sHF_2(i,j,k)
				tsHF(1,i) = tsHF(1,i) + sHF_7(i,j,k)
				tT(0,i) = tT(0,i) + T_2(i,j,k)
				tT(1,i) = tT(1,i) + T_7(i,j,k)
				tLH(0,i) = tLH(0,i) + LH_2(i,j,k)
				tLH(1,i) = tLH(1,i) + LH_7(i,j,k)
				tPBL(0,i) = tPBL(0,i) + PBL_2(i,j,k)
				tPBL(1,i) = tPBL(1,i) + PBL_7(i,j,k)
				tQ(0,i) = tQ(0,i) + Q_2(i,j,k)
				tQ(1,i) = tQ(1,i) + Q_7(i,j,k)
				tUST(0,i) = tUST(0,i) + UST_2(i,j,k)
				tUST(1,i) = tUST(1,i) + UST_7(i,j,k)
				twspd(0,i) = twspd(0,i) + wspd10_2(i,j,k)
				twspd(1,i) = twspd(1,i) + wspd10_7(i,j,k)
				tSWD(0,i) = tSWD(0,i) + SWD_2(i,j,k)
				tSWD(1,i) = tSWD(1,i) + SWD_7(i,j,k)
				tLWD(0,i) = tLWD(0,i) + LWD_2(i,j,k)
				tLWD(1,i) = tLWD(1,i) + LWD_7(i,j,k)
			end if
		end do
	end do
	tsHF(:,i) = tsHF(:,i)/tofloat(n)
	tLH(:,i) = tLH(:,i)/tofloat(n)
	tT(:,i) = tT(:,i)/tofloat(n)
	tPBL(:,i) = tPBL(:,i)/tofloat(n)
	tQ(:,i) = tQ(:,i)/tofloat(n)
	tUST(:,i) = tUST(:,i)/tofloat(n)
	twspd(:,i) = twspd(:,i)/tofloat(n)
	tSWD(:,i) = tSWD(:,i)/tofloat(n)
	tLWD(:,i) = tLWD(:,i)/tofloat(n)
end do
tmsHF = new((/3,diur/),float)
tmLH = new((/3,diur/),float)
tmT = new((/3,diur/),float)
tmPBL = new((/3,diur/),float)
tmQ = new((/3,diur/),float)
tmUST = new((/3,diur/),float)
tmwspd = new((/3,diur/),float)
tmSWD = new((/3,diur/),float)
tmLWD = new((/3,diur/),float)
tmsHF = 0
tmLH = 0
tmT = 0
tmPBL = 0
tmQ = 0
tmUST = 0
tmwspd = 0
tmSWD = 0
tmLWD = 0


do i = 0, diur -1
	n = 0
	do j = i, dimt -1, diur
		tmsHF(:,i) = tmsHF(:,i) + tsHF(:,j)
		tmLH(:,i) = tmLH(:,i) + tLH(:,j)
		tmT(:,i) = tmT(:,i) + tT(:,j)
		tmPBL(:,i) = tmPBL(:,i) + tPBL(:,j)
		tmQ(:,i) = tmQ(:,i) + tQ(:,j)
		tmUST(:,i) = tmUST(:,i) + tUST(:,j)
		tmwspd(:,i) = tmwspd(:,i) + twspd(:,j)
		tmSWD(:,i) = tmSWD(:,i) + tSWD(:,j)
		tmLWD(:,i) = tmLWD(:,i) + tLWD(:,j)
		n = n + 1
	end do
	tmsHF(:,i) = tmsHF(:,i)/int2flt(n)
	tmLH(:,i) = tmLH(:,i)/int2flt(n)
	tmT(:,i) = tmT(:,i)/int2flt(n)
	tmPBL(:,i) = tmPBL(:,i)/int2flt(n)
	tmQ(:,i) = tmQ(:,i)/int2flt(n)
	tmUST(:,i) = tmUST(:,i)/int2flt(n)
	tmwspd(:,i) = tmwspd(:,i)/int2flt(n)
	tmSWD(:,i) = tmSWD(:,i)/int2flt(n)
	tmLWD(:,i) = tmLWD(:,i)/int2flt(n)
end do

print("Data Averaging Time: "+ (get_cpu_time() - st))


; type = "x11"
 type = "png"
wks = gsn_open_wks(type,"Compare_diurnal_comp")
 res = True
 res@xyMarkLineModes = (/"Lines","Lines","Lines"/)
 res@xyLineThicknesses = (/4.0,4.0,4.0/)
 res@xyDashPatterns = (/0,2,0/)
 res@xyLineColors = (/"Black","Black","Gray"/)

 res@tmXBMode = "Explicit"
 res@tmXBValues = ispan(0,24,6)
 res@tmXBLabels = ispan(0,24,6)
 res@tmXBMinorValues = ispan(0,24,1)


; res@pmLegendDisplayMode = "Always"
; res@pmLegendSide = "Top"
; res@pmLegendParallelPosF = .2
; res@pmLegendOrthogonalPosF = -0.25
; res@pmLegendWidthF = 0.12
; res@pmLegendHeightF = 0.09
; res@lgPerimOn = False
; res@lgLabelFontHeightF = .020
; res@xyExplicitLegendLabels = (/" URBAN"," NO-URBAN"," "/)

 res@tiXAxisString = "time(KST)"
 res@tiXAxisFontHeightF = 0.035
 res@tmXBLabelFontHeightF = 0.03
 res@tmYLLabelFontHeightF = 0.03
 res@tiMainFontHeightF = 0.025
 res@gsnDraw = False
 res@gsnFrame = False

res1 = res
 res1@tiYAxisString = "sensible heat flux (W m~S2~-2  )"

res2 = res
 res2@tiYAxisString = "latent heat flux (W m~S2~-2  )"

res3 = res
 res3@tiYAxisString = "2 m temperature (~F34~0~F~C)"

res4 = res
 res4@tiYAxisString = "boundary layer height (km)"

res5 = res
 res5@tiYAxisString = "2 m vapor mixing ratio (g kg~S2~-1  )"

res6 = res
 res6@tiYAxisString = "friction velocity (m/s)"

res7 = res
 res7@tiYAxisString = "10 m wind speed (m/s)"

res8 = res
 res8@tiYAxisString = "Downward Short Wave Flux (W m~S2~-2  )"

res9 = res
 res9@tiYAxisString = "Downward Long Wave Flux (W m~S2~-2  )"

pnlres = True

plots = new(9,graphic)

plots(0) = gsn_csm_xy(wks,tm,tmsHF,res1)

opt = True
opt@NumberLegendItems = 2
opt@LegendLabels = (/" Default"," White roof"/)
annoid = create_legend_from_plot(wks,plots(0),opt)


plots(1) = gsn_csm_xy(wks,tm,tmLH,res2)
plots(2) = gsn_csm_xy(wks,tm,tmT,res3)
plots(3) = gsn_csm_xy(wks,tm,tmPBL,res4)
plots(4) = gsn_csm_xy(wks,tm,tmQ,res5)
plots(5) = gsn_csm_xy(wks,tm,tmUST,res6)
plots(6) = gsn_csm_xy(wks,tm,tmwspd,res7)
plots(7) = gsn_csm_xy(wks,tm,tmSWD,res8)
plots(8) = gsn_csm_xy(wks,tm,tmLWD,res9)



gsn_panel(wks,(/plots/),(/3,3/),pnlres)


print("Total Time: "+ (get_cpu_time() - st))

end
