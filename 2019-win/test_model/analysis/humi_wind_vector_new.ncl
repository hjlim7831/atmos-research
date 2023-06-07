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

name = "picture/HUMI_alb0.7"

colorb = "ncl_default";"MPL_rainbow"
zoom = True
DIUR = True

diro = "~/2019-win/test_model/"
;a = addfile(diro+"analysis/z3_a2wrf","r")
a = addfile(diro+"analysis/z3_a7wrf","r")

; type = "x11"
 type = "png"
; type = "ps"
; type = "ncgm"

tstart = 0+3
tend = 890
intt = 1

if DIUR then
	name = name+"_diur"
end if

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

loc = wrf_user_ll_to_ij(a,(/llon,llon,rlon,rlon/),(/llat,rlat,llat,rlat/),True) -1
indi = loc(0,:)
indj = loc(1,:)

ist = min(indi)
iend = max(indi)
jst = min(indj)
jend = max(indj)

t2 = a->T2(tstart:tend:intt,jst:jend,ist:iend)*1. -273.15

;=========== for full Domain ======================
else

t2 = a->T2(tstart:tend:intt,:,:)*1. -273.15
ist = 0
iend = dimsizes(t2(0,0,:))-1
jst = 0
jend = dimsizes(t2(0,:,0))-1

end if
;============ Calculating ... ====================

u10 = a->U10(tstart:tend:intt,jst:jend,ist:iend)*1.
v10 = a->V10(tstart:tend:intt,jst:jend,ist:iend)*1.
wspd = (u10^2.+v10^2.)^0.5
rh_2 = wrf_user_getvar(a,"rh2",-1)
rh2 = rh_2(tstart:tend:intt,jst:jend,ist:iend)
q2 = a->Q2(tstart:tend:intt,jst:jend,ist:iend)
P = a->PSFC(tstart:tend:intt,jst:jend,ist:iend)/100.

e = q2/0.622*P

;hi2 = -42.379+2.04901523*tk+10.14333127*rh2-0.22475541*tk*rh2-0.00683783*tk^2.-0.05481717*rh2^2.+0.00122874*tk^2.*rh2+0.00085282*tk*rh2^2.-0.00000199*tk^2.*rh2^2.

;di2 = t2-(0.55-0.005*rh2)*(t2-14.5)

;cpi2 = (0.37+0.51*wspd^0.63)*(36.5-t2)

h2 = t2+5./9.*(e-10.)

lat = a->XLAT(0,jst:jend,ist:iend)
lon = a->XLONG(0,jst:jend,ist:iend)

dimj = dimsizes(t2(0,:,0))
dimi = dimsizes(t2(0,0,:))

if DIUR then
t2_m = new((/diur,dimj,dimi/),float)
u10_m = new((/diur,dimj,dimi/),float)
v10_m = new((/diur,dimj,dimi/),float)

t2_m = 0
u10_m = 0
v10_m = 0

dimt = (tend-tstart)/intt +1

do k = 0, diur -1
    n = 0
    do m = k, dimt -1, diur
        t2_m(k,:,:) = t2_m(k,:,:) + h2(m,:,:)
        u10_m(k,:,:) = u10_m(k,:,:) + u10(m,:,:)
        v10_m(k,:,:) = v10_m(k,:,:) + v10(m,:,:)
        n = n + 1
    end do
    t2_m(k,:,:) = t2_m(k,:,:)/int2flt(n)
    u10_m(k,:,:) = u10_m(k,:,:)/int2flt(n)
    v10_m(k,:,:) = v10_m(k,:,:)/int2flt(n)
end do

;t2_m = (t2_m-32.)*5./9.

end if



dimx = dimsizes(t2(0,0,:))
dimy = dimsizes(t2(0,:,0))

times = wrf_user_getvar(a,"times",-1)

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

;==================== Plotting Section ==============================

;==== DIur
if DIUR then
;cst = 24
;ced = 32
;clen = 17
cst = 25
ced = 42
clen = 35

else
;==== indiv
cst = 19
ced = 28
clen = 19

end if

  wks = gsn_open_wks(type,diro+name)
  cmap = read_colormap_file(colorb)
/;
colors = new((/clen,4/),float)
if DIUR then
colors(21,:) = cmap(253,:)
colors(20,:) = cmap(250,:)
colors(19,:) = cmap(247,:)
colors(18,:) = cmap(244,:)
colors(17,:) = cmap(238,:)
colors(16,:) = cmap(220,:)
colors(15,:) = cmap(210,:)
colors(14,:) = cmap(195,:)
colors(13,:) = cmap(180,:)
colors(12,:) = cmap(165,:)
colors(11,:) = cmap(150,:)
colors(10,:) = cmap(135,:)
colors(9,:) = cmap(120,:)
colors(8,:) = cmap(105,:)
colors(7,:) = cmap(90,:)
colors(6,:) = cmap(75,:)
colors(5,:) = cmap(60,:)
colors(4,:) = cmap(45,:)
colors(3,:) = cmap(30,:)
colors(2,:) = cmap(20,:)
colors(1,:) = cmap(10,:)
colors(0,:) = cmap(2,:)

else
colors(28,:) = cmap(253,:)
colors(27,:) = cmap(248,:)
colors(26,:) = cmap(244,:) ; pink
colors(25,:) = cmap(238,:)
colors(24,:) = cmap(230,:)
colors(23,:) = cmap(222,:)
colors(22,:) = cmap(214,:)
colors(21,:) = cmap(206,:)
colors(20,:) = cmap(198,:)
colors(19,:) = cmap(190,:)
colors(18,:) = cmap(180,:)
colors(17,:) = cmap(170,:)
colors(16,:) = cmap(160,:)
colors(15,:) = cmap(150,:)
colors(14,:) = cmap(140,:)
colors(13,:) = cmap(130,:)
colors(12,:) = cmap(120,:)
colors(11,:) = cmap(110,:)
colors(10,:) = cmap(100,:)
colors(9,:) = cmap(90,:)
colors(8,:) = cmap(80,:)
colors(7,:) = cmap(70,:)
colors(6,:) = cmap(60,:)
colors(5,:) = cmap(50,:)
colors(4,:) = cmap(40,:)
colors(3,:) = cmap(30,:)
colors(2,:) = cmap(20,:)
colors(1,:) = cmap(10,:)
colors(0,:) = cmap(2,:)

end if
;/
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
  res_m@mpLambertParallel1F    = a@TRUELAT1		   ;
  res_m@mpLambertParallel2F    = a@TRUELAT2		   ;
  res_m@mpLambertMeridianF     = a@CEN_LON		   ;
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
if DIUR then
res_v@vcRefMagnitudeF           = 2.0
else
res_v@vcRefMagnitudeF           = 3.0	   ;
end if

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
;res_m@cnLevels 					= fspan(21,37,33)
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
  locr = wrf_user_ll_to_ij(a,x,y,locopt)
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

if DIUR then
do ii = 0, diur -1
	print("time (UTC) : "+times(tstart+ii*intt))
	print(max(t2_m(ii,:,:)))
	print(min(t2_m(ii,:,:)))
	res_m@tiMainString = ii+" LST"
	plot = gsn_csm_contour_map(wks,t2_m(ii,y_start:y_end,x_start:x_end),res_m)
	res_v@tmXBOn = False
	res_v@tmYLOn = False
	vector = gsn_csm_vector(wks,u10_m(ii,y_start:y_end,x_start:x_end),v10_m(ii,y_start:y_end,x_start:x_end),res_v)
	do i = 0, 645
		boundary(i,0) = gsn_add_polyline(wks,plot,x(i:i+1),y(i:i+1),resp)
	end do
	overlay(plot,vector)
	plot = add_map_tickmarks2(wks,plot,tmres)
	gsn_panel(wks,plot,(/1,1/),pnlres)
end do

else

do ii = 433, 456
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
  overlay(plot,vector)
  plot = add_map_tickmarks2(wks,plot,tmres)
  gsn_panel(wks,plot,(/1,1/),pnlres)
end do

end if


end
