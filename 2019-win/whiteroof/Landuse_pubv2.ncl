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
  bres@tmXBMajorThicknessF      = 4.0
  bres@tmYLMajorThicknessF      = 4.0
  bres@tmBorderThicknessF       = 4.0

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

;===================================== Main Code ==============================================


begin
  diri = "./"                          ; input directory
  fili = "e2wrfout_d03_2018-07-14_12:00:00"
  f    = addfile (diri+fili, "r")


  x    = f->LU_INDEX(0,:,:)                      ; note: type byte
;  x!0 = "south_north"
;  x!1 = "west_east"

  dimx = dimsizes(x(0,:))
  dimy = dimsizes(x(:,0))
  lat = f->XLAT(0,:,:)
  lon = f->XLONG(0,:,:)
  x@lat2d = lat
  x@lon2d = lon


 printVarSummary(x)

  info     = (/ "  1  Evergreen Needleleaf Forest  ", \
				"  4  Deciduous Broadleaf Forest   ", \
  				"  5  Mixed Forests                ", \
				"  7  Open Shrublands              ", \
				"  9  Savannas                     ", \
                "10  Grasslands                   ", \  ; n=9
                "11  Permanent Wetlands           ", \
                "12  Croplands                    ", \
                "13  Urban and Built-up           ", \
				"14  cropland/natural vegetation mosaic", \
                "16  Barren/Sparsely Vegetated    ", \
                "17  Water                        ", \
				"33  Industrial/Commercial     "  /) ; n=23
  ninfo    = dimsizes(info)

 colorscheme = (/"darkseagreen","palegreen1","palegreen4",\
		"salmon","orange","seagreen3",\
		"lightsteelblue","lightgoldenrod1","red","green",\
		"darkgoldenrod","royalblue",\
		"red4"/) 
cinfo = (/1,4,5,7,9,10,11,12,13,14,16,17,33/)


 ncolors = dimsizes(colorscheme)
 if (ninfo.ne.ncolors) then             ; make sure # of colors match categories (classes)
      print("size mismatch: ninfo="+ninfo+"   ncolors="+ncolors)
      exit
  end if


;************************************************
; create plot
;************************************************

type = "png"
;type = "oldps"
;type = "x11"

  wks = gsn_open_wks(type,"luindex_pubv2")        ; send graphics to PNG file

  res                  = True                ; plot mods desired
  res@gsnDraw          = False
  res@gsnFrame         = False
;  res@gsnPaperMargin   = 0.3
;  res@gsnPaperWidth    = 20
;  res@gsnPaperHeight   = 11
;  res@wkWidth			= 20
;  res@wkHeight			= 20

;  res@gsnMaximize      = True
  res@mpProjection	   = "LambertConformal"
  res@gsnAddCyclic	   = False
  res@mpLambertParallel1F = f@TRUELAT1
  res@mpLambertParallel2F = f@TRUELAT2
  res@mpLambertMeridianF  = f@CEN_LON
  res@mpLimitMode		  = "Corners"
  res@mpLeftCornerLatF	  = lat(4,4)
  res@mpLeftCornerLonF	  = lon(4,4)
  res@mpRightCornerLatF   = lat(dimy-5,dimx-5)
  res@mpRightCornerLonF	  = lon(dimy-5,dimx-5)
  res@mpDataBaseVersion	  = "HighRes"


  res@pmTickMarkDisplayMode = "Always"
  res@tmXTOn				= False
  res@tmYROn				= False

  res@cnFillOn         = True               ; color Fill 
  res@cnFillMode       = "RasterFill"       ; Raster Mode
  res@cnLinesOn        = False              ; Turn off contour lines

  res@cnFillPalette     = colorscheme
  res@gsnSpreadColors   = False
; res@cnFillPalette     = "vegetation_modis"
  res@cnSpanFillPalette = False

  res@cnLineLabelsOn   = False              ; Turn off contour line labels

  res@cnLevelSelectionMode = "ExplicitLevels"              ; set explict contour levels
  res@cnLevels         = integertobyte( cinfo(1:) ) ; one less than ninfo

  res@lbLabelPosition  = "Center"           ; label position
  res@lbLabelAlignment = "BoxCenters"       ; label orientation
  res@lbLabelStrings   = cinfo  
  res@lbOrientation = "vertical"

  res@pmLabelBarHeightF        =  0.40
 ;res@pmLabelBarWidthF         =  0.075      ; default is 0.6
  res@pmLabelBarOrthogonalPosF =  -0.047      
  res@pmLabelBarParallelPosF   = 0.41
  res@lbBoxLineThicknessF	   = 4.0

  res@mpCenterLonF     = 0                  ; set map center
  res@mpFillOn         = False
  res@gsnLeftString	   = " "
  res@vpXF			   = 0.13
  res@vpYF			   = 0.8
  res@vpWidthF		   = 0.5
  res@vpHeightF		   = 0.5
  plot = gsn_csm_contour_map(wks, x, res) ; create plot

  rtxt = True
  rtxt@txJust        = "CenterLeft"
  rtxt@txFontHeightF = 0.015
                            ; 3 rows x 6 columns of text
/;
  n  = -1
  xx = 0.21                 ; arbitrary
  do ncol=0,2
     yy = 0.07
    do nrow=0,2
	   if n .eq. ncolors-1 then
		   break
	   else
       n = n+1
       gsn_text_ndc (wks,info(n),xx,yy,rtxt)
       yy = yy - 2.5*rtxt@txFontHeightF
	   end if
    end do
     xx = xx + 0.20
  end do
;/

xx = 0.619
yy = 0.325
do ii = 0, ncolors-1
	gsn_text_ndc(wks,info(ii),xx,yy,rtxt)
	yy = yy + 2.0*rtxt@txFontHeightF
end do



  tmres			= True
  tmres@tmXBLabelFontHeightF = 0.018
  tmres@tmYLValues = fspan(37.0,38.2,4)
  tmres@tmXBValues = fspan(126.4,127.6,4)

  plot = add_map_tickmarks2(wks,plot,tmres)

  psres = True
  maximize_output(wks,psres)

;  draw(plot)
;  frame(wks)


end

