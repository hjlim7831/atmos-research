begin

diro = "~/2019-win/test_model/"
diri = "csv/"

fil1 = "scatter_data.csv"

lines = asciiread(diro+diri+fil1,-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

TITLE = "("+ (/"a","b"/) + ")"


printVarSummary(fields)

dv = dimsizes(fields(0,:))
dt = dimsizes(fields(:,0))

;maxt_nor = tofloat(fields(:,3))
;maxtdf_nor = tofloat(fields(:,4))
;15windano_nor = tofloat(fields(:,5))
;maxt_r = tofloat(fields(:,0))
;maxtdf_r = tofloat(fields(:,1))
;15windano_r = tofloat(fields(:,2))

xbox = new((/2,dt/),float)
ybox = new((/2,dt/),float)
xbox2 = new((/2,dt/),float)
ybox2 = new((/2,dt/),float)


xbox(0,:) = tofloat(fields(:,3)) ; no rain maxt
xbox(1,:) = tofloat(fields(:,0)) ; rain maxt
ybox(0,:) = tofloat(fields(:,4)) ; no rain maxtdf
ybox(1,:) = tofloat(fields(:,1)) ; rain maxtdf

xbox2(0,:) = tofloat(fields(:,3)) ; no rain maxt
xbox2(1,:) = tofloat(fields(:,0)) ; rain maxt
ybox2(0,:) = tofloat(fields(:,5)) ; no rain windano
ybox2(1,:) = tofloat(fields(:,2)) ; rain windano

;print(maxt_nor)
;print(maxt_r)
;print(maxtdf_nor)
;print(maxtdf_r)

xmax = 36
xmin = 29
ymax = 0.8
ymin = 0.2

xmax2 = 36
xmin2 = 29
ymax2 = 0.7
ymin2 = 0


res						= True
res@gsnFrame			= False
res@gsnDraw				= False
res@tmXBMode			= "Explicit"
res@tmYLMode			= "Explicit"
res@tmXBValues			= ispan(xmin,xmax,1)
res@tmXBLabels			= (/"29","30","31","32","33","34","35","36"/)
res@tmXBMinorValues		= fspan(xmin,xmax,tointeger((xmax-xmin)*4+1))
res@tmXTOn				= False
res@tmYROn				= False

res1					= res
res1@tmYLValues         = (/0.2,0.4,0.6,0.8/)
res1@tmYLLabels         = (/"0.2","0.4","0.6","0.8"/)
res1@tmYLMinorValues    = fspan(ymin,ymax,25)
res1@tiXAxisString      = "daily maximum temperature (~F34~0~F~C)"
res1@tiYAxisString      = "difference in daily maximum temperature (~F34~0~F~C)"


res11					= res1
res11@xyMarkLineModes	= (/"Markers","Markers"/)
res11@xyMarkers			= (/16,4/)
res11@trYMaxF            = ymax
res11@trYMinF            = ymin
res11@trXMaxF            = xmax
res11@trXMinF            = xmin
res11@gsnLeftString      = TITLE(0)
res11@gsnLeftStringFontHeightF = 0.030



; type = "x11"
; type = "png"
 type = "oldps"
  wks = gsn_open_wks(type,"SCATTER_TEMP_PUB")



plot1 = gsn_csm_xy(wks,xbox,ybox,res11)

res12								= res1
res12@xyLineThicknesses				= 2.0
res12@xyDashPatterns					= 0
res12@trYMaxF						= ymax
res12@trYMinF						= ymin
res12@trXMaxF						= xmax
res12@trXMinF						= xmin
res12@gsnRightString					= "y = ~F29~-~F21~0.02x + 1.32"
res12@gsnRightStringOrthogonalPosF	= -0.92
res12@gsnRightStringParallelPosF		= 0.97
res12@gsnRightStringFontHeightF		= 0.022
res12@gsnLeftString					= "R = ~F29~-~F21~0.40"
res12@gsnLeftStringOrthogonalPosF   = -0.98
res12@gsnLeftStringParallelPosF     = 0.57
res12@gsnLeftStringFontHeightF      = 0.022



xx = ispan(xmin,xmax,1)
yy = -0.0245*xx+1.3215

print(-0.0245*30+1.3215)
print(-0.0245*35+1.3215)


ov1 = gsn_csm_xy(wks,xx,yy,res12)

overlay(plot1,ov1)

res2					= res
res2@tmYLValues          = (/0,0.2,0.4,0.6,0.8/)
res2@tmYLLabels          = (/"0","0.2","0.4","0.6","0.8"/)
res2@tmYLMinorValues     = fspan(ymin2,ymax2,17)
res2@tiXAxisString       = "daily maximum temperature (~F34~0~F~C)"
res2@tiYAxisString       = "difference in wind speed at 1500 LST (m s~S2~-1  )"


res21                    = res2

res21@xyMarkLineModes    = (/"Markers","Markers"/)
res21@xyMarkers          = (/16,4/)
res21@trYMaxF            = ymax2
res21@trYMinF            = ymin2
res21@trXMaxF            = xmax2
res21@trXMinF            = xmin2
res21@gsnLeftString		 = TITLE(1)
res21@gsnLeftStringFontHeightF = 0.030

plot2 = gsn_csm_xy(wks,xbox2,ybox2,res21)

res22                                = res2
res22@xyLineThicknesses              = 2.0
res22@xyDashPatterns                 = 0
res22@trYMaxF                        = ymax2
res22@trYMinF                        = ymin2
res22@trXMaxF                        = xmax2
res22@trXMinF                        = xmin2
res22@gsnRightString                 = "y = 0.03x ~F29~-~F21~ 0.57"
res22@gsnRightStringOrthogonalPosF   = -0.92
res22@gsnRightStringParallelPosF     = 0.97
res22@gsnRightStringFontHeightF      = 0.022
res22@gsnLeftString                  = "R = 0.43"
res22@gsnLeftStringOrthogonalPosF   = -0.98
res22@gsnLeftStringParallelPosF     = 0.6
res22@gsnLeftStringFontHeightF      = 0.022

xx2 = ispan(xmin2,xmax2,1)
yy2 = 0.0301*xx - 0.5712

ov2 = gsn_csm_xy(wks,xx2,yy2,res22)

overlay(plot2,ov2)



panel_res			= True

gsn_panel(wks,(/plot1,plot2/),(/2,1/),panel_res)








end
