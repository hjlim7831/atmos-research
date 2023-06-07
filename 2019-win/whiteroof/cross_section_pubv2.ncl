load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;========================================================================================
;======================== Variables which I have to change first ========================
;========================================================================================

;-------input Data path
 dir = "./"
 diro = "~/archive/ERA5_data/ncfile/"
 fileA  = "e2wrfout_d03_2018-07-14_12:00:00" ; change here!
 fileB  = "e7wrfout_d03_2018-07-14_12:00:00" ; 
 fileC  = "CrossSectionData.nc"
 fileD  = "1h_ERA5-20180714-0820-1000hpa.nc"

 tst = 15 ; for FileD
 ted = 912-1-9 ;for FileD

 plat = 37.5
 plon = 126.5

RI =    (/False,False,False,False,False, \
          False,False,False,False,False, \
          False,False,False,True ,False, \
          False,False,False,False,True , \
          False,True ,True ,True ,False, \
          True ,False,True ,True ,True , \
          True ,True ,True ,True ,False, \
          False,True/)


 DIUR = False

picname = "URB_NOURB_cross_EW_Seoul_pub"

  zs     = 0 ;to select height
  ze     = 35 ;to select height
type0 = "png"
;type0 = "x11"

; type = "x11"
 type = "png"
; type = "ps"

;-------time variables
; its = 3   ; to start 00 LST 
; ite = 891
  its = 3+264
  ite = 3+287
; ite = 26
; tidx = (/13, 14, 15, 16/)
 tidx = ispan(0,23,1)
 diur = 24

 dt = dimsizes(tidx)

  whattime = tidx ;U50

 plots = new(dt*2,graphic)
 dum = new(dt*2,graphic)

opts  = True ;you have to put this "True", if you want to display limited vertical cross section

	;;;;; seoul: 

;== Horizontal distance
;deli = -40   ; for Sea Breeze
;delj = 0

deli = 16 ; for BukHan Mountain
delj = 0

;==Original
;lonst = 126.9625
;;;latst = 37.535
;latst = 37.56

;==BukHan Mountain
lonst = 126.9803
latst = 37.6604

;==Gwanak Mountain
;lonst = 126.9631
;latst = 37.4423

;==for Sea breeze
;lonst = 127.0
;latst = 37.45

 a1 = addfile(dir+fileA,"r") ;Urban
 a2 = addfile(dir+fileB,"r") ;No-Urban
 a3 = addfile(dir+fileC,"r")
 a4 = addfile(diro+fileD,"r")
 
 glon = a4->longitude
 glat = a4->latitude
 gtime = a4->time(tst:ted)

 pj = ind(glat.eq.plat)
 pi = ind(glon.eq.plon)

U = a4->u(tst:ted,pj,pi)
sf = U@scale_factor
ofs = U@add_offset
geou = U*sf+ofs

V = a4->v(tst:ted,pj,pi)
sf = V@scale_factor
ofs = V@add_offset
geov = V*sf+ofs

wspd = (geou^2.+geov^2.)^0.5

dtime = dimsizes(wspd)

wspdd = new(dtime/24,double)

do i = 0, dtime/24 -1
	wspdd(i) = max(wspd(i*24:i*24+23))
end do


if deli .eq. 0 then
    angle = 90 ; NS
else if delj .eq. 0 then
    angle = 0 ; EW
else
    angle = -1
end if
end if

 mdims  = getfilevardimsizes(a1,"P")
  nd     = dimsizes(mdims)

 wks0 = gsn_open_wks(type0,"Find_location")

 lon   = wrf_user_getvar(a1, "XLONG",0)
 lat   = wrf_user_getvar(a1, "XLAT",0)

dim1 = dimsizes(lon(:,0))
dim2 = dimsizes(lon(0,:))

lloc = wrf_user_ll_to_ij(a1,lonst,latst,True)-1
ci = (/lloc(0),lloc(0)+deli/)
cj = (/lloc(1),lloc(1)+delj/)

ii1 = min(ci)
ii2 = max(ci)
jj1 = min(cj)
jj2 = max(cj)


;delx = 20


;==============================================================================================
;===================================== Color and Levels =======================================
;==============================================================================================
;cmap = read_colormap_file("MPL_seismic") 
cmap = read_colormap_file("WhiteBlueGreenYellowRed")
;cmap = read_colormap_file("BlueYellowRed")

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

;====== for resources of all variables

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

;if (angle .eq. 0) then
;    opts_xy@trXMinF                 = ii1
;    opts_xy@trXMaxF                 = ii2
;else if (angle .eq. 90) then
;    opts_xy@trXMinF                 = jj1
;    opts_xy@trXMaxF                 = jj2

;end if
;end if

;-------- for vertical wind
    opts_w                          = opts_xy
    opts_w@pmLabelBarOrthogonalPosF  = -0.07
    opts_w@cnLineColor              = "grey60"
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
    opts_w@gsnContourNegLineDashPattern = 0

;-------- for v wind
    opts_v                          = opts_xy
    opts_v@pmLabelBarOrthogonalPosF = -0.07
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

;------- for u wind
    opts_u                          = opts_xy
    opts_u@cnLinesOn                = True
    opts_u@cnLineLabelsOn           = True
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

;-------- for potential temperature
    opts_t                          = opts_xy
;    opts_t@pmLabelBarOrthogonalPosF  = 0.00
    opts_t@cnLinesOn                = False
    opts_t@cnFillOn                 = True
	opts_t@cnFillPalette			= cmap


;-------- for wind vector
opts_vec = True                                ; Set some Basic Plot options
opts_vec = opts_xy
opts_vec@MainTitle = ""
opts_vec@NumVectors = 40
opts_vec@vcGlyphStyle = "LineArrow"
opts_vec@vcRefMagnitudeF = 4
opts_vec@vcRefLengthF = 0.04
opts_vec@vcRefAnnoOn = True
opts_vec@vcRefAnnoOrthogonalPosF = -1.25
opts_vec@vcRefAnnoString1 = opts_vec@vcRefMagnitudeF+" m s~S2~-1"
opts_vec@vcRefAnnoString2On = False
opts_vec@vcRefAnnoPerimOn = False
opts_vec@vcRefAnnoFontHeightF = 0.018
opts_vec@vcMinDistanceF		  = 0.02
opts_vec@vcLineArrowThicknessF= 4.0


;============================================================================================
;========================== to see the location where I choose ==============================
;============================================================================================

 print("lat.: "+lat(jj1,ii1)+" ~ "+lat(jj2,ii2))
 print("long.: "+lon(jj1,ii1)+" ~ "+lon(jj2,ii2))


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
 mpres@mpDataBaseVersion      		= "HighRes"
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
;		pltres@vpWidthF				= 0.8
;		pltres@vpHeightF			= 0.4

        resP = True
        resP@gsnDraw = False
        resP@gsnFrame = False
        resP@gsnPanelCenter      	= False
        resP@gsnPanelLabelBar    	= False
        resP@lbTitleDirection    	= "Across"
        resP@lbTitleFontHeightF  	= 0.02
        resP@lbTitlePosition     	= "Left"
;		resP@vpWidthF				= 0.8
;		resP@vpHeightF				= 0.4

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

 plotH = gsn_csm_contour(wks0,a1->HGT(0,:,:),hres)
 plotP = new((/646/),graphic)
 plotP2 = new(2,graphic)
do i = 0, 645
	plotP(i) = gsn_add_polyline(wks0,plotH,xx(i:i+1),yy(i:i+1),resp)
end do
 plotP2(0) = gsn_add_polymarker(wks0,plotH,ii1,jj1,gres)
 plotP2(1) = gsn_add_polymarker(wks0,plotH,ii2,jj2,gres)
 panel = wrf_map_overlays(a1,wks0,(/plotH/),pltres,mpres)
 draw(panel)
 frame(wks0)
 
;;======================================================================================
;;======================== to draw Vertical Cross Section ==============================
;;======================================================================================

    plane = (/ ii1,jj1, ii2,jj2 /)

if ( angle .eq. 0 ) then
xxlon = fspan(0,ii2-ii1,4)
;print(xxlon)
xlabel = new((/4/),float, -9999)
do i = 0, 3
   xlabel(i) = lon(jj1,floattointeger(xxlon(i))+ii1)
end do
end if



if ( angle .eq. 90 ) then
xxlon = fspan(0,jj2-jj1,4)
;print(xxlon)
xlabel = new((/4/),float, -9999)
do i = 0, 3
   xlabel(i) = lat(floattointeger(xxlon(i))+jj1,ii1)
end do

end if
print(angle)
print(xlabel)
print(xxlon)

; xlabel = (/"37~S~o~N~26'N", "37~S~o~N~28'N","37~S~o~N~30'N", \
;             "37~S~o~N~32'N", "37~S~o~N~34'N","37~S~o~N~36'N"/)

;==================================================================================
;============================ to modify variables =================================
;==================================================================================

PBLH1= a1->PBLH(its:ite,:,:)
Z1	 = a3->z2(its:ite,zs:ze,:,:)
TH1	 = a3->th2(its:ite,zs:ze,:,:)
U1   = a3->ua2(its:ite,zs:ze,:,:)
V1   = a3->va2(its:ite,zs:ze,:,:)
W1	 = a3->wa2(its:ite,zs:ze,:,:)

dimt = ite-its+1
dimx = dimsizes(PBLH1(0,0,:))
dimy = dimsizes(PBLH1(0,:,0))

print(0.1)

if DIUR then
T1_d = new((/diur,ze-zs+1,dimy,dimx/),float)
U1_d = new((/diur,ze-zs+1,dimy,dimx/),float)
V1_d = new((/diur,ze-zs+1,dimy,dimx/),float)
W1_d = new((/diur,ze-zs+1,dimy,dimx/),float)
Z1_d = new((/diur,ze-zs+1,dimy,dimx/),float)
PBLH1_d = new((/diur,dimy,dimx/),float)

T1_d = 0
U1_d = 0
V1_d = 0
W1_d = 0
Z1_d = 0
PBLH1_d = 0

print(dimt)
n = 0
do i = 0, dtime/24 -1
	if wspdd(i).lt.6 .and. .not. RI(i) then
		print(i)
    T1_d = T1_d + TH1(i*24:i*24+23,:,:,:)
    U1_d = U1_d + U1(i*24:i*24+23,:,:,:)
    V1_d = V1_d + V1(i*24:i*24+23,:,:,:)
    W1_d = W1_d + W1(i*24:i*24+23,:,:,:)
    Z1_d = Z1_d + Z1(i*24:i*24+23,:,:,:)
    PBLH1_d = PBLH1_d + PBLH1(i*24:i*24+23,:,:)
	n = n + 1
	end if
end do

T1_d = T1_d/tofloat(n)
U1_d = U1_d/tofloat(n)
V1_d = V1_d/tofloat(n)
W1_d = W1_d/tofloat(n)
Z1_d = Z1_d/tofloat(n)
PBLH1_d = PBLH1_d/tofloat(n)

delete([/TH1,U1,V1,W1,Z1,PBLH1/])

end if
;delete([/TH1,U1,V1,Z1,PBLH1/])

print(1)


PBLH2= a2->PBLH(its:ite,:,:)
Z2   = a3->z7(its:ite,zs:ze,:,:)
TH2  = a3->th7(its:ite,zs:ze,:,:)
U2   = a3->ua7(its:ite,zs:ze,:,:)
V2   = a3->va7(its:ite,zs:ze,:,:)
W2   = a3->wa7(its:ite,zs:ze,:,:)

print(0.2)


Dlen = dimt/diur
print(Dlen)

if DIUR then
T2_d = new((/diur,ze-zs+1,dimy,dimx/),float)
U2_d = new((/diur,ze-zs+1,dimy,dimx/),float)
V2_d = new((/diur,ze-zs+1,dimy,dimx/),float)
W2_d = new((/diur,ze-zs+1,dimy,dimx/),float)
Z2_d = new((/diur,ze-zs+1,dimy,dimx/),float)
PBLH2_d = new((/diur,dimy,dimx/),float)
 
T2_d = 0
U2_d = 0
V2_d = 0
W2_d = 0
Z2_d = 0
PBLH2_d = 0

n = 0
do i = 0, dtime/24 -1
    if wspdd(i).lt.6 .and. .not. RI(i) then
        print(i)
    T2_d = T2_d + TH2(i*24:i*24+23,:,:,:)
    U2_d = U2_d + U2(i*24:i*24+23,:,:,:)
    V2_d = V2_d + V2(i*24:i*24+23,:,:,:)
    W2_d = W2_d + W2(i*24:i*24+23,:,:,:)
    Z2_d = Z2_d + Z2(i*24:i*24+23,:,:,:)
    PBLH2_d = PBLH2_d + PBLH2(i*24:i*24+23,:,:)
	n = n + 1
	end if
end do

T2_d = T2_d/tofloat(n)
U2_d = U2_d/tofloat(n)
V2_d = V2_d/tofloat(n)
W2_d = W2_d/tofloat(n)
Z2_d = Z2_d/tofloat(n)
PBLH2_d = PBLH2_d/tofloat(n)


delete([/TH2,U2,V2,W2,Z2,PBLH2/])
end if
;delete([/TH2,U2,V2,Z2,PBLH2/])

print(2)

    wks = gsn_open_wks(type,picname)

  nt = -1
  do it = 0, dt -1
    nt = nt + 1
    itime = whattime(it)
;	print(itime)
;    print("Working on time: " + times(itime) )
    res@TimeLabel = times(itime)

if DIUR then
	t1 = T1_d(itime,:,:,:)
	u1 = U1_d(itime,:,:,:)
	v1 = V1_d(itime,:,:,:)
	w1 = W1_d(itime,:,:,:)
	z1 = Z1_d(itime,:,:,:)
	pbl1 = PBLH1_d(itime,:,:)

    t2 = T2_d(itime,:,:,:)
    u2 = U2_d(itime,:,:,:)
    v2 = V2_d(itime,:,:,:)
    w2 = W2_d(itime,:,:,:)
    z2 = Z2_d(itime,:,:,:)
    pbl2 = PBLH2_d(itime,:,:)
else
	t1 = TH1(itime,:,:,:)
	u1 = U1(itime,:,:,:)
	v1 = V1(itime,:,:,:)
	w1 = W1(itime,:,:,:)
	z1 = Z1(itime,:,:,:)
	pbl1 = PBLH1(itime,:,:)

    t2 = TH2(itime,:,:,:)
    u2 = U2(itime,:,:,:)
    v2 = V2(itime,:,:,:)
    w2 = W2(itime,:,:,:)
    z2 = Z2(itime,:,:,:)
    pbl2 = PBLH2(itime,:,:)

end if


if ( angle .eq.  0 ) then
   dimx = dimy
end if

    t_plane = wrf_user_vert_cross(t1(:,:,:),z1,plane,opts)
    u_plane = wrf_user_vert_cross(u1(:,:,:),z1,plane,opts)
	v_plane = wrf_user_vert_cross(v1(:,:,:),z1,plane,opts)
	w_plane = wrf_user_vert_cross(w1(:,:,:),z1,plane,opts)
;	ws_plane = sqrt(u_plane^2+v_plane^2)


    t_plane2 = wrf_user_vert_cross(t2(:,:,:),z2,plane,opts)
    u_plane2 = wrf_user_vert_cross(u2(:,:,:),z2,plane,opts)
    v_plane2 = wrf_user_vert_cross(v2(:,:,:),z2,plane,opts)
    w_plane2 = wrf_user_vert_cross(w2(:,:,:),z2,plane,opts)
;    ws_plane2 = sqrt(u_plane2^2+v_plane2^2)

	printVarSummary(t_plane)
	printVarSummary(u_plane)
   zin   = fspan(z1(0,jj1,ii1)/1000.,z1(ze-zs,jj1,ii1)/1000.,100)
    delz = (max(z1)-min(z1))/100.*0.001

;	print(zin)
;;;;; zin is z coordinate

    levo  = fspan(0.2,1.8,9)
    vertz = levo/delz

    zinm  = zin*1000.

;;;;; find out topography heights.
topo_height = new((/dimx-1/),float,-9999)   ;;; **_plane is 1 ~ dimx-1

min_z = min(z1)
do j = 0, deli -1
do i = 0, delj -1
   if ( .not. ismissing(t_plane(i,j)) ) then
      topo_height(j) = delz*i*1000.+min_z
      break
   end if
end do
end do

    avgT = dim_avg_n(t_plane,1)
    avgT2= dim_avg_n(t_plane2,1)

tz = dimsizes(t_plane(:,0))
ti = dimsizes(t_plane(0,:))
anoT = new((/tz,ti/),float)
anoT2 = new((/tz,ti/),float)
do i = 0, tz-1
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
;      w_diff = w_plane(:,:)-w_plane2(:,:)
;      contour_Wdif = wrf_contour(a1,wks,w_diff,opts_w)

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

;      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
    opts_t@cnLevels  = ispan(295,311,1)
;if ( it .eq. 1 ) then
;      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
;end if
;if ( it .eq. 2 ) then
;      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
;end if
;if ( it .eq. 3 ) then
;      opts_t@cnLevels		 = fspan(-1.5,1.5,31)
;end if
;	delete(opts_t@cnLevels)
;      contour_t = wrf_contour(a1,wks,anoT(:,:),opts_t)

;      contour_t2 = wrf_contour(a1,wks,anoT2(:,:),opts_t)
	contour_t = wrf_contour(a1,wks,t_plane,opts_t)
	contour_t2 = wrf_contour(a1,wks,t_plane2,opts_t)
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
;      ws_diff = ws_plane(:,:)-ws_plane2(:,:)
;      contour_WSdif = wrf_contour(a1,wks,u_diff,opts_u)


vector = wrf_vector(a1,wks,u_plane,w_plane,opts_vec)
vector2 = wrf_vector(a1,wks,u_plane2,w_plane2,opts_vec)


;opts_vec@tmYLValues               = vertz
;opts_vec@tmYLLabels               = levo
;opts_vec@tmXBValues               = "" + xxlon
;opts_vec@tmXBLabels               = xlabel
;opts_vec@vcRefMagnitudeF = 2
;opts_vec@vcRefAnnoString1 = opts_vec@vcRefMagnitudeF+" m s~S2~-1"
;vector_diff = wrf_vector(a1,wks,u_plane-u_plane2,w_plane-w_plane2,opts_vec)

resp                         = True 
resp@gsLineColor             = "Black"
resp@gsLineThicknessF        = 6

delete(xx)

xx = ispan(0,dimx-1,1)

;;; zin -> z coord.
;pblh(iy,0:dimx-2) = pblh(iy,0:dimx-2)+topo_height
;pblh = (pblh-min(z))*0.001/delz
;pblh2(iy,0:dimx-2) = pblh2(iy,0:dimx-2)+topo_height
;pblh2 = (pblh2-min(z))*0.001/delz


;printVarSummary(contour_w)

	; MAKE PLOTS         
    pltres@CommonTitle = True
    pltres@PlotTitle =  times(itime+9+3)+" LST"
;    plots(nt*3) = wrf_overlays(a1,wks,(/contour_w,contour_v,contour_t,contour_u/),pltres)
;    plots(nt*3+1) = wrf_overlays(a1,wks,(/contour_w2,contour_v2,contour_t2,contour_u2/),pltres)
;    plots(nt*3+2) = wrf_overlays(a1,wks,(/contour_Wdif,contour_Vdif,contour_Tdif,contour_WSdif/),pltres)

;    plots(nt*2) = wrf_overlays(a1,wks,(/contour_t,contour_v,contour_u/),pltres)
;    dum(nt*2) = gsn_add_polyline(wks,plots(nt*2),xx(:),pblh(iy,:),resp)
;    plots(nt*2+1) = wrf_overlays(a1,wks,(/contour_t2,contour_v2,contour_u2/),pltres)
;    dum(nt*2+1) = gsn_add_polyline(wks,plots(nt*2+1),xx(:),pblh2(iy,:),resp)
    plots(nt*2) = wrf_overlays(a1,wks,(/contour_t,contour_w,vector/),pltres)
	plots(nt*2+1) = wrf_overlays(a1,wks,(/contour_t2,contour_w2,vector2/),pltres)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

 end do ; time loop
nn = 2

 pnlres                            = True
 do ii = 0, dt/nn -1
 gsn_panel(wks,(/plots(ii*nn*2:ii*nn*2+nn*2-1)/),(/nn,2/),pnlres)
 end do

end
