;*************************************************
; polyg_8_lbar.ncl
;
; Concepts illustrated:
;   - Drawing a scatter plot on a map
;   - Changing the marker color and size in a map plot
;   - Plotting station locations using markers
;   - Manually creating a labelbar
;   - Adding text to a plot
;   - Generating dummy data using "random_uniform"
;   - Binning data
;*************************************************
;
; This example creates some dummy station data,
; and then plots each value by coloring and sizing it
; depending on which range of values it falls in.
;
;*************************************************
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

;----------------------------------------------------------------------
; Procedure for adding a labelbar at a given NDC location, given
; the levels and colors to use.
;----------------------------------------------------------------------
undef("add_labelbar")
procedure add_labelbar(wks,plot,levels,colors)
local lbres, labels
begin
  nlevels = dimsizes(levels)
;----------------------------------------------------------------------
; Draw a labelbar
;----------------------------------------------------------------------
  lbres                	    	= True
  lbres@vpWidthF           		= 0.2             ; width
  lbres@vpHeightF       	   	= 0.65             ; height
  lbres@lbPerimOn      	    	= False            ; Turn off perimeter.
; lbres@lbOrientation      		= "Horizontal"     ; Default is vertical.
  lbres@lbLabelAlignment   		= "InteriorEdges"  ; Default is "BoxCenters"
  lbres@lbFillColors       		= colors           ; Colors for boxes.
  lbres@lbMonoFillPattern  		= True             ; Fill them all solid.
  lbres@lbLabelFontHeightF 		= 0.025            ; label font height
  lbres@lbBoxLineThicknessF		= 5.0
;  lbres@lbTitleString	   		= "(days)"
;  lbres@lbTitleExtemtF			= 0.4
;  lbres@lbTitleFontHeightF 		= 0.020

  labels = sprintf("%g",levels)

  lbid = gsn_create_labelbar(wks,nlevels+1,labels,lbres)
   
;
; Now, create some annotation resources indicating how we want to
; attach the labelbar to the plot. Here, we are using the top right
; corner of the labelbar as the point which we are going to position
; it, and then we use amParallelPosF and amOrthogonalPosF to indicate
; where we want to place it.
;
; amParallelPosF/amOrthogonalPosF                                       ;
;    0.0/ 0.0  -  annotation in dead center of plot
;    0.5/ 0.5  -  annotation at bottom right of plot
;    0.5/-0.5  -  annotation at top right of plot
;   -0.5/-0.5  -  annotation at top left of plot
;   -0.5/ 0.5  -  annotation at bottom left of plot
;                                                                 
  amres                  = True
  amres@amJust           = "TopCenter"
  amres@amParallelPosF   =  0.65   ; keep labelbar centered
  amres@amOrthogonalPosF = -0.50   ; move down and outside of plot

;
; Give both annotation id and labelbar id unique names.
;
; Attaching them to plot with unique names ensures that
; labelbar "lives" outside this procedure.
;
  tmpid1 = "anno"+unique_string("id")
  tmpid2 = "lbar"+unique_string("id")

  plot@$tmpid1$ = gsn_add_annotation(plot,lbid,amres)
  plot@$tmpid2$ = lbid
end

;----------------------------------------------------------------------
; Main code.
;----------------------------------------------------------------------
begin
;-------Options--------
; bin settings (bin0 = < 0.,; bin1 = 0.:4.999, etc.)

;  levels = ispan(25,33,1)
;  levels = fspan(1.5,4.5,13)
   levels = ispan(330,540,10)
;  levels = (/0.0/)

  nlevels = dimsizes(levels)
  colors  = span_color_rgba("MPL_jet",nlevels+1)

;---------------------------



diro = "~/2019-win/whiteroof/"

fil1 = "wt2.csv"

;==========================

lines2 = asciiread(diro+fil1,-1,"string")
nlines2 = dimsizes(lines2)
delim = ","
fields2 = str_split_csv(lines2,delim,0)

uhi = tofloat(fields2(1:,0))
wd = tofloat(fields2(1:,1))
ut = tofloat(fields2(1:,2))
ws = tofloat(fields2(1:,3))
q2 = tofloat(fields2(1:,6)) *1000
sw = tofloat(fields2(1:,10))

print(wd)
print(ut)

npts = dimsizes(uhi)

var = sw
print(max(var))
print(min(var))

;------------------------------ 
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = nlevels+1        ; number of distinct markers
  uhi_new = new((/num_distinct_markers,npts/),float,-999)
  wd_new = new((/num_distinct_markers,npts/),float,-999)
;
; Group the points according to which range they fall in. At the
; same time, create the label that we will use later in the labelbar
;       
  do i = 0, num_distinct_markers-1
    if (i.eq.0) then
      indexes = ind(var.lt.levels(0))
    end if
    if (i.eq.num_distinct_markers-1) then
      indexes = ind(var.ge.max(levels))
    end if
    if (i.gt.0.and.i.lt.num_distinct_markers-1) then       
      indexes = ind(var.ge.levels(i-1).and.var.lt.levels(i))
    end if
;
; Now that we have the set of indexes whose values fall within 
; the given range, take the corresponding lat/lon values and store
; them, so later we can color this set of markers with the appropriate
; color.
;
    if (.not.any(ismissing(indexes))) then 
      npts_range = dimsizes(indexes)   ; # of points in this range.
      uhi_new(i,0:npts_range-1) = uhi(indexes)
      wd_new(i,0:npts_range-1) = wd(indexes)
    end if
;	print(indexes)
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do

;===========================================================================
; Begin plotting section.
;

type = "png"
;type = "x11"

  wks = gsn_open_wks(type,"Q2_scatter")              ; send graphics to PNG file

res                               = True
res@gsnMaximize                   = True
res@gsnFrame                      = False
res@gsnDraw                       = False

res@tmXBMajorThicknessF			= 5.0
res@tmYLMajorThicknessF			= 5.0
res@tmXTOn						= False
res@tmYROn						= False
res@tmBorderThicknessF            = 5.0
res@tiXAxisString				= "daytime averaged wind direction"
res@tiYAxisString				= "daytime averaged white roof effect (~S2~o  C)"
res@tmXBMode					= "Explicit"
res@trXMaxF						= 360
res@trXMinF						= 0.
res@trYMaxF						= -0.1
res@trYMinF						= -1.
res@tmXBValues					= (/90,180,270,360/)
res@tmXBLabels					= (/"E","S","W","N"/)

;mpres@tiMainOn                      = True
;mpres@tiMainString                  = "Number of Heatwave days in 2018"

res@gsnRightString					= " (g/kg)"
res@gsnRightStringFontHeightF			= 0.015
res@gsnRightStringParallelPosF		= 1.25
res@gsnRightStringOrthogonalPosF		= 0.04


res@xyMarkLineModes = (/"Markers"/)
res@xyMarkers = (/16/)
res@xyMarkerSizeF = 0.005



;--Create logical variables to hold the marker resources.
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
;
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.
;
n = 0
do i = 0, num_distinct_markers-1
	n = n + 1
	if (.not.ismissing(uhi_new(i,0)))
res@xyMarkerColor      = colors(i,:)
res@xyMarkerSizeF      = 0.021    ;+0.007
plot = gsn_csm_xy(wks,wd_new(i,:),uhi_new(i,:),res)
	break
	end if
end do


  overlays = new(num_distinct_markers-1,graphic)
  do i = n, num_distinct_markers-1
    if (.not.ismissing(uhi_new(i,0)))
      res@xyMarkerColor      = colors(i,:)
      res@xyMarkerSizeF      = 0.021	;+0.007
	 overlays(i-1) =  gsn_csm_xy(wks,wd_new(i,:),uhi_new(i,:),res)
	 overlay(plot,overlays(i-1))
    end if
  end do

;---Draw labelbar and advance frame.
;plot = new(1,graphic)
add_labelbar(wks,plot,levels,colors)

panel_res					= True
panel_res@gsnPanelBottom	= 0.2


gsn_panel(wks,plot,(/1,1/),panel_res)

;  draw(plot)
;  frame(wks)

end     
