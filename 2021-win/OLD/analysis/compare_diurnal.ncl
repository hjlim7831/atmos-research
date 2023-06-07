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
  lgres@vpWidthF  = vpw/2.1
  lgres@vpHeightF = vph/7.
  lgres@lgPerimOn = False

  lgres@lgLabelFontHeightF = 0.10

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

;========================= We're going to change this part ========================
begin

st = get_cpu_time()

name = "ALB_DIUR" ; name of picture

; whole
;datem = (/"01","01","01","01","01","01","08","08","08","08","08","08"/)
;dated = (/"17","18","19","22","23","24","03","04","10","11","12","21"/) ; for input file name (UTC)
;dateD = (/"18","19","20","23","24","25","04","05","11","12","13","22"/) ; for plotting (KST)

; winter
;datem = (/"01","01","01","01","01","01"/)
;dated = (/"17","18","19","22","23","24"/) ; for input file name (UTC)
;dateD = (/"18","19","20","23","24","25"/) ; for plotting (KST)
;cmap = read_colormap_file("cmocean_dense")
;tcolor = cmap(33:250:13,:)
;name = name + "_1"

; summer
;datem = (/"08","08","08","08","08","08"/)
;dated = (/"03","04","10","11","12","21"/) ; for input file name (UTC)
;dateD = (/"04","05","11","12","13","22"/) ; for plotting (KST)
;cmap = read_colormap_file("matlab_hot")
;tcolor = cmap(45:5:-5,:)
;name = name + "_8"

; individual
datem = (/"01"/)
dated = (/"22"/) ; for input file name (UTC)
dateD = (/"23"/) ; for plotting (KST)
; for summer
;cmap = read_colormap_file("matlab_hot")
;tcolor = cmap(45:5:-5,:)
; for winter
cmap = read_colormap_file("cmocean_dense")
tcolor = cmap(33:250:13,:)

name = name + "_"+datem+dateD



;type = "x11" ; picture type
;type = "png"
type = "oldps"

var = (/"T2","TSK","HFX","LH",\
		"PBLH","Q2","UST","WSPD",\
		"SWDOWN","GLW","SWUP","LWUP",\
		"netSW","netLW","RNET","RES"/)

vlabel = (/ "2 m temperature (~F34~0~F~C)","skin temperature (~F34~0~F~C)",\
			"sensible heat flux (W m~S2~-2  )","latent heat flux (W m~S2~-2  )",\
			"boundary layer height (km)","2 m mixing ratio (g/kg)",\
			"friction velocity (m/s)","10 m wind speed (m/s)",\
			"downward shortwave flux (W m~S2~-2  )","downward longwave flux (W m~S2~-2  )",\
			"upward shortwave flux (W m~S2~-2  )","upward longwave flux (W m~S2~-2  )",\
			"net shortwave flux (W m~S2~-2  )","net longwave flux (W m~S2~-2  )",\
			"net radiative flux (W m~S2~-2  )","surface energy budget (W m~S2~-2  )"/)


dir = "/home/hjlim/2021-win/model/"


t_start = 12
t_end = 36
intt = 1

stTITLE ="("+ (/"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q"/) + ")"

; ============================================ Data Processing ==============================================

nd = dimsizes(datem)

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(0)+"-"+dated(0)+"_03:00:00"


pathf = dir+datem(0)+dated(0)+albf
nfil = dimsizes(pathf)

a = addfile(pathf(0),"r")

lu = a->LU_INDEX(0,:,:)
LAT = a->XLAT(0,:,:)
LON = a->XLONG(0,:,:)

nt = (t_end-t_start+1)/intt
ny = dimsizes(lu(:,0))
nx = dimsizes(lu(0,:))
nv = dimsizes(var)

varbox = new((/nv,nd,nfil,nt,ny,nx/),float)
uvar = new((/nv,nd,nfil,nt/),float)
tmbox = new((/nfil,nt/),float)

uvar = 0.

do ii = 0, nfil -1
	tmbox(ii,:) = fspan(0,nt-1,nt)
end do

do jj = 0, nd -1

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(jj)+"-"+dated(jj)+"_03:00:00"
pathf = dir+datem(jj)+dated(jj)+albf

STBOLT = 5.67*10^-8 ; W/m2/K4

do ii = 0, nfil -1
	a1 = addfile(pathf(ii),"r")
	do kk = 0, nv -1
		if var(kk) .eq. "WSPD" then
			varbox(kk,jj,ii,:,:,:) = (a1->U10(t_start:t_end,:,:)^2.+a1->V10(t_start:t_end,:,:)^2.)^0.5
		else if var(kk) .eq. "PBLH" then
			varbox(kk,jj,ii,:,:,:) = a1->$var(kk)$(t_start:t_end,:,:)/1000.
		else if (var(kk) .eq. "T2") .or. (var(kk) .eq. "TSK") then
			varbox(kk,jj,ii,:,:,:) = a1->$var(kk)$(t_start:t_end,:,:) - 273.15
		else if (var(kk) .eq. "Q2") then
			varbox(kk,jj,ii,:,:,:) = a1->$var(kk)$(t_start:t_end,:,:)*1000.
		else if (var(kk) .eq. "SWUP") then
			varbox(kk,jj,ii,:,:,:) = a1->ALBEDO(t_start:t_end,:,:) * a1->SWDOWN(t_start:t_end,:,:)
		else if (var(kk) .eq. "LWUP") then
			varbox(kk,jj,ii,:,:,:) = STBOLT*a1->TSK(t_start:t_end,:,:)^4.
		else if (var(kk) .eq. "netSW") then
			varbox(kk,jj,ii,:,:,:) = (1.-a1->ALBEDO(t_start:t_end,:,:))*a1->SWDOWN(t_start:t_end,:,:)
		else if (var(kk) .eq. "netLW") then
			varbox(kk,jj,ii,:,:,:) = a1->EMISS(t_start:t_end,:,:)*(a1->GLW(t_start:t_end,:,:) - STBOLT*a1->TSK(t_start:t_end,:,:)^4.)
		else if (var(kk) .eq. "RNET") then
			varbox(kk,jj,ii,:,:,:) = (1.-a1->ALBEDO(t_start:t_end,:,:))*a1->SWDOWN(t_start:t_end,:,:)+a1->EMISS(t_start:t_end,:,:)*(a1->GLW(t_start:t_end,:,:) - STBOLT*a1->TSK(t_start:t_end,:,:)^4.)
		else if (var(kk) .eq. "RES") then
			varbox(kk,jj,ii,:,:,:) = (1.-a1->ALBEDO(t_start:t_end,:,:))*a1->SWDOWN(t_start:t_end,:,:)+a1->EMISS(t_start:t_end,:,:)*(a1->GLW(t_start:t_end,:,:) - STBOLT*a1->TSK(t_start:t_end,:,:)^4.) + a1->GRDFLX(t_start:t_end,:,:) - a1->HFX(t_start:t_end,:,:) - a1->LH(t_start:t_end,:,:)
		else if (var(kk) .eq. "NOAHRES") then
			varbox(kk,jj,ii,:,:,:) = a1->NOAHRES(t_start:t_end,:,:)
		else
			varbox(kk,jj,ii,:,:,:) = a1->$var(kk)$(t_start:t_end,:,:)
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
		end if
	end do
	delete([/a1/])
end do
end do


print("Data Input Time: "+ (get_cpu_time() - st))


sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

BON = gc_inout(LAT,LON,sblat,sblon)

do i = 0, nt -1
	n = 0
	do j = 0, ny -1
		do k = 0, nx -1
			if (lu(j,k) .eq. 13 .or. lu(j,k) .gt. 30).and. BON(j,k) then
				n = n + 1
				uvar(:,:,:,i) = uvar(:,:,:,i) + varbox(:,:,:,i,j,k) 
			end if
		end do
	end do
	uvar(:,:,:,i) = uvar(:,:,:,i)/tofloat(n)
end do

print("Data Averaging Time: "+ (get_cpu_time() - st))

muvar = dim_avg_n(uvar,1)




; =============================================== Drawing Section ================================================

wks = gsn_open_wks(type,name)

thn = new(nfil,float)
dpat = new(nfil,integer)
mpat = new(nfil,integer)

thn = 2.0
dpat = 0
mpat = 16

res											= True
res@gsnDraw									= False
res@gsnFrame								= False
res@xyMarkLineMode							= "MarkLines"
res@xyLineThicknesses						= thn
res@xyDashPatterns							= dpat
res@xyMarkers								= mpat
res@xyLineColors							= tcolor
res@xyMarkerColors							= tcolor
res@tmXBMode								= "Explicit"
res@tmXBValues								= ispan(0,24,6)
res@tmXBLabels								= ispan(0,24,6)
res@tmXBMinorValues							= ispan(0,24,1)
res@trXMinF									= 0
res@trXMaxF									= 24
;res@tmXTOn									= False
;res@tmYROn									= False
res@tiXAxisString							= "time (LST)"


; res@pmLegendDisplayMode = "Always"
; res@pmLegendSide = "Top"
; res@pmLegendParallelPosF = .2
; res@pmLegendOrthogonalPosF = -0.25
; res@pmLegendWidthF = 0.12
; res@pmLegendHeightF = 0.09
; res@lgPerimOn = False
; res@lgLabelFontHeightF = .020
; res@xyExplicitLegendLabels = (/" URBAN"," NO-URBAN"," "/)

; res@tiXAxisFontHeightF = 0.032
; res@tiYAxisFontHeightF = 0.032
; res@tmXBLabelFontHeightF = 0.030
; res@tmYLLabelFontHeightF = 0.030
; res@tiMainFontHeightF = 0.025
; res@gsnLeftStringFontHeightF = 0.036
; res@tmYLMode  = "Explicit"

pnlres = True
;pnlres@gsnFrame = False
;pnlres@gsnDraw = False

plots = new(nv,graphic)

do ii = 0, nv -1
	res@tiYAxisString = vlabel(ii)
	plots(ii) = gsn_csm_xy(wks,tmbox,muvar(ii,:,:),res)
end do

;gsn_panel(wks,(/plots/),(/3,5/),pnlres)
gsn_panel(wks,(/plots/),(/4,4/),pnlres)

end
