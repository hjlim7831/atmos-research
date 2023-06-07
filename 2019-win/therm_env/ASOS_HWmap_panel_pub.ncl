undef("add_right_title")
function add_right_title(wks,plot,title)
local txres,font_height_txid,amres
begin

txres					= True
txres@txAngleF			= 90.
txres@txFontHeightF		= 0.036

txid = gsn_create_text(wks,title, txres)

amres					= True
amres@amParallelPosF	= -0.85

amres@amOrthogonalPosF	= 0.0
amres@amJust			= "CenterCenter"

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

;tnum = tointeger((upper-lower)/step + 1)
tnum = tointeger((upper-lower)/step + 1) +1

 nboxes_left  = (center - (lower - step))/step
 nboxes_right = ((upper + 2*step) - center)/step

;
; Calculate the number of colors in the map on the left and right hand sides.
;
 ncolors_left = (center_color - color_start + 1)
 ncolors_right = (color_end - center_color)


 output = True

;
;
; Either the lower or upper extent of the color map will be adjusted. If
; the magnitude of the lower limit is less than the magnitude of the
; upper limit, then the lower limit has to be "moved in" towards the
; center color. Oppositely, the upper limit will be moved. If both the
; lower and upper numerical values are the same, then pass back 2 as the
; lower extent and color_end (number of colors) as the upper extent (use
; the whole map in other words).
;
 if(abs(lower) .lt. abs(upper))then

  output@ColorStart = round(center_color - (ncolors_right/nboxes_right)*nboxes_left, 3)
  output@ColorEnd   = color_end

 else

;---no "else if" in NCL :(
  if(abs(lower) .gt. abs(upper))then
   output@ColorStart = 2
   output@ColorEnd   = round(center_color + (ncolors_left/nboxes_left)*nboxes_right, 3)
  else
   output@ColorStart = 2
   output@ColorEnd   = color_end
  end if

 end if

  output@ColorIndex = round(fspan(output@ColorStart,output@ColorEnd,tnum),3)



 return(output)

end


undef("add_labelbar")
procedure add_labelbar(wks,plot,levels,colors,lbres)
local labels
begin
  nlevels = dimsizes(levels)
;----------------------------------------------------------------------
; Draw a labelbar
;----------------------------------------------------------------------

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
  amres@amParallelPosF   =  0.75   ; keep labelbar centered
  amres@amOrthogonalPosF = -0.70   ; move down and outside of plot

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


;---------------------------


diro = "~/2019-win/therm_env/"
filo = "varboxv6.csv"
filo1 = "csv/META_ASOS_1973-2019_2020-02-17_revisedv2.csv"
ncol = 3

lines1 = asciiread(diro+filo,-1,"string") ; bring variable data
nlines1 = dimsizes(lines1)
delim = ","
fields1 = str_split_csv(lines1,delim,0)


;printVarSummary(fields1)
;print(fields1)  

var_list = fields1(0,:8)
varbox = tofloat(fields1(1:,:8)) ; 60 X 5

wvarlen = dimsizes(varbox(0,:)) ; 12 = 4 X 3
varlen = wvarlen/ncol

TITLE = new((/varlen,ncol/),string)

;TITLE(0,0) = "(a) 2018"
;TITLE(0,1) = "(b) 1979 - 2019"
;TITLE(0,2) = "(c) anomaly"
;TITLE(1,:) = (/"(d)","(e)","(f)"/)
;TITLE(2,:) = (/"(g)","(h)","(i)"/)

TITLE(:,0) = (/"(a)","(d)","(g)"/) + " 2018"
TITLE(:,1) = (/"(b)","(e)","(h)"/) + " 1979 - 2019"
TITLE(:,2) = (/"(c)","(f)","(i)"/) + " anomaly"

AVG = new((/varlen,ncol/),string)
AVG(0,:) = "avg: "+ (/"28.14","7.75","20.40"/) + " days"
AVG(1,:) = "avg: "+ (/"35.18","34.38","0.79"/) + " ~S2~o  C"
AVG(2,:) = "avg: "+ (/"29.29","28.36","0.96"/) + " ~S2~o  C"


lbTITLE = new((/varlen,ncol/),string)
lbTITLE(:,0) = " "
lbTITLE(0,1:) = "(days)"
lbTITLE(1:,1:) = "(~S2~o  C)"

;timetitle = new((/varlen,ncol/),string)

;timetitle(0,:) = (/"2018", "1973 - 2019", "anomaly"/)
;timetitle(1:,:) = " "


lRANGE = new((/3,varlen,ncol/),float)
;============== min, max, number
;== mean
lRANGE(:,0,0) = (/0.,44.,12./)
lRANGE(:,1,0) = (/33.,38.,11./)
lRANGE(:,2,0) = (/26.,31.5,12./)

;== Ano.
lRANGE(:,0,2) = (/-3.,33.,13./)
lRANGE(:,1,2) = (/-0.5,2.5,7./)
lRANGE(:,2,2) = (/-1.,2.,7./)

lRANGE(:,0,1) = lRANGE(:,0,0)
lRANGE(:,1,1) = lRANGE(:,1,0)
lRANGE(:,2,1) = lRANGE(:,2,0)

vTITLE = new((/varlen,ncol/),string)

vTITLE = " "
vTITLE(0,0) = "heat wave duration"
vTITLE(1,0) = "daily maximum temperature"
vTITLE(2,0) = "daily average temperature"



;====for station data


lines = asciiread(diro+filo1,-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

STNNUM = fields(:,0)
stnlat = tofloat(fields(:,2))
stnlon = tofloat(fields(:,3))
npts = dimsizes(stnlat)

type = "oldps"
;type = "png"
;type = "x11"


wks = gsn_open_wks(type,"HW_panel_pub")              ; send graphics to PNG file

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
mpres@mpMaxLonF                     = max(stnlon) +0.5

mpres@mpFillOn                      = False
;mpres@mpLandFillColor				= "gray95"
mpres@mpOutlineDrawOrder            = "Draw"
mpres@mpOutlineOn                   = True
mpres@mpOutlineBoundarySets         = "National"

;mpres@mpDataBaseVersion             = "HighRes" ;"MediumRes"
mpres@mpDatabaseVersion             = "MediumRes"
mpres@mpNationalLineThicknessF      = 3.0
mpres@mpNationalLineColor           = "Gray12"

mpres@mpGeophysicalLineColor        = "Gray12"
mpres@mpGeophysicalLineThicknessF   = 3.0
;mpres@mpLimbLineThicknessF          = 1.5

mpres@tmXBMode                      = "Explicit"
mpres@tmXBValues                    = ispan(125,131,1)
mpres@tmXBLabels                    = ispan(125,131,1) +"~S2~o   E"
mpres@tmXBLabelFontHeightF          = 0.026
mpres@tmYLValues                    = ispan(32,40,1)
mpres@tmYLLabels                    = ispan(32,40,1) +"~S2~o   N"
mpres@tmYLLabelFontHeightF          = 0.026
mpres@tmXBMajorThicknessF           = 3.0
mpres@tmYLMajorThicknessF           = 3.0
mpres@tmXTOn                        = False
mpres@tmYROn                        = False
mpres@tmBorderThicknessF            = 3.0


;mpres@tiMainOn                      = True


mpres@gsnLeftStringFontHeightF          = 0.030+0.005
;mpres@gsnLeftStringParallelPosF            = 1.2
mpres@gsnLeftStringOrthogonalPosF       = 0.015+0.005
mpres@gsnRightStringOrthogonalPosF		= -0.98
mpres@gsnRightStringParallelPosF		= 0.92
mpres@gsnRightStringFontHeightF			= 0.030

  gsres               = True
  gsres@gsMarkerIndex = 16          ; Use filled dots for markers.

;We're going to use 

;============================================================================
;============================Starting Do loop================================
;============================================================================


n1 = 0
n2 = 0

plots1 = new((varlen*(ncol-1)),graphic)
plots2 = new(varlen,graphic)
amid1 = new((varlen*(ncol-1)),graphic)
amid2 = new(varlen,graphic)

;ii = 8
do ii = 0, varlen*ncol -1

nvar = ii/3
nncol = mod(ii,3)
print("nvar:"+nvar)
print("nncol:"+nncol)


var = varbox(:,ii)
var_name = var_list(ii)

print(var)
print("max: "+max(var))
print("min: "+min(var))

grid_min = lRANGE(0,nvar,nncol)
grid_max = lRANGE(1,nvar,nncol)
w_num = tointeger(lRANGE(2,nvar,nncol))
grid_step = (grid_max - grid_min)/tofloat(w_num -1)
grid_center = 0.0

levels = fspan(grid_min,grid_max,w_num)

  nlevels = dimsizes(levels)


if nncol .ne. 2 then
;  colors  = span_color_rgba("MPL_YlOrRd",nlevels+1)
;  colors  = span_color_rgba("MPL_RdYlGn",nlevels+1)
;  colors = colors(::-1,:)
;  colors  = span_color_rgba("hotres",nlevels+1)
  colors = span_color_rgba("NCV_jet",nlevels+1)

else
 gsn_range = gsnColorRange(grid_min,grid_max,grid_step,grid_center,64,34)
 cmap = read_colormap_file("cmp_b2r")
; cmap = read_colormap_file("MPL_RdBu")
; cmap = read_colormap_file("MPL_coolwarm")
 cc = read_colormap_file("MPL_Reds")
; cmap = cmap(::-1,:)
 print(gsn_range)



clen = dimsizes(gsn_range@ColorIndex)

colors = new((/clen,4/),float)

do k = 0, clen -1
	IND = gsn_range@ColorIndex(k) -2
	colors(k,:) = cmap(IND,:)
end do
/;
if nvar .eq. 0 then
colors(clen-1,:) = cc(126,:)
colors(clen-2,:) = cc(115,:)
colors(clen-3,:) = cc(105,:)
colors(clen-4,:) = cc(95,:)
colors(clen-5,:) = cc(85,:)
colors(clen-6,:) = cc(75,:)
colors(clen-7,:) = cc(65,:)
colors(clen-8,:) = cc(55,:)
colors(clen-9,:) = cc(45,:)
colors(clen-10,:) = cc(35,:)
colors(clen-11,:) = cc(25,:)
end if
;/
end if

print(colors)

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

mpres@gsnLeftString			= TITLE(nvar,nncol)
mpres@gsnRightString		= AVG(nvar,nncol)
;mpres@tiMainString          = timetitle(nvar,nncol)
  lbres                         = True
  lbres@vpWidthF                = 0.2             ; width
  lbres@vpHeightF               = 0.95             ; height
  lbres@lbPerimOn               = False            ; Turn off perimeter.
; lbres@lbOrientation           = "Horizontal"     ; Default is vertical.
  lbres@lbLabelAlignment        = "InteriorEdges"  ; Default is "BoxCenters"
  lbres@lbMonoFillPattern       = True             ; Fill them all solid.
  lbres@lbLabelFontHeightF      = 0.025 +0.005     ; label font height
  lbres@lbBoxLineThicknessF     = 3.0
;  lbres@lbTitleExtentF          = 0.001
  lbres@lbTitleFontHeightF      = 0.020 + 0.015
  lbres@lbTitleDirection        = "Across"
;  lbres@lbTitleAngleF           = 270
 lbres@lbTitleJust             = "BottomCenter"
  lbres@lbTitlePosition         = "Top"
;  lbres@lbTitleFontAspectF     = 0.98
  lbres@lbLabelStride			= 2


lbres@lbTitleString         = lbTITLE(nvar,nncol)
;mpres@tiYAxisString		= vTITLE(nvar,nncol)
lbres@lbFillColors          = colors           ; Colors for boxes.
; Loop through each grouping of markers, and draw them one set at
; a time, assigning the proper color and size with gsn_marker.
;
  pmid = new((/num_distinct_markers/),graphic)

if nncol .ne. 2 then

	plots1(n1) = gsn_csm_map(wks,mpres)
	do i = 0, num_distinct_markers-1
    	if (.not.ismissing(lat_new(i,0)))
      		gsres@gsMarkerColor      = colors(i,:)
      		gsres@gsMarkerSizeF      = 0.008	;+0.007
      		pmid(i) = gsn_add_polymarker(wks,plots1(n1),lon_new(i,:),lat_new(i,:),gsres)
    	end if
  	end do
	
	amid1(n1) = add_right_title(wks,plots1(n1),vTITLE(nvar,nncol))
	str1 = unique_string("markers")
	plots1@$str1$ = pmid

 	if nncol .eq. 1 then
	add_labelbar(wks,plots1(n1),levels,colors,lbres)
	 end if
	n1 = n1 + 1
else

	plots2(n2) = gsn_csm_map(wks,mpres)
	do i = 0, num_distinct_markers-1
    	if (.not.ismissing(lat_new(i,0)))
      		gsres@gsMarkerColor      = colors(i,:)
      		gsres@gsMarkerSizeF      = 0.008 ;+0.007
      		pmid(i) = gsn_add_polymarker(wks,plots2(n2),lon_new(i,:),lat_new(i,:),gsres)
    	end if
  	end do
	
	amid2(n2) = add_right_title(wks,plots2(n2),vTITLE(nvar,nncol))
	str1 = unique_string("markers")
	plots2@$str1$ = pmid

	add_labelbar(wks,plots2(n2),levels,colors,lbres)
	n2 = n2 + 1

	delete([/gsn_range/])
end if

delete([/levels,colors,lat_new,lon_new,pmid,lbres/])



end do


;=============================================================
;============================ Draw labelbar and advance frame.
;=============================================================
;plot = new(1,graphic)


;=== Draw panel

plot_length = 1./tofloat(ncol) * 2
print(plot_length)


panel_res					= True
panel_res@gsnFrame			= False
;panel_res@gsnDraw			= False
panel_res@gsnPanelTop		= 0.935
panel_res@gsnPanelBottom	= 0.025
panel_res@gsnPanelLeft		= 0.107
panel_res@gsnPanelRight		= 0.56
panel_res@gsnPanelYWhiteSpacePercent = 4.9

gsn_panel(wks,(/plots1/),(/varlen,2/),panel_res)

panel_res@gsnPanelLeft		= 0.62
panel_res@gsnPanelTop		= 0.98
panel_res@gsnPanelBottom	= 0.005
panel_res@gsnPanelRight		= 0.91
panel_res@gsnPanelYWhiteSpacePercent = 0

gsn_panel(wks,(/plots2/),(/varlen,1/),panel_res)

frame(wks)

end     
