begin

za = ispan(0,2000,50)
dimz = dimsizes(za)
diur = 24

targ = 22

print(za(targ))

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"tmtc.nc","r")

tmtheta = a1->tmtheta

printVarSummary(tmtheta)

;tt = dim_avg_n(tmtheta(:,12,:targ),(/1/))
;print(tt(1) - tt(0))

tt2 = tmtheta(:,12,:)
targtemp = abs(tt2(1,:)-tt2(0,:))
print(targtemp)
print(min(targtemp))
IND = ind(targtemp.eq.min(targtemp))
print(za(IND))


; type = "x11"
;  type = "png"
 type = "oldps"
 wks = gsn_open_wks(type,"Compare_vertical_diurnal_temp")

res = True
res@xyMarkLineModes = (/"Lines","Lines"/)
res@xyLineThicknesses = (/4.0,4.0/)
res@xyDashPatterns = (/0,0/)
res@xyLineColors = (/"Red","Blue"/)
;res@tiMainOn		= "True"
res@tiXAxisString = "temperature (~F34~0~F~C)"
res@tiYAxisString = "height (km)"
res@trYMaxF		= 2
res@trXMinF     = 15
res@trXMaxF		= 33
res@tmYLMode	= "Explicit"
res@tmXBMode	= "Explicit"
res@tmXBValues	= ispan(15,33,3)
res@tmXBLabels = (/"15","18","21","24","27","30","33"/)
res@tmXBMinorValues = ispan(15,33,1)
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
res@pmLegendParallelPosF	= 0.58
;res@xyExplicitLegendLabels	= (/"  cool-roof case","  conventional-roof case"/)
res@xyExplicitLegendLabels = (/"  conventional-roof case","  cool-roof case"/)
res@lgLabelFontHeightF		= 0.012
res@lgBoxMinorExtentF		= 0.25


plots = new(diur,graphic)

ntmtheta = new((/2,diur,dimz/),float)
ntmtheta(0,:,:) = tmtheta(1,:,:)
ntmtheta(1,:,:) = tmtheta(0,:,:)


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
