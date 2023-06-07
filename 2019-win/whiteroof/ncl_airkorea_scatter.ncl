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
  lbres@vpHeightF       	   	= 0.70             ; height
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

  labels = sprintf("%4.2f",levels)

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
  amres@amOrthogonalPosF = -0.55   ; move down and outside of plot

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

;  levels = (/0.03,0.04,0.05,0.06,0.07,0.08,0.09,0.10,0.11,0.12,0.13,0.14,0.15,0.16/)
  levels = (/0.02,0.04,0.06,0.08,0.10,0.12,0.14,0.16,0.18/)
;  levels = (/0.0/)

  nlevels = dimsizes(levels)
  colors  = span_color_rgba("MPL_YlOrRd",nlevels+1)

;---------------------------



diro = "~/2019-win/whiteroof/"
diri = "csv/"

fil1 = "jungu_2018-3.csv"
fil2 = "ASOS_0715-0820_forValid_revised.csv"

sday = 15
eday = 31+20



;==========================

dlen = (eday -sday +1) *24

sdt = (sday-1)*24 -1
edt = eday*24 -1

sdt1 = (sday -15)*24
edt1 = (eday -14)*24


lines2 = asciiread(diro+diri+fil1,-1,"string")
nlines2 = dimsizes(lines2)
delim = ","
fields2 = str_split_csv(lines2,delim,0)


O3 = tofloat(fields2(1+sdt:edt,4))

lines3 = asciiread(diro+diri+fil2,-1,"string")
nlines3 = dimsizes(lines3)
delim = ","
fields3 = str_split_csv(lines3,delim,0)

T2 = tofloat(fields3(sdt1:edt1-1,2))
ws10 = tofloat(fields3(sdt1:edt1-1,3))

vlen = dimsizes(T2)

npts = vlen/24

O3_max = new(npts,float)
T2_max = new(npts,float)
ws10_max = new(npts,float)

do i = 0, npts -1
	maxT2 = max(T2(24*i:24*i+23))
	T2_max(i) = maxT2
	do j = 0, 23
		if (T2(24*i+j) .eq. maxT2) then
			O3_max(i) = O3(24*i+j)
			ws10_max(i) = ws10(24*i+j)
		end if
	end do
end do
	

print(T2_max)
print("max:"+max(T2_max))
print("min:"+min(T2_max))

print(ws10_max)
print("max:"+max(ws10_max))
print("min:"+min(ws10_max))

var = O3_max

print(O3_max)
print("max:"+max(O3_max))
print("min:"+min(O3_max))

;------------------------------ 
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = nlevels+1        ; number of distinct markers
  ws10_new = new((/num_distinct_markers,npts/),float,-999)
  T2_new = new((/num_distinct_markers,npts/),float,-999)
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
      ws10_new(i,0:npts_range-1) = ws10_max(indexes)
      T2_new(i,0:npts_range-1) = T2_max(indexes)
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

  wks = gsn_open_wks(type,"pollution_scatter")              ; send graphics to PNG file

res                               = True
res@gsnMaximize                   = True
res@gsnFrame                      = False
res@gsnDraw                       = False






;mpres@tmXBMode                      = "Explicit"
;mpres@tmXBValues                    = ispan(125,131,1)
;mpres@tmXBLabels                    = ispan(125,131,1) +" E"
;mpres@tmYLValues                    = ispan(32,40,1)
;mpres@tmYLLabels                    = ispan(32,40,1) +" N"

res@tmXBMajorThicknessF			= 5.0
res@tmYLMajorThicknessF			= 5.0
res@tmXTOn						= False
res@tmYROn						= False
res@tmBorderThicknessF            = 5.0
res@tiXAxisString				= "10 m wind speed (m/s)"
res@tiYAxisString				= "Daily maximum 2 m air temperature (~S2~o  C)"
res@tmXBMode					= "Manual"
res@trXMaxF						= 4.0
res@trXMinF						= 0.8
res@trYMaxF						= 40.
res@trYMinF						= 30.

;mpres@tiMainOn                      = True
;mpres@tiMainString                  = "Number of Heatwave days in 2018"

res@gsnRightString					= "Ozone (ppm)"
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
	if (.not.ismissing(T2_new(i,0)))
res@xyMarkerColor      = colors(i,:)
res@xyMarkerSizeF      = 0.042    ;+0.007
plot = gsn_csm_xy(wks,ws10_new(i,:),T2_new(i,:),res)
	break
	end if
end do


  overlays = new(num_distinct_markers-1,graphic)
  do i = n, num_distinct_markers-1
    if (.not.ismissing(T2_new(i,0)))
      res@xyMarkerColor      = colors(i,:)
      res@xyMarkerSizeF      = 0.042	;+0.007
	 overlays(i-1) =  gsn_csm_xy(wks,ws10_new(i,:),T2_new(i,:),res)
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
