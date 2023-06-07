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
  lgres@vpWidthF  = vpw/3.
  lgres@vpHeightF = vph/5.
  lgres@lgPerimOn = False

  lgres@lgLabelFontHeightF = 0.12

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

diro = "~/class/History/num_model2/"

lines = asciiread(diro+"csv/AWS_0803-0809_forValid_revised.csv",-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)
printVarSummary(fields)

obtmp = tofloat(fields(:,0))
obwspd = tofloat(fields(:,1))
obwd = tofloat(fields(:,2))
obskt = tofloat(fields(:,4))


filname = (/"yswrfout_d03_2016-08-02_12:00:00","mynnwrfout_d03_2016-08-02_12:00:00","qnsewrfout_d03_2016-08-02_12:00:00"/)

varname = (/"2 m temperature (~F34~0~F~C)","skin temperature (~F34~0~F~C)","10 m wind speed (m/s)",\
			"10 m wind direction (~S2~o   )","sensible heat flux (W m~S2~-2  )","latent heat flux (W m~S2~-2  )",\
			"friction velocity (m/s)","boundary layer height (km)"/)

tstart = 3
tend = 26
intt = 1
dimt = (tend-tstart+1)/intt
tm = fspan(0,dimt-1,dimt)

nvar = 8
nfil = 3
ny = 165
nx = 141
; 1. 2 m temperature, 2. skin temperature, 3. U10, 4. V10,
; 5. sensible heat flux, 6. latent heat flux, 7. friction velocity, 8. PBL height

tmbox = new((/nfil,dimt/),float)
do ii = 0, nfil -1
	tmbox(ii,:) = tm
end do

varbox = new((/nfil,nvar,dimt,ny,nx/),float)

r2d = 45.0/atan(1.0)

do ii = 0, nfil -1
	a = addfile(diro+filname(ii),"r")
	varbox(ii,0,:,:,:) = a->T2(tstart:tend:intt,:,:) - 273.15
	varbox(ii,1,:,:,:) = a->TSK(tstart:tend:intt,:,:) - 273.15
	varbox(ii,2,:,:,:) = a->U10(tstart:tend:intt,:,:)
	varbox(ii,3,:,:,:) = a->V10(tstart:tend:intt,:,:)
	varbox(ii,4,:,:,:) = a->HFX(tstart:tend:intt,:,:)
	varbox(ii,5,:,:,:) = a->LH(tstart:tend:intt,:,:)
	varbox(ii,6,:,:,:) = a->UST(tstart:tend:intt,:,:)
	varbox(ii,7,:,:,:) = a->PBLH(tstart:tend:intt,:,:)/1000.

	delete([/a/])
end do

a = addfile(diro+filname(0),"r")
LAT = a->XLAT(0,:,:)
LON = a->XLONG(0,:,:)

print("Data Input Time: "+ (get_cpu_time() - st))

mlat = 37.5714
mlon = 126.9658

mind = wrf_user_ll_to_ij(a,mlon,mlat,True) - 1
mi = mind(0)
mj = mind(1)

latdum = (/LAT(mj-1,mi),LAT(mj,mi),LAT(mj+1,mi)/)
londum = (/LON(mj,mi-1),LON(mj,mi),LON(mj,mi+1)/)
do i = 0, 1
	do j = 0, 1
		if (latdum(j) .le. mlat) .and. (mlat .le. latdum(j+1)) .and. (londum(i) .le. mlon) .and. (mlon .le. londum(i+1)) then
			latdum2 = (/latdum(j),latdum(j+1)/)
			londum2 = (/londum(i),londum(i+1)/)
			vardum = varbox(:,:,:,mj-1+j:mj+j,mi-1+i:mi+i)
		end if
	end do
end do

movar = linint2_points(londum2,latdum2,vardum,False,mlon,mlat,0)
printVarSummary(movar)

mou10 = movar(:,2,:,0)
mov10 = movar(:,3,:,0)

movar(:,2,:,0) = (mou10^2.+mov10^2.)^0.5
movar(:,3,:,0) = atan2(mou10,mov10) * r2d + 180

print("Data Averaging Time: "+ (get_cpu_time() - st))


; type = "x11"
 type = "png"
wks = gsn_open_wks(type,"Compare_diurnal_ASOS")
 res = True
 res@xyLineThicknesses = (/4.0,4.0,4.0/)
 res@xyDashPatterns = (/0,0,0/)
 res@xyLineColors = (/"Red","Blue","Green"/)
 res@xyMarkerColors = (/"Red","Blue","Green"/)
 res@xyMarkers = (/16,16,16/)
 res@xyMarkerSizes = (/0.02,0.02,0.02/)

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


pnlres = True

plots = new(nvar,graphic)
ov = new(4,graphic)

do ii = 0, nvar -1
	if ii .eq. 3 then
		res@xyMarkLineModes = (/"Markers","Markers","Markers"/)
		res@tmYLMode		= "Explicit"
		res@tmYLValues		= (/90,180,270,360/)
		res@tmYLLabels 		= (/"E","S","W","N"/)
		res@trYMaxF			= 360
	else
		res@tmYLMode		= "Automatic"
		res@xyMarkLineModes = (/"Lines","Lines","Lines"/)
	end if
	if ii .eq. 1 then
		res@trYMaxF			= 45
		res@trYMinF			= 22
	end if
	res@tiYAxisString = varname(ii)
	plots(ii) = gsn_csm_xy(wks,tmbox,movar(:,ii,:,0),res)
	if ii.eq.3 then
		delete(res@trYMaxF)
	end if
	if ii.eq.1 then
		delete([/res@trYMaxF,res@trYMinF/])
	end if
end do

ores = True
ores@gsnFrame                    = False
ores@gsnDraw                     = False
ores@xyMarkLineModes            = "Lines"
ores@xyLineThicknesses          = 4.0
ores@xyDashPatterns             = 0
ores@xyLineColors               = "Black"
ores@xyMarkers = 16
ores@xyMarkerSizes = 0.02

ores@pmLegendDisplayMode         = True
ores@pmLegendWidthF              = 0.12
ores@pmLegendHeightF             = 0.03
ores@pmLegendParallelPosF        = .19
ores@pmLegendOrthogonalPosF      = -1.04
ores@lgLabelFontHeightF          = 0.027
ores@lgPerimOn                   = False
ores@xyExplicitLegendLabels      = (/"OBS"/)




ov(0) = gsn_csm_xy(wks,tm,obtmp,ores)


ores@pmLegendDisplayMode         = False
ov(1) = gsn_csm_xy(wks,tm,obwspd,ores)

ores@xyMarkLineModes            = "Markers"
ov(2) = gsn_csm_xy(wks,tm,obwd,ores)

ores@xyMarkLineModes            = "Lines"
ov(3) = gsn_csm_xy(wks,tm,obskt,ores)

overlay(plots(0),ov(0))
overlay(plots(1),ov(3))
overlay(plots(2),ov(1))
overlay(plots(3),ov(2))


opt = True
opt@NumberLegendItems = 3
opt@LegendLabels = (/" YSU"," MYNN"," QNSE"/)
annoid = create_legend_from_plot(wks,plots(0),opt)

gsn_panel(wks,(/plots/),(/2,4/),pnlres)


print("Total Time: "+ (get_cpu_time() - st))

end
