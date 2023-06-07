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

  levels = (/-0.8,-0.7,-0.6,-0.5,-0.4,-0.3,-0.2,-0.1,0,0.1/) ; T2
;  levels = (/-7,-6.5,-6.0,-5.5,-5.0,-4.5,-4.0,-3.5/) ; TSK
;  levels = (/130.,140.,150.,160.,170.,180.,190.,200.,210.,220.,230./) ; USR

  nlevels = dimsizes(levels)
  colors  = span_color_rgba("cmocean_ice",nlevels+1)

res = True
res@gsnRightString                  = "White Roof Effect (~S2~o  C)"
res@gsnRightStringFontHeightF           = 0.015
res@gsnRightStringParallelPosF      = 1.25
res@gsnRightStringOrthogonalPosF        = 0.04
res@tiXAxisString               = "10 m wind speed (m/s)"
;res@tiYAxisString               = "Upward Short wave Radiation at 13:00 (W m~S2~-2  )"
res@tiYAxisString               = "2 m  Temperature at 15:00 (~S2~o  C)"
res@trXMaxF                        = 6.0
res@trXMinF                        = 2.0
res@trYMaxF                        = 36.
res@trYMinF                        = 28.

tt = 15

type = "png"
;type = "x11"

 wks = gsn_open_wks(type,"Scatter_model_tw_T2_"+tt)              ; send graphics to PNG file
; wks = gsn_open_wks(type,"Scatter_model_tw_TSK_"+tt)
; wks = gsn_open_wks(type,"Scatter_model_tw_USR_"+tt)


;---------------------------

 dir = "./"
 fileA  = "e2wrfout_d03_2018-07-14_12:00:00" ; change here!
 fileB  = "e7wrfout_d03_2018-07-14_12:00:00" ;

a1 = addfile(dir+fileA,"r")
a2 = addfile(dir+fileB,"r")

its = 3
ite = 891


;==========================

tlen = (ite -its +1)
npts = tlen/24

t1 = a1->T2(its:ite,:,:) -273.15
t2 = a2->T2(its:ite,:,:) -273.15
;t1 = a1->ALBEDO(its:ite,:,:) * a1->SWDOWN(its:ite,:,:)
;t2 = a2->ALBEDO(its:ite,:,:) * a2->SWDOWN(its:ite,:,:)
wspd1 = (a1->U10(its:ite,:,:)^2.+a1->V10(its:ite,:,:)^2.)^0.5
wspd2 = (a2->U10(its:ite,:,:)^2.+a2->V10(its:ite,:,:)^2.)^0.5

lu = a1->LU_INDEX(0,:,:)

d1 = dimsizes(t1(0,:,0))
d2 = dimsizes(t1(0,0,:))

ut1 = new(tlen,float)
ut2 = new(tlen,float)
uwspd1 = new(tlen,float)
uwspd2 = new(tlen,float)

ut1 = 0.
ut2 = 0.
uwspd1 = 0.
uwspd2 = 0.
n = 0
do i = 0, d1 -1
	do j = 0, d2 -1
		if lu(i,j) .eq. 13 .or. lu(i,j) .ge. 31 then
			ut1 = ut1 + t1(:,i,j)
			ut2 = ut2 + t2(:,i,j)
			uwspd1 = uwspd1 + wspd1(:,i,j)
			uwspd2 = uwspd2 + wspd2(:,i,j)
			n = n + 1
		end if
	end do
end do

ut1 = ut1 / tofloat(n)
ut2 = ut2 / tofloat(n)
uwspd1 = uwspd1 / tofloat(n)
uwspd2 = uwspd2 / tofloat(n)

HI = new(npts,float)
WRE = new(npts,float)
WS = new(npts,float)


do i = 0, npts -1
	HI(i) = ut1(24*i+tt)
	WRE(i) = ut2(24*i+tt)-ut1(24*i+tt)
	WS(i) = uwspd1(24*i+tt)
end do
	

print(HI)
print("max:"+max(HI))
print("min:"+min(HI))

print(WS)
print("max:"+max(WS))
print("min:"+min(WS))

var = WRE

print(WRE)
print("max:"+max(WRE))
print("min:"+min(WRE))

;------------------------------ 
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = nlevels+1        ; number of distinct markers
  WS_new = new((/num_distinct_markers,npts/),float,-999)
  HI_new = new((/num_distinct_markers,npts/),float,-999)
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
      WS_new(i,0:npts_range-1) = WS(indexes)
      HI_new(i,0:npts_range-1) = HI(indexes)
    end if
;	print(indexes)
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do
;print(WS_new)
;print(HI_new)

;===========================================================================
; Begin plotting section.
;


res@gsnMaximize                   = True
res@gsnFrame                      = False
res@gsnDraw                       = False


res@tmXBMajorThicknessF			= 5.0
res@tmYLMajorThicknessF			= 5.0
res@tmXTOn						= False
res@tmYROn						= False
res@tmBorderThicknessF            = 5.0
res@tmXBMode					= "Manual"

;mpres@tiMainOn                      = True
;mpres@tiMainString                  = "Number of Heatwave days in 2018"


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
	if (.not.ismissing(HI_new(i,0)))
res@xyMarkerColor      = colors(i,:)
res@xyMarkerSizeF      = 0.035    ;+0.007
plot = gsn_csm_xy(wks,WS_new(i,:),HI_new(i,:),res)
	break
	end if
end do


  overlays = new(num_distinct_markers-1,graphic)
  do i = n, num_distinct_markers-1
    if (.not.ismissing(HI_new(i,0)))
      res@xyMarkerColor      = colors(i,:)
      res@xyMarkerSizeF      = 0.035	;+0.007
	 overlays(i-1) =  gsn_csm_xy(wks,WS_new(i,:),HI_new(i,:),res)
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
