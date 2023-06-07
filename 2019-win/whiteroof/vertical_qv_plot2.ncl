begin

za = ispan(0,2000,50)
dimz = dimsizes(za)
diur = 24

print(za(28))

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"tmqv.nc","r")

tmqv = a1->tmqv * 1000.


; type = "x11"
 type = "png"
; type = "oldps"
 wks = gsn_open_wks(type,"Compare_vertical_diurnal_qv")

res = True
res@xyMarkLineModes = (/"Lines","Lines"/)
res@xyLineThicknesses = (/4.0,4.0/)
res@xyDashPatterns = (/0,0/)
res@xyLineColors = (/"Blue","Red"/)
;res@tiMainOn		= "True"
res@tiXAxisString = "water vapor mixing ratio (g kg ~S2~-1  )"
res@tiYAxisString = "height (km)"
res@trYMaxF		= 2
;res@trXMinF     = 28
;res@trXMaxF		= 38
res@tmYLMode	= "Explicit"
;res@tmXBMode	= "Explicit"
;res@tmXBValues	= ispan(28,38,2)
;res@tmXBLabels = (/"28","30","32","34","36","38"/)
;res@tmXBMinorValues = fspan(26,38,25)
res@tmYLValues = tofloat(ispan(0,2000,400))/1000
res@tmYLLabels = tofloat(ispan(0,2000,400))/1000
res@tmYLMinorValues = tofloat(ispan(0,2000,100))/1000

res@tiMainFontHeightF = 0.020

res@vpHeightF	= 0.6
res@vpWidthF	= 0.3

res@pmLegendDisplayMode 	= "Always"
res@lgPerimOn				= False
res@pmLegendWidthF			= 0.10
res@pmLegendHeightF			= 0.05
res@pmLegendOrthogonalPosF	= -1.13
res@pmLegendParallelPosF	= 0.38
res@xyExplicitLegendLabels	= (/"  cool-roof case","  conventional-roof case"/)
res@lgLabelFontHeightF		= 0.012
res@lgBoxMinorExtentF		= 0.25


plots = new(diur,graphic)



zbox = new((/2,dimz/),float)
zbox(0,:) = za/1000.
zbox(1,:) = za/1000.

do ii = 0, diur -1
;ii = 12
	nn = mod(ii + 1, 24)
;	res@tiMainString = sprinti("%2.2i",nn) + "00 LST"
	plots(ii) = gsn_csm_xy(wks,tmqv(:,ii,2:),zbox(:,2:),res)
end do



end
