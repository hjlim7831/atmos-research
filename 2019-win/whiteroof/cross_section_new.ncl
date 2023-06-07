load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

 dir = "./"
 fileA  = "e2wrfout_d03_2018-07-14_12:00:00"
 fileB  = "e7wrfout_d03_2018-07-14_12:00:00"

 type = "x11"
; type = "png"
e type = "ps"
;cl

 its = 3   ; 00 LST 
 tidx = (/13, 14, 15, 16/)
 dt = dimsizes(tidx)

 whattime = its+tidx ;U50

angle = 0.  ;90-EW, 0-NS
opts  = True ;you have to put this "True", if you want to display limited vertical cross section

	;;;;; seoul: 

;== Horizontal distance
deli = 0
delj = 25

;==Original
;lonst = 126.9625
;;;latst = 37.535
;latst = 37.56

;==BukHan Mountain
;lonst = 126.9803
;latst = 37.6604

;==Gwanak Mountain
lonst = 126.9631
latst = 37.4423

;lonst = 127.1
;latst = 37.65

 a1 = addfile(dir+fileA,"r") ;Urban
 a2 = addfile(dir+fileB,"r") ;No-Urban

 mdims  = getfilevardimsizes(a1,"P")
  nd     = dimsizes(mdims)
  zs     = 0 ;to select height
  ze     = 10 ;to select height

 wks = gsn_open_wks(type,"Find_location")

 lon   = wrf_user_getvar(a1, "XLONG",0)
 lat   = wrf_user_getvar(a1, "XLAT",0)

dim1 = dimsizes(lon(:,0))
dim2 = dimsizes(lon(0,:))

lloc = wrf_user_ll_to_ij(a1,lonst,latst,True)-1
ii = lloc(0)
jj = lloc(1)
print(lloc)



;delx = 20

;============ to see the location where I choose 

 print("lat.: "+lat(jj,ii)+" ~ "+lat(jj+delj,ii+deli))
 print("long.: "+lon(jj,ii)+" ~ "+lon(jj+delj,ii+deli))


;cross section: parallel to longitude

 gres = True
 gres@gsnFrame          = False
 gres@gsMarkerIndex    = 16
 gres@gsMarkerThicknessF = 3.

 hres	= True
 hres@gsnFrame		= False
 hres@gsnDraw		= False
 hres@cnLineLabelsOn	= False
 hres@cnFillOn			= True
 hres@cnFillPalette		= "MPL_YlOrBr"

 mpres								= True
 mpres@gsnFrame						= False
 mpres@gsnDraw						= False
 mpres@mpGeophysicalLineColor 		= "Black"
 mpres@mpDataBaseVersion      		= "MediumRes"
 mpres@mpGridLineColor        		= "Black"
 mpres@mpLimbLineColor        		= "Black"
 mpres@mpPerimLineColor      		= "Black"
 mpres@mpGeophysicalLineThicknessF  = 2.
 mpres@mpGridAndLimbOn     			= True
 mpres@mpGridLineColor     			= "grey"
 mpres@pmTickMarkDisplayMode 		= "Always"
 mpres@mpOutlineBoundarySets        = "National"
 mpres@mpNationalLineThicknessF     = 1.0
 mpres@mpProjection 				= "LambertConformal"
 mpres@mpLambertParallel1F 			= a1@TRUELAT1
 mpres@mpLambertParallel2F          = a1@TRUELAT2
 mpres@mpLambertMeridianF   		= a1@CEN_LON
 mpres@mpLimitMode          		= "Corners"
; mpres@mpLeftCornerLatF 			= 37.32
; mpres@mpLeftCornerLonF			= 126.54
; mpres@mpRightCornerLatF			= 37.82
; mpres@mpRightCornerLonF			= 127.25
 mpres@mpLeftCornerLatF				= lat(0,0)
 mpres@mpLeftCornerLonF             = lon(0,0)
 mpres@mpRightCornerLatF            = lat(dim1-1,dim2-1)
 mpres@mpRightCornerLonF            = lon(dim1-1,dim2-1)


 mpres@tfDoNDCOverlay      			= True
        pltres                      = True
        pltres@PanelPlot            = True
        pltres@FramePlot            = False
        pltres@NoTitles             = True

        resP = True
        resP@gsnDraw = False
        resP@gsnFrame = False
        resP@gsnPanelCenter      	= False
        resP@gsnPanelLabelBar    	= False
        resP@lbTitleDirection    	= "Across"
        resP@lbTitleFontHeightF  	= 0.02
        resP@lbTitlePosition     	= "Left"


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

 plotH = gsn_csm_contour(wks,a1->HGT(0,:,:),hres)
 plotP = new((/646/),graphic)
 plotP2 = new(2,graphic)
do i = 0, 645
	plotP(i) = gsn_add_polyline(wks,plotH,xx(i:i+1),yy(i:i+1),resp)
end do
 plotP2(0) = gsn_add_polymarker(wks,plotH,ii,jj,gres)
 plotP2(1) = gsn_add_polymarker(wks,plotH,ii+deli,jj+delj,gres)
 panel = wrf_map_overlays(a1,wks,(/plotH/),pltres,mpres)
 draw(panel)
 frame(wks)
 
;;======================================================================================
;;======================== to draw Vertical Cross Section ==============================
;;======================================================================================

 wks = gsn_open_wks(type,"URB_NOURB_cross_EW_Seoul"+whattime(0))

; iy1    = iy-delx
; iy2    = iy+delx ;mdims(nd-2)-2
; ix1    = ix-delx ;ix-50		;EW
; ix2    = ix+delx 

; iy1 = iy-(ldelx+rdelx)/2
; iy2 = iy+(ldelx+rdelx)/2
; ix1 = ix-ldelx
; ix2 = ix+rdelx

 jj1 = jj
 jj2 = jj+delj
 ii1 = ii
 ii2 = ii+deli


    plane = (/ ii1,jj1, ii2,jj2 /)
 
if ( angle .eq. 90 ) then
xxlon = fspan(0,ii2-ii1,4)
;print(xxlon)
xlabel = new((/4/),float, -9999)
do i = 0, 3
   xlabel(i) = lon(jj1,floattointeger(xxlon(i))+ii1)
end do

end if

if ( angle .eq. 0 ) then
xxlon = fspan(0,jj2-jj1,4)
;print(xxlon)
xlabel = new((/4/),float, -9999)
do i = 0, 3
   xlabel(i) = lat(floattointeger(xxlon(i))+jj1,ii1)
end do
print(xlabel)
end if

; xlabel = (/"37~S~o~N~26'N", "37~S~o~N~28'N","37~S~o~N~30'N", \
;             "37~S~o~N~32'N", "37~S~o~N~34'N","37~S~o~N~36'N"/)

;xmin = iy-40
;xmax = iy+40
;xmin = iy-30
;xmax = iy+30
;cl
 plots = new(12,graphic)
 dum = new(12,graphic)

;============= Color and Levels ==============
  gsn_define_colormap(wks,"MPL_seismic")

 res                          = True
 res@NoHeaderFooter           = True

 pltres                       = True
 pltres@PanelPlot             = True
 pltres@FramePlot             = False

 res@gsnDraw                      = False
; res@gsnFrame                     = False
 res@tfDoNDCOverlay               = True
 res@cnMissingValFillColor        = "gray" 
 res@cnMissingValFillPattern      = 0

 times  = wrf_user_list_times(a1)

    opts_xy                         = res
    opts_xy@tiYAxisString           = "height (km)"
    opts_xy@tmXBMode                = "Explicit"
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmBorderThicknessF      = 1. 
    opts_xy@tmXBMajorThicknessF     = 1. 
    opts_xy@tmYLMajorThicknessF     = 1. 
    opts_xy@tiXAxisFontHeightF      = 0.03
    opts_xy@tiYAxisFontHeightF      = 0.03
    opts_xy@tmXBMajorLengthF        = 0.01
    opts_xy@tmYLMajorLengthF        = 0.01
    opts_xy@tmYLLabelFontHeightF    = 0.024
    opts_xy@tmXBLabelFontHeightF    = 0.024
;    opts_xy@trYMaxF                 = 68 
    opts_xy@trYMaxF                 = 56
    opts_xy@tiMainOn                = False

if (angle .eq. 0) then
	opts_xy@trXMinF					= min((/ii1,ii2/))
	opts_xy@trXMaxF					= max((/ii1,ii2/))
else if (angle .eq. 90) then
	opts_xy@trXMinF					= min((/jj1,jj2/))
	opts_xy@trXMaxF					= max((/jj1,jj2/))
end if
end if

    opts_w                          = opts_xy
    opts_w@pmLabelBarOrthogonalPosF  = -0.07
    opts_w@cnLineColor              = "grey40" 
    opts_w@cnLinesOn                = True
	opts_w@cnLineLabelsOn           = True
    opts_w@cnFillOn                 = False
    opts_w@cnLevelSelectionMode     = "ExplicitLevels"
    opts_w@cnLevels                 = (/-1.5,-1.0,-0.5,0.5,1.0,1.5/)
    opts_w@cnLineThicknessF         = 4.0
    opts_w@cnLineLabelPerimOn       = False
    opts_w@cnLineLabelBackgroundColor = "White"
    opts_w@cnLineLabelPerimSpaceF   = 0.3
    opts_w@cnLineLabelDensityF      = 1.2
    opts_w@gsnContourNegLineDashPattern = 14

    opts_v                          = opts_xy
    opts_v@pmLabelBarOrthogonalPosF  = -0.07
    opts_v@cnLinesOn                = True
    opts_v@cnLevelFlags             = "LineOnly"
    opts_v@cnFillOn                 = False
    opts_v@cnLevelSelectionMode     = "ExplicitLevels"
;    opts_v@cnLevels                 = (/-2.,-1.5,-1,-0.5,-0.25,0.25,0.5,1.,1.5,2./) 
	opts_v@cnLevels                 = (/-4.0,-2.0,-1.0,-0.5,0.5,1.0,2.0,4.0/)
	opts_v@cnLineThicknessF         = 1.
    opts_v@cnInfoLabelOn            = False
    opts_v@cnLineLabelPerimOn       = False
    opts_v@cnLineLabelBackgroundColor = "darkolivegreen3"
    opts_v@cnLineLabelPerimSpaceF   = 0.3
    opts_v@cnLineLabelDensityF      = 1.2
    opts_v@cnLineColor              = "darkgreen"

    opts_t                          = opts_xy
;    opts_t@pmLabelBarOrthogonalPosF  = 0.00
    opts_t@cnLinesOn                = False
    opts_t@cnFillOn                 = True

    opts_u                          = opts_xy
    opts_u@cnLinesOn                = True
	opts_u@cnLineLabelsOn			= True
    opts_u@cnLevelFlags             = "LineAndLabel"
    opts_u@cnFillOn                 = False
    opts_u@cnLevelSelectionMode     = "ExplicitLevels"
;    opts_u@cnLevels                 = (/-2.0,-1.5,-1.0,-0.5,-0.25,0.25,0.5,1.0,1.5,2.0/)
    opts_u@cnLevels                 = (/-4.0,-2.0,-1.0,-0.5,0.5,1.0,2.0,4.0/)
    opts_u@cnLineThicknessF         = 1.5
    opts_u@cnInfoLabelOn            = False ; don't touch this
    opts_u@cnLineLabelPerimOn       = False
    opts_u@cnLineLabelBackgroundColor = "White"
    opts_u@cnLineLabelPerimSpaceF   = 0.3
    opts_u@cnLineLabelDensityF      = 1.0
    opts_u@cnMonoLineColor          = True
    opts_u@cnLineColor              = "Black"
;---------------------------------------------------------------





  nt = -1
  do it = 0, dt -1
    nt = nt + 1
    itime = whattime(it)
;	print(itime)
;    print("Working on time: " + times(itime) )
    res@TimeLabel = times(itime)

    t_L = wrf_user_getvar(a1, "th",itime)*1.-273.15
    u_L = wrf_user_getvar(a1, "ua",itime)*1.
    v_L = wrf_user_getvar(a1, "va",itime)*1.
    w_L = wrf_user_getvar(a1, "wa",itime)*1.
    z_L = wrf_user_getvar(a1, "z",itime)*1.

    ;lu  = wrf_user_getvar(a1, "LU_INDEX",itime)
    lu	= a1->LU_INDEX(itime,:,:)

    t   = t_L(zs:ze,:,:)
    u   = u_L(zs:ze,:,:)
    v   = v_L(zs:ze,:,:)
    w   = w_L(zs:ze,:,:)
    z   = z_L(zs:ze,:,:)

dimx = dimsizes(t(0,0,:))
dimy = dimsizes(t(0,:,0))

if ( angle .eq.  0 ) then
   dimx = dimy
end if

    t_L2= wrf_user_getvar(a2, "th",itime)*1.-273.15
    u_L2= wrf_user_getvar(a2, "ua",itime)*1.
    v_L2= wrf_user_getvar(a2, "va",itime)*1.
    w_L2= wrf_user_getvar(a2, "wa",itime)*1.
    z_L2= wrf_user_getvar(a2, "z",itime)*1.

    t2  = t_L2(zs:ze,:,:)
    u2  = u_L2(zs:ze,:,:)
    v2  = v_L2(zs:ze,:,:)
    w2  = w_L2(zs:ze,:,:)
    z2  = z_L2(zs:ze,:,:)


    t_plane  = wrf_user_intrp3d(t(:,:,:),z,"v",plane,angle,opts)
    u_plane  = wrf_user_intrp3d(u(:,:,:),z,"v",plane,angle,opts)
    v_plane  = wrf_user_intrp3d(v(:,:,:),z,"v",plane,angle,opts)
    w_plane  = wrf_user_intrp3d(w(:,:,:),z,"v",plane,angle,opts)
    ws_plane = sqrt(u_plane^2+v_plane^2)

    t_plane2 = wrf_user_intrp3d(t2(:,:,:),z,"v",plane,angle,opts)
    u_plane2 = wrf_user_intrp3d(u2(:,:,:),z,"v",plane,angle,opts)
    v_plane2 = wrf_user_intrp3d(v2(:,:,:),z,"v",plane,angle,opts)
    w_plane2 = wrf_user_intrp3d(w2(:,:,:),z,"v",plane,angle,opts)
    ws_plane2= sqrt(u_plane2^2+v_plane2^2)

	printVarSummary(t_plane)
    zin   = fspan(z(0,iy,ix)/1000.,z(ze-zs,iy,ix)/1000.,100)
    delz = (max(z)-min(z))/100.*0.001
;;;;; zin is z coordinate

    levo  = fspan(0.2,1.8,9)
    vertz = levo/delz

    zinm  = zin*1000.

;;;;; find out topography heights.
topo_height = new((/dimx-1/),float,-9999)   ;;; **_plane is 1 ~ dimx-1

min_z = min(z)
do j = 0, idelx -1
do i = 0, jdelx -1
   if ( .not. ismissing(t_plane(i,j)) ) then
      topo_height(j) = delz*i*1000.+min_z
      break
   end if
end do
end do

    avgT = dim_avg_n(t_plane,1)
    avgT2= dim_avg_n(t_plane2,1)

tx = dimsizes(t_plane(:,0))
ty = dimsizes(t_plane(0,:))
anoT = new((/tx,ty/),float)
anoT2 = new((/tx,ty/),float)
do i = 0, tx-1
	anoT(i,:) = t_plane(i,:) - avgT(i)
	anoT2(i,:) = t_plane2(i,:) - avgT2(i)
end do


  ; Options for XY Plots
    opts_xy@tmXBValues              = "" + xxlon
    opts_xy@tmXBLabels              = xlabel
;    opts_xy@PlotOrientation         = t_plane@Orientation

  ; Plotting options for w
    opts_w@cnInfoLabelOn            = False
    opts_w@cnLineLabelsOn           = True
    opts_w@tmYLValues               = vertz
    opts_w@tmYLLabels               = levo
    opts_w@tmXBValues               = "" + xxlon
    opts_w@tmXBLabels               = xlabel

      contour_w = wrf_contour(a1,wks,w_plane(:,:),opts_w)

      contour_w2 = wrf_contour(a1,wks,w_plane2(:,:),opts_w)
      w_diff = w_plane(:,:)-w_plane2(:,:)
      contour_Wdif = wrf_contour(a1,wks,w_diff,opts_w)

  ; Plotting options for v
;    opts_v@tmYLValues               = vertz
;    opts_v@tmYLLabels               = levo
    opts_v@tmXBValues               = "" + xxlon
    opts_v@tmXBLabels               = xlabel

      contour_v = wrf_contour(a1,wks,v_plane(:,:),opts_v)

      contour_v2 = wrf_contour(a1,wks,v_plane2(:,:),opts_v)
      v_diff = v_plane(:,:)-v_plane2(:,:)
      contour_Vdif = wrf_contour(a1,wks,v_diff,opts_v)

    opts_t@cnLevelSelectionMode     = "ExplicitLevels"
    opts_t@lbLabelBarOn             = True ;False
    opts_t@lbLabelFontHeightF       = 0.025
    opts_t@lbTitleFontHeightF       = 0.025
    opts_t@tmYLValues               = vertz
    opts_t@tmYLLabels               = levo
    opts_t@tmXBValues               = "" + xxlon
    opts_t@tmXBLabels               = xlabel
    opts_t@lbTitleOn                = True
    opts_t@lbTitleString             = "(~F34~0~F~C)"
    opts_t@lbOrientation = "Vertical"
;;;;;;;;; lbOrientation = "Horizontal", then comment lines below this line.
    opts_t@pmLabelBarHeightF = 0.7
    opts_t@pmLabelBarWidthF = 0.3
    opts_t@lbTitlePosition = "Top"
    opts_t@lbTitleOffsetF = 0.04
    opts_t@pmLabelBarOrthogonalPosF = -1.3
    opts_t@pmLabelBarParallelPosF = 1.2
    opts_t@FieldTitle = "T"
    opts_t@UnitLabel  = "K"
    opts_t@gsnPaperOrientation = "portrait"

      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
if ( it .eq. 1 ) then
      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
end if
if ( it .eq. 2 ) then
      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
end if
if ( it .eq. 3 ) then
      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
end if
      contour_t = wrf_contour(a1,wks,anoT(:,:),opts_t)

      contour_t2 = wrf_contour(a1,wks,anoT2(:,:),opts_t)
      delete(opts_t@cnLevels)
      opts_t@cnLevels		 = fspan(-1,1,11)*0.25
      t_diff = t_plane(:,:)-t_plane2(:,:)
      contour_Tdif = wrf_contour(a1,wks,t_diff(:,:),opts_t)
      delete(opts_t@cnLevels)

    opts_u@tmYLValues               = vertz
    opts_u@tmYLLabels               = levo
    opts_u@tmXBValues               = "" + xxlon
    opts_u@tmXBLabels               = xlabel

      contour_u = wrf_contour(a1,wks,u_plane(:,:),opts_u)

      contour_u2 = wrf_contour(a1,wks,u_plane2(:,:),opts_u)  
      ws_diff = ws_plane(:,:)-ws_plane2(:,:)
;      contour_WSdif = wrf_contour(a1,wks,u_diff,opts_u)

opts_vec = True                                ; Set some Basic Plot options
opts_vec = opts_xy
opts_vec@MainTitle = ""
opts_vec@NumVectors = 40
opts_vec@vcGlyphStyle = "LineArrow"
opts_vec@vcRefMagnitudeF = 8
opts_vec@vcRefLengthF = 0.04
opts_vec@vcRefAnnoOn = True
opts_vec@vcRefAnnoOrthogonalPosF = -1.25
opts_vec@vcRefAnnoString1 = opts_vec@vcRefMagnitudeF+" m s~S2~-1"
opts_vec@vcRefAnnoString2On = False
opts_vec@vcRefAnnoPerimOn = False
opts_vec@vcRefAnnoFontHeightF = 0.018
opts_vec@tmYLValues               = vertz
opts_vec@tmYLLabels               = levo
opts_vec@tmXBValues               = "" + xxlon
opts_vec@tmXBLabels               = xlabel

vector = wrf_vector(a1,wks,u_plane,w_plane,opts_vec)
vector2 = wrf_vector(a1,wks,u_plane2,w_plane2,opts_vec)

;print(lat(iy,ix))

opts_vec@vcRefMagnitudeF = 2
opts_vec@vcRefAnnoString1 = opts_vec@vcRefMagnitudeF+" m s~S2~-1"
vector_diff = wrf_vector(a1,wks,u_plane-u_plane2,w_plane-w_plane2,opts_vec)

resp                         = True 
resp@gsLineColor             = "Black"
resp@gsLineThicknessF        = 6

delete(xx)

xx = ispan(0,dimx-1,1)

;;; zin -> z coord.
pblh(iy,0:dimx-2) = pblh(iy,0:dimx-2)+topo_height
pblh = (pblh-min(z))*0.001/delz
pblh2(iy,0:dimx-2) = pblh2(iy,0:dimx-2)+topo_height
pblh2 = (pblh2-min(z))*0.001/delz

printVarSummary(contour_w)

	; MAKE PLOTS         
    pltres@CommonTitle = True
    pltres@PlotTitle =  times(itime+9*6)+" LST"
;    plots(nt*3) = wrf_overlays(a1,wks,(/contour_w,contour_v,contour_t,contour_u/),pltres)
;    plots(nt*3+1) = wrf_overlays(a1,wks,(/contour_w2,contour_v2,contour_t2,contour_u2/),pltres)
;    plots(nt*3+2) = wrf_overlays(a1,wks,(/contour_Wdif,contour_Vdif,contour_Tdif,contour_WSdif/),pltres)

    plots(nt*2) = wrf_overlays(a1,wks,(/contour_t,contour_v,contour_u/),pltres)
    dum(nt*2) = gsn_add_polyline(wks,plots(nt*2),xx(:),pblh(iy,:),resp)
    plots(nt*2+1) = wrf_overlays(a1,wks,(/contour_t2,contour_v2,contour_u2/),pltres)
    dum(nt*2+1) = gsn_add_polyline(wks,plots(nt*2+1),xx(:),pblh2(iy,:),resp)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 end do ; time loop

; print("long.: "+lon(iy,ix-delx)+" ~ "+lon(iy,ix+delx))
; print("lat.: "+avg(lat(iy,ix-delx:ix+delx)))

 pnlres                            = True
 gsn_panel(wks,(/plots(0:3)/),(/2,2/),pnlres)
 gsn_panel(wks,(/plots(4:7)/),(/2,2/),pnlres)

; print(lu(xmin:xmax,ix))
; print(pblh(xmin:xmax,ix))
; print(pblh2(xmin:xmax,ix))


end
