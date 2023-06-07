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
  lbres@vpHeightF       	   	= 0.85             ; height
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

  labels = sprintf("%4.1f",levels)

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
  amres@amOrthogonalPosF = -0.5   ; move down and outside of plot

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

;  levels = (/0.,4.,8.,12.,16.,20.,24.,28.,32.,36.,40./)  
;  levels = (/0.,0.5,1.,1.5,2.,2.5,3./)
;  levels = (/0,3,6,9,12,15,18,21,24,27,30/)
;  levels = (/0.,2.,4.,6.,8.,10.,12.,14.,16.,18.,20./)
  
;  levels = (/27.,27.5,28.,28.5,29.,29.5,30.,30.5/) ; HWmeT
;  levels = (/33., 33.5, 34., 34.5/) ; HWmaT
;  levels = (/21.,21.5,22.,22.5,23.,23.5,24.,24.5,25.,25.5,26./) ; HWmiT
;  levels = (/33.5,34.,34.5,35.,35.5,36,36.5,37/)  ; HWmaT_2018
;  levels = (/27.5,28.,28.5,29.,29.5,30.,30.5,31./) ; HWmeT_2018
  levels = (/22.,22.5,23.,23.5,24.,24.5,25,25.5,26.,26.5,27./) ; HWmiT_2018

  nlevels = dimsizes(levels)
  colors  = span_color_rgba("MPL_OrRd",nlevels+1)

;---------------------------



diro = "~/2019-win/therm_env/"

lines1 = asciiread(diro+"varbox.csv",-1,"string") ; bring variable data
nlines1 = dimsizes(lines1)
delim = ","
fields1 = str_split_csv(lines1,delim,0)

;printVarSummary(fields1)
;print(fields1)  

var_list = fields1(0,:)
varbox = tofloat(fields1(1:,:)) ; 60 X 5


;====for station data


lines = asciiread(diro+"csv/META_ASOS_1973-2019_2020-02-17_revised.csv",-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

STNNUM = fields(:,0)
stnlat = tofloat(fields(:,2))
stnlon = tofloat(fields(:,3))
npts = dimsizes(stnlat)

;We're going to use 

ii = 7

var = varbox(:,ii)
var_name = var_list(ii)

print(var)
print("max: "+max(var))
print("min: "+min(var))



;------------------------------ 
; Create X and Y arrays to hold the points for each range and initialize
; them to missing values.  We want to use num_distinct_markers
; different colors, so we need num_distinct_markers sets of X and
; Y points.
;
  num_distinct_markers = nlevels+1        ; number of distinct markers
  lat_new = new((/num_distinct_markers,npts/),float,-999)
  lon_new = new((/num_distinct_markers,npts/),float,-999)
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
      lat_new(i,0:npts_range-1) = stnlat(indexes)
      lon_new(i,0:npts_range-1) = stnlon(indexes)
    end if
    delete(indexes)            ; Necessary b/c "indexes" may be a different
                               ; size next time.
  end do

;===========================================================================
; Begin plotting section.
;

;type = "png"
type = "x11"

  wks = gsn_open_wks(type,var_name)              ; send graphics to PNG file

mpres                               = True
mpres@gsnMaximize                   = True
mpres@gsnFrame                      = False
mpres@gsnDraw                       = False

;mpres@cnLineLabelPlacementMode     = "Constant"
;mpres@cnLineLabelFontColor         = "Gray15"
;mpres@cnLineDashSegLenF            = 0.3

;mpres@cnFillOn                     = True

mpres@mpMinLatF                     = min(stnlat) -0.25
mpres@mpMinLonF                     = min(stnlon) -0.5
mpres@mpMaxLatF                     = max(stnlat) +0.5
mpres@mpMaxLonF                     = max(stnlon) +0.25 -1.25

mpres@mpFillOn                      = False
mpres@mpOutlineDrawOrder            = "PreDraw"
mpres@mpOutlineOn                   = True
mpres@mpOutlineBoundarySets         = "National"

;mpres@mpDataBaseVersion             = "HighRes" ;"MediumRes"
mpres@mpDatabaseVersion             = "MediumRes"
mpres@mpNationalLineThicknessF      = 5.0
mpres@mpNationalLineColor			= "Gray12"

mpres@mpGeophysicalLineColor		= "Gray12"
mpres@mpGeophysicalLineThicknessF   = 5.0
;mpres@mpLimbLineThicknessF          = 1.5



mpres@tmXBMode                      = "Explicit"
mpres@tmXBValues                    = ispan(125,131,1)
mpres@tmXBLabels                    = ispan(125,131,1) +" E"
mpres@tmYLValues                    = ispan(32,40,1)
mpres@tmYLLabels                    = ispan(32,40,1) +" N"
mpres@tmXBMajorThicknessF			= 5.0
mpres@tmYLMajorThicknessF			= 5.0
mpres@tmXTOn						= False
mpres@tmYROn						= False
mpres@tmBorderThicknessF            = 5.0


;mpres@tiMainOn                      = True
;mpres@tiMainString                  = "Number of Heatwave days in 2018"

mpres@gsnRightString					= "(days)"
mpres@gsnRightStringFontHeightF			= 0.015
mpres@gsnRightStringParallelPosF		= 1.2
mpres@gsnRightStringOrthogonalPosF		= 0.0


  map = gsn_csm_map(wks,mpres)

;--Create logical variables to hold the marker resources.
  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.
;
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.
;
  pmid = new(num_distinct_markers,graphic)
  do i = 0, num_distinct_markers-1
    if (.not.ismissing(lat_new(i,0)))
      gsres@gsMarkerColor      = colors(i,:)
      gsres@gsMarkerSizeF      = 0.042	;+0.007
      pmid(i) = gsn_add_polymarker(wks,map,lon_new(i,:),lat_new(i,:),gsres)
    end if
  end do

;---Draw labelbar and advance frame.
;plot = new(1,graphic)
add_labelbar(wks,map,levels,colors)

panel_res					= True
panel_res@gsnPanelBottom	= 0.2


gsn_panel(wks,map,(/1,1/),panel_res)

;  draw(map)
;  frame(wks)

end     
