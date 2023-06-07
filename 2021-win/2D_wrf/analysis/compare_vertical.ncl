begin
st = get_cpu_time()

diri = "~/2021-win/2D_wrf/model/test3/"
diro= "~/2021-win/2D_wrf/picture/"
fil1 = "wrfout_d01_2008-06-20_00:00:00"
name = "COMPARE_VERTICAL"

var_name = (/"T","QVAPOR"/)

tstart = 0
tend = 144
intt = 1
dimt = (tend-tstart+1)/intt
diur = 144 ; 10 minutes interval
tm = fspan(0,diur,dimt)/6.

a1 = addfile(diri+fil1,"r")

; =========================== variable setting ===================================

var_name = (/"HFX","LH","GRDFLX","SWDOWN","GLW"/)

plot_set = (/3,2/)

ystring = (/"sensible heat flux (W m~S2~-2  )",\
			"latent heat flux (W m~S2~-2  )",\
			"ground heat flux (W m~S2~-2  )",\
			"downward shortwave radiation (W m~S2~-2  )",\
			"downward longwave radiation (W m~S2~-2  )"/)

vardim = getfilevardimsizes(a1,"P")

dimz = vardim(0)
dimy = vardim(2)
dimx = vardim(3)

varn = dimsizes(var_name)

dx = 250 ; m
xlen = 800 * 1000 ; m

uxst = 90 * 1000/dx
uxed = 110 * 1000/dx
rxst = 130 * 1000/dx
rxed = 150 * 1000/dx

varbox = new((/varn,dimt,dimy,dimx/),float)
tvarbox = new((/varn,3,dimt/),float)

; ===================== Plotting Resources =================================

 type = "x11"
; type = "png"
wks = gsn_open_wks(type,diro+name)
 res = True
 res@xyMarkLineModes = (/"Lines","Lines","Lines"/)
 res@xyLineThicknesses = (/4.0,4.0,4.0/)
 res@xyDashPatterns = (/0,2,0/)
 res@xyLineColors = (/"Black","Black","Gray"/)

 res@tmXBMode = "Explicit"
 res@tmXBValues = ispan(0,24,6)
 res@tmXBLabels = ispan(0,24,6)
 res@tmXBMinorValues = ispan(0,24,1)


; res@pmLegendDisplayMode = "Always"
; res@pmLegendSide = "Top"
; res@pmLegendParallelPosF = .2
; res@pmLegendOrthogonalPosF = -0.25
; res@pmLegendWidthF = 0.12
; res@pmLegendHeightF = 0.09
; res@lgPerimOn = False
; res@lgLabelFontHeightF = .020
; res@xyExplicitLegendLabels = (/" URBAN"," NO-URBAN"," "/)

 res@tiXAxisString = "time(KST)"
 res@tiXAxisFontHeightF = 0.035
 res@tmXBLabelFontHeightF = 0.03
 res@tmYLLabelFontHeightF = 0.03
 res@tiMainFontHeightF = 0.025
 res@gsnDraw = False
 res@gsnFrame = False

; ================================ Loop Section =============================================

do vi = 0, varn -1

varbox(vi,:,:,:) = a1->$var_name(vi)$(tstart:tend:intt,:,:)

tvarbox(vi,0,:) = dim_avg_n(varbox(vi,:,:,uxst:uxed),(/1,2/))
tvarbox(vi,1,:) = dim_avg_n(varbox(vi,:,:,rxst:rxed),(/1,2/))

end do

tbox = new((/3,dimt/),float)

tbox(0,:) = tm
tbox(1,:) = tm
tbox(2,:) = tm

print("Data Averaging Time: "+ (get_cpu_time() - st))

plots = new(varn,graphic)

do vi = 0, varn -1

res1 = res
res1@tiYAxisString = ystring(vi)
plots(vi) = gsn_csm_xy(wks,tbox,tvarbox(vi,:,:),res1)

end do

pnlres = True

opt = True
opt@NumberLegendItems = 2
opt@LegendLabels = (/" Default"," White roof"/)
;annoid = create_legend_from_plot(wks,plots(0),opt)


gsn_panel(wks,(/plots/),(/plot_set(0),plot_set(1)/),pnlres)


print("Total Time: "+ (get_cpu_time() - st))

end
