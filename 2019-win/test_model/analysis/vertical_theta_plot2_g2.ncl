begin

za = ispan(0,2000,50)
dimz = dimsizes(za)
diur = 24

name = "picture/Compare_vertical_diurnal_theta2"

targ = 22

print(za(targ))

diro = "~/2019-win/test_model/"
a1 = addfile(diro+"analysis/tmtheta.nc","r")

tmtheta = a1->tmtheta - 273.15

printVarSummary(tmtheta)

ntmtheta = new((/2,24,41/),float)
ntmtheta(0,:,:) = tmtheta(1,:,:)
ntmtheta(1,:,:) = tmtheta(0,:,:)

tt = dim_avg_n(tmtheta(:,12,:targ),(/1/))
print(tt(1) - tt(0))

; type = "x11"
;  type = "png"
 type = "oldps"
 wks = gsn_open_wks(type,diro+name)

res = True
res@xyMarkLineModes = (/"Lines","Lines"/)
res@xyLineThicknesses = (/4.0,4.0/)
res@xyDashPatterns = (/0,0/)
res@xyLineColors = (/"Red","Blue"/)
;res@tiMainOn		= "True"
res@tiXAxisString = "potential temperature (~F34~0~F~C)"
res@tiYAxisString = "height (km)"
res@trYMaxF		= 2
res@trXMinF     = 28
res@trXMaxF		= 38
res@tmYLMode	= "Explicit"
res@tmXBMode	= "Explicit"
res@tmXBValues	= ispan(28,38,2)
res@tmXBLabels = (/"28","30","32","34","36","38"/)
res@tmXBMinorValues = fspan(26,38,25)
res@tmYLValues = tofloat(ispan(0,2000,400))/1000
res@tmYLLabels = tofloat(ispan(0,2000,400))/1000
res@tmYLMinorValues = tofloat(ispan(0,2000,100))/1000

res@tiMainFontHeightF = 0.020

res@vpHeightF	= 0.52
res@vpWidthF	= 0.3

res@pmLegendDisplayMode 	= "Always"
res@lgPerimOn				= False
res@pmLegendWidthF			= 0.10
res@pmLegendHeightF			= 0.05
res@pmLegendOrthogonalPosF	= -1.14
res@pmLegendParallelPosF	= 0.36
;res@xyExplicitLegendLabels	= (/"  cool-roof case","  conventional-roof case"/)
res@xyExplicitLegendLabels = (/"  conventional-roof case","  cool-roof case"/)
res@lgLabelFontHeightF		= 0.012
res@lgBoxMinorExtentF		= 0.25


plots = new(diur,graphic)



zbox = new((/2,dimz/),float)
zbox(0,:) = za/1000.
zbox(1,:) = za/1000.

;do ii = 0, diur -1
ii = 12
	nn = mod(ii, 24)
;	res@tiMainString = sprinti("%2.2i",nn) + "00 LST"
	plots(ii) = gsn_csm_xy(wks,ntmtheta(:,ii,2:),zbox(:,2:),res)
;end do



end
