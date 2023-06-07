load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

undef("add_map_tickmarks2")
function add_map_tickmarks2(wks,plot,res)
local res2, bres, vpx, vpy, vpw, vph, xndc, yndc, npts, n, j, nlat, \
nlon, delta, bot_lon, top_lon, lft_lat, rgt_lat, xblabels, xbvalues, \
xtlabels, xtvalues, yllabels, ylvalues, yrlabels, yrvalues, xfix, \
xlat, xlon, yfix, annoid, anno_str
begin
;---Make a copy of the original resource list.
  res2 = res

;---Retrieve edges of plot in NDC space.
  getvalues plot
     "vpXF"      :  vpx
     "vpYF"      :  vpy
     "vpWidthF"  :  vpw
     "vpHeightF" :  vph
  end getvalues

;---Turn off tickmarks associated with map. We want to add our own.
  setvalues plot
    "pmTickMarkDisplayMode" : "Never"
  end setvalues

;---Initialize resources for tickmark plot. User shouldn't change these.
  bres                          = True
  bres@vpXF                     = vpx
  bres@vpYF                     = vpy
  bres@vpWidthF                 = vpw
  bres@vpHeightF                = vph
  bres@trXMinF                  = vpx
  bres@trXMaxF                  = vpx + vpw
  bres@trYMinF                  = vpy - vph
  bres@trYMaxF                  = vpy
  bres@tmEqualizeXYSizes        = True

;---This resource the user can change in main code if desired.
  bres@gsnTickMarksPointOutward = get_res_value(res2,"gsnTickMarksPointOutward",True)

;
; NDC Points to scan on X and Y axes. These arrays will be used to
; find the closest NDC pair that gets us close to the location where
; we want a tickmark.
;
  npts = 100000   ; Increase to get closer match for tickmarks
  xndc = fspan(vpx,vpx+vpw,npts)
  yndc = fspan(vpy-vph,vpy,npts)

  n    = dimsizes(yndc) 
  xfix = new(n,float)
  yfix = new(n,float)
  xlon = new(n,float)
  xlat = new(n,float)
  delta = 0.001

;---Left axis tickmarks
  if(isatt(res2,"tmYLValues")) then
    lft_lat    = get_res_value(res2,"tmYLValues",-1)
    nlat       = dimsizes(lft_lat)
    ylvalues = new(nlat,float)
    yllabels = new(nlat,string)
    xfix  = vpx + 0.0001 ; Just a smidge into the plot to make sure we don't
                         ; get missing values returned.
;
; Loop across each left latitude value that we want a tickmark for,
; and try to find the closest X,Y NDC coordinate pair along this axis.
;
    NhlNDCToData(plot,xfix,yndc,xlon,xlat)
    do j=0,dimsizes(lft_lat)-1
      NhlNDCToData(plot,xfix,yndc,xlon,xlat)
      ii = minind(fabs(xlat-lft_lat(j)))
      if(.not.any(ismissing(ii)).and.fabs(xlat(ii)-lft_lat(j)).le.delta)
        yllabels(j) = fabs(lft_lat(j)) + ""
        ylvalues(j) = yndc(ii(0))
        if(lft_lat(j).lt.0) then
          yllabels(j) = yllabels(j) + "~S~o~N~S"
        end if
        if(lft_lat(j).gt.0) then
          yllabels(j) = yllabels(j) + "~S~o~N~N"
        end if
      end if
      delete(ii)
    end do
    bres@tmYLMode   = "Explicit"
    bres@tmYLValues = ylvalues
    bres@tmYLLabels = get_res_value(res2,"tmYLLabels",yllabels)
  else
    bres@tmYLOn       = False
    bres@tmYLLabelsOn = False
  end if

;---Right axis tickmarks
  if(isatt(res2,"tmYRValues")) then
    rgt_lat    = get_res_value(res2,"tmYRValues",-1)
    nlat       = dimsizes(rgt_lat)
    yrvalues = new(nlat,float)
    yrlabels = new(nlat,string)

    xfix  = vpx + vpw - 0.0001 ; Just a smidge into the plot to make sure we don't
                               ; get missing values returned.
;
; Loop across each right latitude value that we want a tickmark for,
; and try to find the closest X,Y NDC coordinate pair along this axis.
;
    do j=0,dimsizes(rgt_lat)-1
      NhlNDCToData(plot,xfix,yndc,xlon,xlat)
      ii = minind(fabs(xlat-rgt_lat(j)))
      if(.not.any(ismissing(ii)).and.fabs(xlat(ii)-rgt_lat(j)).le.delta)
        yrlabels(j) = fabs(rgt_lat(j)) + ""
        yrvalues(j) = yndc(ii(0))
        if(rgt_lat(j).lt.0) then
          yrlabels(j) = yrlabels(j) + "~S~o~N~S"
        end if
        if(rgt_lat(j).gt.0) then
          yrlabels(j) = yrlabels(j) + "~S~o~N~N"
        end if
      end if
      delete(ii)
    end do
    bres@tmYROn       = True
    bres@tmYRLabelsOn = True
    bres@tmYUseLeft   = False
    bres@tmYRMode     = "Explicit"
    bres@tmYRValues   = yrvalues
    bres@tmYRLabels   = get_res_value(res2,"tmYRLabels",yrlabels)
  else
    bres@tmYUseLeft   = False
    bres@tmYROn       = False
    bres@tmYRLabelsOn = False
  end if

;---Top axis tickmarks
  if(isatt(res2,"tmXTValues")) then
    top_lon    = get_res_value(res2,"tmXTValues",-1)
    nlon       = dimsizes(top_lon)
    xtvalues = new(nlon,float)
    xtlabels = new(nlon,string)

    yfix  = vpy - 0.0001 ; Just a smidge into the plot to make sure we don't
                         ; get missing values returned.
;
; Loop across each top longitude value that we want a tickmark for,
; and try to find the closest X,Y NDC coordinate pair along this axis.
;
    do j=0,dimsizes(top_lon)-1
      NhlNDCToData(plot,xndc,yfix,xlon,xlat)
      ii = minind(fabs(xlon-top_lon(j)))
      if(.not.any(ismissing(ii)).and.fabs(xlon(ii)-top_lon(j)).le.delta)
        xtlabels(j) = fabs(top_lon(j)) + ""
        xtvalues(j) = xndc(ii(0))
        if(top_lon(j).lt.0) then
          xtlabels(j) = xtlabels(j) + "~S~o~N~W"
        end if
        if(top_lon(j).gt.0) then
          xtlabels(j) = xtlabels(j) + "~S~o~N~E"
        end if
      end if
      delete(ii)
    end do
    bres@tmXTOn       = True
    bres@tmXTLabelsOn = True
    bres@tmXUseBottom = False
    bres@tmXTMode     = "Explicit"
    bres@tmXTValues   = xtvalues
    bres@tmXTLabels   = get_res_value(res2,"tmXTLabels",xtlabels)
  else
    bres@tmXUseBottom = False
    bres@tmXTOn       = False
    bres@tmXTLabelsOn = False
  end if

;---Bottom axis tickmarks
  if(isatt(res2,"tmXBValues")) then
    bot_lon    = get_res_value(res2,"tmXBValues",-1)
    nlon       = dimsizes(bot_lon)
    xbvalues = new(nlon,float)
    xblabels = new(nlon,string)

    yfix  = vpy-vph + 0.0001 ; Just a smidge into the plot to make sure 
                             ; we don't get missing values returned.
;
; Loop across each bottom longitude value that we want a tickmark for,
; and try to find the closest X,Y NDC coordinate pair along this axis.
;
    do j=0,dimsizes(bot_lon)-1
      NhlNDCToData(plot,xndc,yfix,xlon,xlat)
      ii = minind(fabs(xlon-bot_lon(j)))
      if(.not.any(ismissing(ii)).and.fabs(xlon(ii)-bot_lon(j)).le.delta)
        xblabels(j) = fabs(bot_lon(j)) + ""
        xbvalues(j) = xndc(ii(0))
        if(bot_lon(j).lt.0) then
          xblabels(j) = xblabels(j) + "~S~o~N~W"
        end if
        if(bot_lon(j).gt.0) then
          xblabels(j) = xblabels(j) + "~S~o~N~E"
        end if
      end if
      delete(ii)
    end do
    bres@tmXBMode   = "Explicit"
    bres@tmXBValues = xbvalues
    bres@tmXBLabels = get_res_value(res2,"tmXBLabels",xblabels)
  else
    bres@tmXBOn       = False
    bres@tmXBLabelsOn = False
  end if

;
; Now that we are done figuring out where to put tickmarks, and
; what labels to use, get any "tm" resources that might have been
; set by the user, and create a blank plot with thes new tickmarks.
;

;---Get rest of user resources that were set with "tm".
  bres = get_res_eq(res2,"tm")

  bres = True   ; Above call will set bres to True if no "tm" resources, so
                ; make sure it is True still.

  bres@gsnDraw  = False
  bres@gsnFrame = False

;
; Create blank plot with new tickmarks (don't use gsn_csm_blank_plot, 
; because it wants to scale the size of your X and Y axes.)
;
  blank  = gsn_blank_plot(wks,bres)

;
; Attach new tickmarks to original plot. This will allow resizing
; if desired. The default is to attach one plot to the center of
; the other one. These two plots are already the same size.
;
  annoid = gsn_add_annotation(plot,blank,False)

;
; Be sure to return the annotation id, otherwise the
; tickmarks will disappear.
;
  anno_str = unique_string("annoid")
  plot@$anno_str$ = annoid

  return(plot)
end


begin

name = "TW_hovmoller"

colorb = "NCV_blue_red";"MPL_RdBu";"cmp_b2r"
zoom = True
DIUR = False

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"e2wrfout_d03_2018-07-14_12:00:00","r")
a2 = addfile(diro+"e7wrfout_d03_2018-07-14_12:00:00","r")

; type = "x11"
 type = "png"
; type = "ps"
; type = "ncgm"

tstart = 0+3
tend = 890
intt = 1

if zoom then
	name = name+"_zoom"
end if

diur = 24

if zoom then
; ================= for zoom ====================

llat = 37.22
llon = 126.44
rlat = 37.92
rlon = 127.35

loc = wrf_user_ll_to_ij(a1,(/llon,llon,rlon,rlon/),(/llat,rlat,llat,rlat/),True) -1
indi = loc(0,:)
indj = loc(1,:)

ist = min(indi)
iend = max(indi)
jst = min(indj)
jend = max(indj)

t2 = a2->T2(tstart:tend:intt,jst:jend,ist:iend)*1. -a1->T2(tstart:tend:intt,jst:jend,ist:iend)*1.

;=========== for full Domain ======================
else

t2 = a2->T2(tstart:tend:intt,:,:)*1. -a1->T2(tstart:tend:intt,:,:)*1.
ist = 0
iend = dimsizes(t2(0,0,:))-1
jst = 0
jend = dimsizes(t2(0,:,0))-1

end if
;============ Calculating ... ====================

u10 = a2->U10(tstart:tend:intt,jst:jend,ist:iend)*1. - a1->U10(tstart:tend:intt,jst:jend,ist:iend)*1.
v10 = a2->V10(tstart:tend:intt,jst:jend,ist:iend)*1. - a1->V10(tstart:tend:intt,jst:jend,ist:iend)*1.

lat = a1->XLAT(0,jst:jend,ist:iend)
lon = a1->XLONG(0,jst:jend,ist:iend)

dimj = dimsizes(t2(0,:,0))
dimi = dimsizes(t2(0,0,:))


dimx = dimsizes(t2(0,0,:))
dimy = dimsizes(t2(0,:,0))

times = wrf_user_getvar(a1,"times",-1)

print(lat(0,0))
print(lon(0,0))
print(lat(dimy-1,dimx-1))
print(lon(dimy-1,dimx-1))
print(max(t2))
print(min(t2))

print("time (UTC) : "+times(tstart))
print("time (UTC) : "+times(tend))

 x_start = 0  ;smaller
 x_end   = dimx-1  ;smaller
 y_start = 0  ;smaller
 y_end   = dimy-1  ;smaller

; Cross Section

i1 = 10
i2 = 55
jj = 45

lat1 = lat(jj,i1)
lat2 = lat(jj,i2)
lon1 = lon(jj,i1)
lon2 = lon(jj,i2)

latbox = (/lat1,lat2/)
lonbox = (/lon1,lon2/)

xxlon = lon(jj,i1:i2)



;==================== Plotting Section ==============================

;==== indiv
cst = -2.0
ced = 2.0
clen = 17

;type0 = "x11"
type0 = "png"



  wks = gsn_open_wks(type0,"Sample")
  cmap = read_colormap_file(colorb)

;  gsn_define_colormap(wks,colorb)


  res						   = True				; Set some Basic Plot options
  res@gsnDraw 				   = False
  res@gsnFrame 				   = False
  res@pmTickMarkDisplayMode    = "Always"
  res@gsnAddCyclic			   = False
  res@gsnMaximize   		   = False
  res@tfDoNDCOverlay 		   = True

  res_m 					   = res
  res_m@mpOutlineOn            = True
  res_m@mpOutlineBoundarySets  = "National"		   ;
  res_m@mpOutlineDrawOrder     = "PostDraw"		   ;

  ;projection
  res_m@mpProjection           = "LambertConformal" ;
  res_m@mpLambertParallel1F    = a1@TRUELAT1		   ;
  res_m@mpLambertParallel2F    = a1@TRUELAT2		   ;
  res_m@mpLambertMeridianF     = a1@CEN_LON		   ;
  res_m@mpLimitMode            = "Corners"		   ;
  res_m@mpLeftCornerLatF       = lat(0,0)		   ;
  res_m@mpLeftCornerLonF       = lon(0,0)		   ;
  res_m@mpRightCornerLatF      = lat(dimy-1,dimx-1) ;
  res_m@mpRightCornerLonF      = lon(dimy-1,dimx-1) ;
;  res_m@mpLeftCornerLatF      = 37.32
;  res_m@mpLeftCornerLonF      = 126.54
;  res_m@mpRightCornerLatF     = 37.82
;  res_m@mpRightCornerLonF     = 127.25

;  res_m@mpLeftCornerLatF      = 37.48866
;  res_m@mpLeftCornerLonF      = 126.8965
;  res_m@mpRightCornerLatF     = 37.57794
;  res_m@mpRightCornerLonF     = 127.0267

lLat = lat(0,0)
lLon = lon(0,0)
rLat = lat(dimy-1,dimx-1)
rLon = lon(dimy-1,dimx-1)

;;;;;;;;;;;;;;;;; Main string
res_m@tiMainOn 				   = True
res_m@tiMainString = "Temperature at 2 m and wind vector at 10 m : Urban"
res_m@tiMainString 			   = "Temperature at 2 m and wind vector at 10 m : Urban"
;res_m@tiMainString                = "Temperature at 2 m and wind vector at 10 m : 3Gahf"
res_m@tiMainFontHeightF 	   = 0.025

res_v = res
res_v@vcRefMagnitudeF           = 3.0      ;

res_v@vcRefAnnoArrowLineColor   = "black"  ;
res_v@vcRefAnnoArrowUseVecColor = False	   ;
res_v@vcRefLengthF 				= 0.04     ;
res_v@vcMinDistanceF            = 0.04
res_v@vcLineArrowThicknessF     = 5.0	   ;
res_v@vcLineArrowHeadMinSizeF	= 0.01
res_v@vcLineArrowHeadMaxSizeF	= 0.01
res_v@vcRefAnnoString1 			= res_v@vcRefMagnitudeF+" m s~S2~-1" 										   ;
res_v@vcRefAnnoFontHeightF 		= 0.015    ;
res_v@vcRefAnnoString2On 		= False    ;
res_v@vcRefAnnoSide 			= "Bottom" ;
res_v@vcRefAnnoPerimOn 			= False	   ;
;res_v@vcRefAnnoArrowMinOffsetF = 0.2
res_v@vcRefAnnoOrthogonalPosF 	= -1.12    ;
res_v@vcRefAnnoParallelPosF 	= 0.98     ;
res_v@vcRefAnnoBackgroundColor	= -1
;res_v@vcRefAnnoArrowSpaceF 	= 1.7
res_v@gsnLeftString     		= ""
res_v@gsnRightString    		= ""

res_m@lbTitleOn 				= True
res_m@lbOrientation 			= "Vertical"
res_m@pmLabelBarHeightF 		= 0.55
res_m@lbTitleString 			= "(~F34~0~F~C)"
;res_m@lbTitleString 			= "(m s~S2~-1  )"
;res_m@lbTitlePosition 			= "Left"
;res_m@lbTitleDirection 		= "Across"
res_m@lbTitleFontHeightF 		= 0.018
res_m@pmLabelBarOrthogonalPosF  = 0.05
res_m@pmLabelBarParallelPosF 	= 0.55
res_m@lbTitleOffsetF 			= -0.01
res_m@lbBoxLineThicknessF		= 5.0

res_m@cnFillOn 					= True                      ;  ; Create a color fill plot
res_m@cnLinesOn 				= False						  ;
res_m@cnFillPalette				= cmap
res_m@cnLevelSelectionMode 		= "ExplicitLevels" ;
;res_m@cnLevels 					= fspan(22,38,33)
res_m@cnLevels					= fspan(cst,ced,clen)

res_m@tmXTOn 					= False
res_m@tmYROn 					= False

;res@mpMinLonF            =  126.85               ; select a subregion
;res@mpMaxLonF            =  127.05
;res@mpMinLatF            =  37.41
;res@mpMaxLatF            =  37.61
;res@mpMinLonF            =  126.5               ; select a subregion
;res@mpMaxLonF            =  127.5
;res@mpMinLatF            =  37.
;res@mpMaxLatF            =  38.
;res@mpMinLonF            =  126.90               ; select a subregion
;res@mpMaxLonF            =  127.025
;res@mpMinLatF            =  37.485
;res@mpMaxLatF            =  37.585

;;;; domain 2,3,
res_m@mpDataBaseVersion			  = "MediumRes"		  ;
;;;; domain 2,3,
res_m@mpDataBaseVersion 		  = "HighRes"
res_m@pmTickMarkDisplayMode 	  = "Always"
res_m@mpNationalLineThicknessF    = 5.0		  ;
res_m@mpGeophysicalLineThicknessF = 5.0		  ;
res_m@mpLimbLineThicknessF        = 1.5		  ;
res_v@tmBorderThicknessF		  = 5.0


;;;;; Seoul boundary
  SeoulBND = asciiread("./Seoul_Boundary.prn",(/647,2/),"float")
  x = SeoulBND(:,0) ; longitude
  y = SeoulBND(:,1) ; latitude
  boundary = new((/646,6/), graphic)
  locopt = True
  locopt@returnInt = False
  locr = wrf_user_ll_to_ij(a1,x,y,locopt)
 ;print(dimsizes(locr))
  xx = locr(0,:)
  yy = locr(1,:) ;print(xx)
  resp                         = True
  resp@gsLineColor             = "Black"
  resp@gsLineThicknessF        = 5

res_m@tmYLLabelFontHeightF = 0.013
res_m@tmXBLabelFontHeightF = 0.013

;res@mpGridLatSpacingF = 20
;res@mpGridLonSpacing = 0.05 

res_m@gsnPaperOrientation = "portrait"

;res@tmXBValues = fspan(lLon,rLon,5)
;res@tmXBLabels = (/"180","90W","EQ","90E","180"/)

print(dimy)
print(dimx)
res_m@vpHeightF = 0.6 
res_m@vpWidthF  = 0.6

  tmres          = True
;---Set the values you want for the map tickmarks.
  tmres@tmXBLabelFontHeightF = 0.014         ; Default is a bit large
;---We're putting tickmarks on all four axes.
;tmres@tmYLValues = fspan(37.4,37.8,5)
;tmres@tmXBValues = fspan(126.6,127.2,4)
tmres@tmYLValues = fspan(37.0,38.0,11)
tmres@tmXBValues = fspan(126.6,127.4,5)
tmres@tmXBMajorThicknessF         = 5.0
tmres@tmYLMajorThicknessF         = 5.0
tmres@tmBorderThicknessF          = 5.0

res_v@tmYROn	= False
res_v@tmXTOn	= False

pnlres = True

plres = True
plres@gsLineColor = "Red"

;do ii = 433, 456
ii = 0
;do ii = 0, (tend-tstart)/intt
  print("time (UTC) : "+times(tstart+ii*intt))
  print(max(t2(ii,:,:)))
  print(min(t2(ii,:,:)))
  res_m@tiMainString = times(tstart+ii*intt)
  plot = gsn_csm_contour_map(wks,t2(ii,y_start:y_end,x_start:x_end),res_m)
  res_v@tmXBOn = False
  res_v@tmYLOn = False
  vector = gsn_csm_vector(wks,u10(ii,y_start:y_end,x_start:x_end),v10(ii,y_start:y_end,x_start:x_end),res_v)
  do i = 0, 645
     boundary(i,0) = gsn_add_polyline(wks,plot,x(i:i+1),y(i:i+1),resp)
  end do
  dum = gsn_add_polyline(wks,plot,lonbox,latbox,plres)
  
  overlay(plot,vector)
  plot = add_map_tickmarks2(wks,plot,tmres)
  gsn_panel(wks,plot,(/1,1/),pnlres)
;end do


; for hovmiller diagram

dtstart = 12
dtend = 20

ddt = dtend-dtstart+1

dimt = ddt*37
di = i2 - i1 + 1

tbox = new((/dimt,di/),float)

ts = dtstart
te = dtend
dtn = 0
do ii = 0, 37 -1
		tbox(dtn:dtn+ddt-1,:) = t2(ts:te,jj,i1:i2)
	ts = ts + 24
	te = te + 24
	dtn = dtn + ddt
end do
;print(tbox)

tbox!0 = "time"
tbox!1 = "lon"
tbox&lon = xxlon

tbox1 = tbox(:9*ddt-1,:)
tbox2 = tbox(9*ddt:18*ddt-1,:)
tbox3 = tbox(18*ddt:27*ddt-1,:)
tbox4 = tbox(27*ddt:37*ddt-1,:)



printVarSummary(tbox)

res2							= True
res2@cnFillOn                   = True                      ;  ; Create a color fill plot
res2@cnLinesOn                  = False                       ;
res2@cnFillPalette              = cmap
res2@cnLevelSelectionMode       = "ExplicitLevels" ;
res2@cnLevels                   = fspan(cst,ced,clen)
res2@tmYLMode					= "Explicit"
;res2@tmYLValues					= ispan(0,dimt,ddt)
res2@tmXBMode					= "Automatic"
res2@vpWidthF					= 0.4
res2@vpHeightF					= 0.6

 wks2 = gsn_open_wks(type,name)

res21 = res2
res21@tmYLValues = ispan(0,ddt*9-1,ddt)
res21@tmYLLabels = (/"7/15","7/16","7/17","7/18","7/19","7/20","7/21","7/22","7/23"/)

plot1 = gsn_csm_hov(wks2,tbox1,res21)

res22 = res2
res22@tmYLValues = ispan(0,ddt*9-1,ddt)

res22@tmYLLabels = (/"7/24","7/25","7/26","7/27","7/28","7/29","7/30","7/31","8/1"/)

plot2 = gsn_csm_hov(wks2,tbox2,res22)

res23 = res2
res23@tmYLValues = ispan(0,ddt*9-1,ddt)

res23@tmYLLabels = (/"8/2","8/3","8/4","8/5","8/6","8/7","8/8","8/9","8/10"/)

plot3 = gsn_csm_hov(wks2,tbox3,res23)

res24 = res2
res24@tmYLValues = ispan(0,ddt*10-1,ddt)

res24@tmYLLabels = (/"8/11","8/12","8/13","8/14","8/15","8/16","8/17","8/18","8/19","8/20"/)


plot4 = gsn_csm_hov(wks2,tbox4,res24)




end
