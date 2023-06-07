begin
  diri = "./"                          ; input directory
  fili = "e2wrfout_d03_2018-07-14_12:00:00"
  f    = addfile (diri+fili, "r")

  x    = f->LU_INDEX(0,:,:)                      ; note: type byte
  lat = f->XLAT(0,:,:)
  lon = f->XLONG(0,:,:)
  x@lat2d = lat
  x@lon2d = lon
  dimx = dimsizes(x(0,:))
  dimy = dimsizes(x(:,0))

 ;printVarSummary(x)

  info     = (/ " 1  Evergreen Needleleaf", \  ; n=0
                " 2  Evergreen Broadleaf ", \
                " 3  Deciduous Needleleaf", \
                " 4  Deciduous Broadleaf ", \
                " 5  Mixed Forest        ", \
                " 6  Closed Shrublands   ", \
                " 7  Open Shrublands     ", \
                " 8  Woody Savannas      ", \
                " 9  Savannas            ", \
                "10  Grasslands          ", \
                "11  Permanent Wetlands  ", \
                "12  Croplands           ", \
                "13  Urban and Built-up  ", \
                "14  Cropland/natural vegetation mosaic    ", \
                "15  Snow and Ice        ", \
                "16  Barren or Sparsely Vegetated ", \
                "17  Water               ", \
                "18  Wooded Tundra       ", \
				"19  Mixed Tundra", \
				"20  Barren Tundra", \
				"31  Low Intensity Residential", \
				"32  High Intensity Residential", \
				"33  Industrial or Commercial"  /) ; n=17
  ninfo    = dimsizes(info)

;************************************************
; create plot
;************************************************

  wks = gsn_open_wks("x11","vegland")        ; send graphics to PNG file

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
  res@gsnMaximize      = True 
  res@mpProjection     = "LambertConformal"
  res@gsnAddCyclic     = False
  res@mpLambertParallel1F = f@TRUELAT1
  res@mpLambertParallel2F = f@TRUELAT2
  res@mpLambertMeridianF  = f@CEN_LON
  res@mpLimitMode         = "Corners"
  res@mpLeftCornerLatF    = lat(2,2)
  res@mpLeftCornerLonF    = lon(2,2)
  res@mpRightCornerLatF   = lat(dimy-3,dimx-3)
  res@mpRightCornerLonF   = lon(dimy-3,dimx-3)
  res@mpDataBaseVersion   = "HighRes"



  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = "t2m_29lev"
; res@cnFillPalette     = "vegetation_modis"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
  res@cnLevels         = integertobyte( ispan(2,ninfo,1) ) ; one less than ninfo

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = ispan(1,ninfo,1)  

  res@pmLabelBarHeightF        =  0.075
 ;res@pmLabelBarWidthF         =  0.60      ; default is 0.6
 ;res@pmLabelBarOrthogonalPosF = -0.0005    ; move up smidge

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False

  res@gsnRightString   = fili
  plot = gsn_csm_contour_map_ce(wks, x, res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.010 
                            ; 3 rows x 6 columns of text
  n  = -1
  xx = 0.05                 ; arbitrary
  do ncol=0,5
     yy = 0.22 
    do nrow=0,2
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 3*rtxt@txFontHeightF
    end do
     xx = xx + 0.155 
  end do
  draw(plot)
  frame(wks)


end

