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

; =====================================================================================
; ==================================== Main Code ======================================
; =====================================================================================

begin
st = get_cpu_time()

diri = "~/2021-win/2D_wrf/model/sea_breeze/white_roof/"
diro= "~/2021-win/2D_wrf/picture/"
fil1 = "wrfout_d01_2008-06-20_00:00:00"
name = "COMPARE_DIURNAL_SB_CONV"

;var_name = (/"HFX","LH","GRDFLX","SWDOWN","GLW","T2"/)

var_name = (/"T2","U10","HFX","LH"/)

tstart = 0
tend = 144
intt = 1
dimt = (tend-tstart+1)/intt
diur = 144 ; 10 minutes interval
tm = fspan(0,diur,dimt)/6.

a1 = addfile(diri+fil1,"r")

; =========================== variable setting ===================================

plot_set = (/2,2/)

;ystring = (/"sensible heat flux (W m~S2~-2  )",\
;			"latent heat flux (W m~S2~-2  )",\
;			"ground heat flux (W m~S2~-2  )",\
;			"downward shortwave radiation (W m~S2~-2  )",\
;			"downward longwave radiation (W m~S2~-2  )",\
;			"2 m temperature (~S2~o  C)"/)


ystring = (/"2 m temperature (~S2~o  C)",\
			"10 m U wind (m s~S2~-1  )",\
			"sensible heat flux (W m~S2~-2  )",\
			"latent heat flux (W m~S2~-2  )"/)

vardim = getfilevardimsizes(a1,"P")
print(vardim)


dimz = vardim(0)
dimy = vardim(2)
dimx = vardim(3)

varn = dimsizes(var_name)

dx = 1000 ; m
xlen = 800 * 1000 ; m


; for default case
;uxst = 90 * 1000/dx
;uxed = 110 * 1000/dx
;rxst = 130 * 1000/dx
;rxed = 150 * 1000/dx

; for 1way urban-sea case

uxst = 120 * 1000/dx
uxed = 140 * 1000/dx
rxst1 = 100 * 1000/dx
rxed1 = 120 * 1000/dx
rxst2 = 140 * 1000/dx
rxed2 = 160 * 1000/dx


varbox = new((/varn,dimt,dimy,dimx/),float)
tvarbox = new((/varn,3,dimt/),float)

; ===================== Plotting Resources =================================

 type = "x11"
; type = "png"
wks = gsn_open_wks(type,diro+name)
 res = True
 res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines"/)
 res@xyLineThicknesses = (/4.0,4.0,4.0,4.0/)
 res@xyDashPatterns = (/0,2,4,0/)
 res@xyLineColors = (/"Black","Black","Black","Gray"/)

 res@tmXBMode = "Explicit"
 res@tmXBValues = ispan(0,24,6)
 res@tmXBLabels = ispan(0,24,6)
 res@tmXBMinorValues = ispan(0,24,1)

 res@tiXAxisString = "time(KST)"
 res@tiXAxisFontHeightF = 0.035
 res@tmXBLabelFontHeightF = 0.03
 res@tmYLLabelFontHeightF = 0.03
 res@tiMainFontHeightF = 0.025
 res@gsnDraw = False
 res@gsnFrame = False


 res@pmLegendWidthF			= 0.15
 res@pmLegendHeightF		= 0.18
 res@pmLegendOrthogonalPosF = -1.25
 res@pmLegendParallelPosF	= 0.35
 res@lgLabelFontHeightF		= 0.025
 res@lgPerimOn				= False
 res@xyExplicitLegendLabels = (/" urban"," rural (near coast)"," rural (far from coast)"/)

; ================================ Loop Section =============================================

do vi = 0, varn -1

varbox(vi,:,:,:) = a1->$var_name(vi)$(tstart:tend:intt,:,:)

printVarSummary(varbox(vi,:,:,uxst:uxed))

tvarbox(vi,0,:) = dim_avg_n(varbox(vi,:,:,uxst:uxed),(/1,2/))
tvarbox(vi,1,:) = dim_avg_n(varbox(vi,:,:,rxst1:rxed1),(/1,2/))
tvarbox(vi,2,:) = dim_avg_n(varbox(vi,:,:,rxst2:rxed2),(/1,2/))


end do

tbox = new((/3,dimt/),float)

tbox(0,:) = tm
tbox(1,:) = tm
tbox(2,:) = tm

print("Data Averaging Time: "+ (get_cpu_time() - st))

plots = new(varn,graphic)

do vi = 0, varn -1

res1 = res
res1@tiYAxisString = ystring(vi)
if vi .eq. 0 then
	res1@pmLegendDisplayMode = "Always"
else
	res1@pmLegendDisplayMode = "Never"
end if

plots(vi) = gsn_csm_xy(wks,tbox(:,1:),tvarbox(vi,:,1:),res1)

end do

pnlres = True

opt = True
opt@NumberLegendItems = 2
opt@LegendLabels = (/" Default"," White roof"/)
;annoid = create_legend_from_plot(wks,plots(0),opt)


gsn_panel(wks,(/plots/),(/plot_set(0),plot_set(1)/),pnlres)


print("Total Time: "+ (get_cpu_time() - st))

end
