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

name = "picture/TW_alb_pub"
name2 = "TW_alb_pub"

colorb = (/"ncl_default","ncl_default","NCV_blue_red"/)

LST = (/13,15,17/)
nlst = dimsizes(LST)

zoom = True
DIUR = False

diro = "~/2019-win/test_model/"
a2 = addfile(diro+"analysis/z3_a2wrf","r")
a7 = addfile(diro+"analysis/z3_a7wrf","r")

; type = "x11"
; type = "png"
 type = "ps"
; type = "ncgm"

if DIUR then
	tstart = 0+3
	tend = 890
	intt = 1
else
	tstart = 433+3
	tend = 456+3
	intt = 1
end if

if DIUR then
TITLE = (/"(a) cool-roof case","(b) conventional-roof case","(c) difference"/)
else
TITLE = new((/3,nlst/),string)
ll1 = new((/3,4/),string)
ll1(:,0) = (/"(a) ","(b) ","(c) "/)
ll1(:,1) = (/"(d) ","(e) ","(f) "/)
ll1(:,2) = (/"(g) ","(h) ","(i) "/)
ll1(:,3) = (/"(j) ","(k) ","(l) "/)
ll2 = (/"cool","conventional","difference"/)
do nst = 0, nlst -1
	TITLE(:,nst) = ll1(:,nst) + sprinti("%2.2i", LST(nst)) + "00 LST, " + ll2
end do
end if
print(TITLE)


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

loc = wrf_user_ll_to_ij(a2,(/llon,llon,rlon,rlon/),(/llat,rlat,llat,rlat/),True) -1
indi = loc(0,:)
indj = loc(1,:)

ist = min(indi)
iend = max(indi)
jst = min(indj)
jend = max(indj)

t2 = a2->T2(tstart:tend:intt,jst:jend,ist:iend)*1.-273.15

;=========== for full Domain ======================
else

t2 = a2->T2(tstart:tend:intt,:,:)*1.-273.15
ist = 0
iend = dimsizes(t2(0,0,:))-1
jst = 0
jend = dimsizes(t2(0,:,0))-1

end if
;============ Calculating ... ====================

t7 = a7->T2(tstart:tend:intt,jst:jend,ist:iend)*1. -273.15
u2 = a2->U10(tstart:tend:intt,jst:jend,ist:iend)*1.
u7 = a7->U10(tstart:tend:intt,jst:jend,ist:iend)*1.
v2 = a2->V10(tstart:tend:intt,jst:jend,ist:iend)*1.
v7 = a7->V10(tstart:tend:intt,jst:jend,ist:iend)*1.

lat = a2->XLAT(0,jst:jend,ist:iend)
lon = a2->XLONG(0,jst:jend,ist:iend)
lui = a2->LU_INDEX(0,jst:jend,ist:iend)

dimj = dimsizes(t2(0,:,0))
dimi = dimsizes(t2(0,0,:))
dimt = dimsizes(t2(:,0,0))

if DIUR then
t2_m2 = new((/diur,dimj,dimi/),float)
u10_m2 = new((/diur,dimj,dimi/),float)
v10_m2 = new((/diur,dimj,dimi/),float)
t2_m7 = new((/diur,dimj,dimi/),float)
u10_m7 = new((/diur,dimj,dimi/),float)
v10_m7 = new((/diur,dimj,dimi/),float)

t2_m2 = 0
u10_m2 = 0
v10_m2 = 0
t2_m7 = 0
u10_m7 = 0
v10_m7 = 0

do k = 0, diur -1
    n = 0
    do m = k, dimt -1, diur
        t2_m2(k,:,:) = t2_m2(k,:,:) + t2(m,:,:)
        u10_m2(k,:,:) = u10_m2(k,:,:) + u2(m,:,:)
        v10_m2(k,:,:) = v10_m2(k,:,:) + v2(m,:,:)
        t2_m7(k,:,:) = t2_m7(k,:,:) + t7(m,:,:)
        u10_m7(k,:,:) = u10_m7(k,:,:) + u7(m,:,:)
        v10_m7(k,:,:) = v10_m7(k,:,:) + v7(m,:,:)
        n = n + 1
    end do
    t2_m2(k,:,:) = t2_m2(k,:,:)/int2flt(n)
    u10_m2(k,:,:) = u10_m2(k,:,:)/int2flt(n)
    v10_m2(k,:,:) = v10_m2(k,:,:)/int2flt(n)
    t2_m7(k,:,:) = t2_m7(k,:,:)/int2flt(n)
    u10_m7(k,:,:) = u10_m7(k,:,:)/int2flt(n)
    v10_m7(k,:,:) = v10_m7(k,:,:)/int2flt(n)

end do

t2box = new((/3,diur,dimj,dimi/),float)
u10box = new((/3,diur,dimj,dimi/),float)
v10box = new((/3,diur,dimj,dimi/),float)

t2box(0,:,:,:) = t2_m7
t2box(1,:,:,:) = t2_m2
t2box(2,:,:,:) = t2_m7 - t2_m2

u10box(0,:,:,:) = u10_m7
u10box(1,:,:,:) = u10_m2
u10box(2,:,:,:) = u10_m7 - u10_m2

v10box(0,:,:,:) = v10_m7
v10box(1,:,:,:) = v10_m2
v10box(2,:,:,:) = v10_m7 - v10_m2

else

t2box = new((/3,dimt,dimj,dimi/),float)
u10box = new((/3,dimt,dimj,dimi/),float)
v10box = new((/3,dimt,dimj,dimi/),float)

t2box(0,:,:,:) = t7
t2box(1,:,:,:) = t2
t2box(2,:,:,:) = t7 - t2

u10box(0,:,:,:) = u7
u10box(1,:,:,:) = u2
u10box(2,:,:,:) = u7 - u2

v10box(0,:,:,:) = v7
v10box(1,:,:,:) = v2
v10box(2,:,:,:) = v7 - v2


end if

setfileoption("nc","Format","LargeFile")
filo = "analysis/tempd_seoul.nc"
system("/bin/rm -f "+diro+filo)
fout = addfile(diro+filo,"c")
fout->t2box = t2box


dimx = dimsizes(t2(0,0,:))
dimy = dimsizes(t2(0,:,0))

times = wrf_user_getvar(a2,"times",-1)

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

  wks = gsn_open_wks(type,diro+name)

;==== Diur
if DIUR then
plen = 3

else
;==== indiv

plen = 3*nlst

end if

plot = new(plen,graphic)
vector = new(plen,graphic)
boundary = new((/646,plen/),graphic)

do jj = 0, plen -1

ntime = jj/3
nncol = mod(jj,3)

tt = LST(ntime) -1

if DIUR then
	if nncol .eq. 2 then
		cst = -1.5
		ced = 1.5
		clen = 13
	else
		cst = 24.
		ced = 32.5
		clen = 18
	end if
else
	if nncol .eq. 2 then
		cst = -2.
		ced = 2.
		clen = 21
	else
		cst = 23.
		ced = 37.
		clen = 29
	end if

end if


  cmap = read_colormap_file(colorb(nncol))

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
  res_m@mpLambertParallel1F    = a2@TRUELAT1		   ;
  res_m@mpLambertParallel2F    = a2@TRUELAT2		   ;
  res_m@mpLambertMeridianF     = a2@CEN_LON		   ;
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
;res_m@tiMainOn 				   = True
;res_m@tiMainString = "Temperature at 2 m and wind vector at 10 m : Urban"
;res_m@tiMainString 			   = "Temperature at 2 m and wind vector at 10 m : Urban"
;res_m@tiMainString                = "Temperature at 2 m and wind vector at 10 m : 3Gahf"
res_m@tiMainFontHeightF 	   = 0.025

res_v = res
if DIUR then
	if nncol .eq. 2 then
		res_v@vcRefMagnitudeF           = 1.0	   ;
	else
		res_v@vcRefMagnitudeF			= 2.0
	end if
else
	if nncol .eq. 2 then
		res_v@vcRefMagnitudeF           = 2.5      ;
	else
		res_v@vcRefMagnitudeF			= 5.0
	end if
end if

res_v@vcRefAnnoArrowLineColor   = "black"  ;
res_v@vcRefAnnoArrowUseVecColor = False	   ;
res_v@vcRefLengthF 				= 0.04     ;
res_v@vcMinDistanceF            = 0.03
res_v@vcLineArrowThicknessF     = 1.0	   ;
res_v@vcLineArrowHeadMinSizeF	= 0.01
res_v@vcLineArrowHeadMaxSizeF	= 0.01
res_v@vcRefAnnoString1 			= res_v@vcRefMagnitudeF+" m s~S2~-1" 										   ;
res_v@vcRefAnnoFontHeightF 		= 0.020    ;
res_v@vcRefAnnoString2On 		= False    ;
res_v@vcRefAnnoSide 			= "Bottom" ;
res_v@vcRefAnnoPerimOn 			= False	   ;
;res_v@vcRefAnnoArrowMinOffsetF = 0.2
res_v@vcRefAnnoOrthogonalPosF 	= -1.15    ;
res_v@vcRefAnnoParallelPosF 	= 0.98     ;
res_v@vcRefAnnoBackgroundColor	= -1
;res_v@vcRefAnnoArrowSpaceF 	= 1.7
res_v@gsnLeftString     		= ""
res_v@gsnRightString    		= ""

res_m@lbLabelBarOn				= False
res_m@lbOrientation 			= "Horizontal"
res_m@pmLabelBarHeightF 		= 0.50
res_m@lbTitleString 			= "(~F34~0~F~C)"
;res_m@lbTitleString 			= "(m s~S2~-1  )"
;res_m@lbTitlePosition 			= "Left"
;res_m@lbTitleDirection 		= "Across"
res_m@lbTitleFontHeightF 		= 0.018
res_m@pmLabelBarOrthogonalPosF  = 0.05
res_m@pmLabelBarParallelPosF 	= 0.55
res_m@lbTitleOffsetF 			= -0.01
res_m@lbBoxLineThicknessF		= 1.0

res_m@cnFillOn 					= True                      ;  ; Create a color fill plot
res_m@cnLinesOn 				= False						  ;
res_m@cnLineLabelsOn			= False
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
res_m@mpNationalLineThicknessF    = 1.0		  ;
res_m@mpGeophysicalLineThicknessF = 1.0		  ;
res_m@mpLimbLineThicknessF        = 1.5		  ;
res_v@tmBorderThicknessF		  = 1.0


;;;;; Seoul boundary
  SeoulBND = asciiread("./Seoul_Boundary.prn",(/647,2/),"float")
  x = SeoulBND(:,0) ; longitude
  y = SeoulBND(:,1) ; latitude
  locopt = True
  locopt@returnInt = False
  locr = wrf_user_ll_to_ij(a2,x,y,locopt)
 ;print(dimsizes(locr))
  xx = locr(0,:)
  yy = locr(1,:) ;print(xx)
  resp                         = True
  resp@gsLineColor             = "Black"
  resp@gsLineThicknessF        = 2.5

BON = gc_inout(lat,lon,y,x)

;res_m@tmYLLabelFontHeightF = 0.020
;res_m@tmXBLabelFontHeightF = 0.020

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
  tmres@tmXBLabelFontHeightF = 0.020         ; Default is a bit large
;---We're putting tickmarks on all four axes.
;tmres@tmYLValues = fspan(37.4,37.8,5)
;tmres@tmXBValues = fspan(126.6,127.2,4)
tmres@tmYLValues = fspan(37.0,38.0,6)
tmres@tmXBValues = fspan(126.6,127.4,5)
tmres@tmXBMajorThicknessF         = 3.0
tmres@tmYLMajorThicknessF         = 3.0
tmres@tmBorderThicknessF          = 3.0

if nncol .eq. 0 then
tmres@tmYLOn = True
else
tmres@tmYLOn = False
end if

if ntime .eq. plen/3-1 then
tmres@tmXBOn = True
else
tmres@tmXBOn = False
end if

res_v@tmYROn	= False
res_v@tmXTOn	= False


if DIUR then
tdiff = 0.
nn = 0
do j = 0, dimj -1
	do i = 0, dimi -1
		if (lui(j,i) .eq. 13 .or. lui(j,k) .gt. 30) .and. BON(j,i) then
			tdiff = tdiff + t2box(2,12,j,i)
			nn = nn + 1
		end if
	end do
end do

tdiff = tdiff/tofloat(nn)
print(tdiff)


ii = 12
;res_m@tiMainString = ii+1+" LST"
print(max(t2box(jj,ii,:,:)))
print(min(t2box(jj,ii,:,:)))
res_m@gsnLeftString	= TITLE(jj)
res_m@gsnLeftStringFontHeightF	= 0.03
plot(jj) = gsn_csm_contour_map(wks,t2box(jj,ii,y_start:y_end,x_start:x_end),res_m)
res_v@tmXBOn = False
res_v@tmYLOn = False
vector(jj) = gsn_csm_vector(wks,u10box(jj,ii,y_start:y_end,x_start:x_end),v10box(jj,ii,y_start:y_end,x_start:x_end),res_v)
	do i = 0, 645
		boundary(i,jj) = gsn_add_polyline(wks,plot(jj),x(i:i+1),y(i:i+1),resp)
	end do
	overlay(plot(jj),vector(jj))
	plot(jj) = add_map_tickmarks2(wks,plot(jj),tmres)


else

;tdiff = 0.
;nn = 0
;do j = 0, dimj -1
;    do i = 0, dimi -1
;        if (lui(j,i) .eq. 13 .or. lui(j,i) .gt. 30) .and. BON(j,i) then
;            tdiff = tdiff + t2box(2,12,j,i)
;            nn = nn + 1
;        end if
;    end do
;end do

print(max(t2box(nncol,tt,:,:)))
print(min(t2box(nncol,tt,:,:)))
res_m@gsnLeftString = TITLE(nncol,ntime)
res_m@gsnLeftStringFontHeightF = 0.03
plot(jj) = gsn_csm_contour_map(wks,t2box(nncol,tt,y_start:y_end,x_start:x_end),res_m)
  res_v@tmXBOn = False
  res_v@tmYLOn = False
  vector = gsn_csm_vector(wks,u10box(nncol,tt,y_start:y_end,x_start:x_end),v10box(nncol,tt,y_start:y_end,x_start:x_end),res_v)
  do i = 0, 645
     boundary(i,jj) = gsn_add_polyline(wks,plot(jj),x(i:i+1),y(i:i+1),resp)
  end do
  overlay(plot(jj),vector(jj))
  plot(jj) = add_map_tickmarks2(wks,plot(jj),tmres)

end if

delete([/cmap,res_m@cnFillPalette,res_m@cnLevels/])
end do

pnlres = True
pnlres@lbTitleString             = "(~F34~0~F~C)"
pnlres@lbTitlePosition          = "Bottom"
pnlres@lbTitleDirection         = "Across"
pnlres@lbTitleFontHeightF        = 0.012
;res_m@pmLabelBarOrthogonalPosF  = 0.05
;res_m@pmLabelBarParallelPosF    = 0.55
;res_m@lbTitleOffsetF            = -0.01

pnlres@gsnMaximize = True
;pnlres@vpYF = 0.9
pnlres@vpHeightF = 1.0
if DIUR then
pnlres@pmLabelBarHeightF			= 0.06
pnlres@pmLabelBarWidthF				= 0.50
pnlres@pmLabelBarOrthogonalPosF     = -0.02
pnlres@pmLabelBarParallelPosF       = 0.03
pnlres@gsnPanelRight                = 0.67
pnlres@gsnPanelLeft                 = 0.01

else
pnlres@pmLabelBarHeightF            = 0.05
pnlres@pmLabelBarWidthF             = 0.40
pnlres@pmLabelBarOrthogonalPosF     = -0.02
pnlres@pmLabelBarParallelPosF       = 0.03
pnlres@gsnPanelBottom				= 0.02
pnlres@gsnPanelRight                = 0.70
pnlres@gsnPanelLeft                 = 0.04

end if

pnlres@lbBoxLineThicknessF			= 1.0
pnlres@lbLabelFontHeightF			= 0.01
pnlres@gsnFrame						= False
pnlres@gsnDraw						= True

pnlres@gsnPanelLabelBar 			= True
pnlres@lbLabelStride				= 2
pnlres@gsnPanelXWhiteSpacePercent	= 0.
pnlres@gsnPanelYWhiteSpacePercent	= 1.

if DIUR then
gsn_panel(wks,plot(:1),(/1,2/),pnlres)

else

plots = new(plen/3*2,graphic)
plots(::2) = plot(::3)
plots(1::2) = plot(1::3)
gsn_panel(wks,plots,(/4,2/),pnlres)

end if

pnlres@gsnPanelRight				= 0.975
pnlres@gsnPanelLeft					= 0.70

if DIUR then
pnlres@pmLabelBarWidthF             = 0.25
pnlres@pmLabelBarOrthogonalPosF     = -0.02
pnlres@pmLabelBarParallelPosF       = 0.00
pnlres@gsnPanelRight                = 0.975
pnlres@gsnPanelLeft                 = 0.70


else
pnlres@pmLabelBarWidthF             = 0.20
pnlres@pmLabelBarOrthogonalPosF     = -0.02
pnlres@pmLabelBarParallelPosF       = 0.00
pnlres@gsnPanelRight                = 0.92
pnlres@gsnPanelLeft                 = 0.65


end if

pnlres@lbLabelStride				= 1

if DIUR then
gsn_panel(wks,plot(2),(/1,1/),pnlres)
else
gsn_panel(wks,plot(2::3),(/4,1/),pnlres)
end if

frame(wks)

if type .eq. "oldps" then
	system("cd ../picture")
    system("ps2epsi "+name2+".ps")
    system("mv "+name2+".epsi "+name2+".eps")
    system("convert -density 700 "+name2+".eps "+name2+".png")
end if



end
