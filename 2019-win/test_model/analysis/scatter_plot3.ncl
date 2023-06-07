begin

diro = "~/2019-win/whiteroof/"
diri = "csv/"

fil = "scatter_data2.csv"

lines = asciiread(diro+diri+fil,-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

printVarSummary(fields)

dv = dimsizes(fields(0,:))
dt = dimsizes(fields(:,0))

;maxt_nor = tofloat(fields(:,0))
;wsdf_nor = tofloat(fields(:,1))
;maxt_r = tofloat(fields(:7,2))
;wsdf_r = tofloat(fields(:7,3))

xbox = new((/2,dt/),float)
ybox = new((/2,dt/),float)

xbox(0,:) = tofloat(fields(:,0))
xbox(1,:) = tofloat(fields(:,2))
ybox(0,:) = tofloat(fields(:,1))
ybox(1,:) = tofloat(fields(:,3))

;print(maxt_nor)
;print(maxt_r)
;print(maxtdf_nor)
;print(maxtdf_r)

xmax = 36
xmin = 29
ymax = 0.8
ymin = 0

res						= True
res@gsnFrame			= False
res@gsnDraw				= False
res@tmXBMode			= "Explicit"
res@tmYLMode			= "Explicit"
res@tmXBValues			= ispan(xmin,xmax,1)
res@tmXBLabels			= (/"29","30","31","32","33","34","35","36"/)
res@tmXBMinorValues		= fspan(xmin,xmax,tointeger((xmax-xmin)*4+1))

res@tmYLValues			= (/0,0.2,0.4,0.6,0.8/)
res@tmYLLabels			= (/"0","0.2","0.4","0.6","0.8"/)
res@tmYLMinorValues		= fspan(ymin,ymax,17)
res@tiXAxisString       = "daily maximum temperature (~F34~0~F~C)"
res@tiYAxisString		= "difference in wind speed at 1500 LST (m s~S2~-1  )"


res1					= res

res1@xyMarkLineModes	= (/"Markers","Markers"/)
res1@xyMarkers			= (/16,4/)
res1@trYMaxF            = ymax
res1@trYMinF            = ymin
res1@trXMaxF            = xmax
res1@trXMinF            = xmin


; type = "x11"
 type = "png"
; type = "oldps"
  wks = gsn_open_wks(type,"SCATTER_TEMP_RAIN3")



plot1 = gsn_csm_xy(wks,xbox,ybox,res1)

res2								= res
res2@xyLineThicknesses				= 4.0
res2@xyDashPatterns					= 0
res2@trYMaxF						= ymax
res2@trYMinF						= ymin
res2@trXMaxF						= xmax
res2@trXMinF						= xmin
res2@gsnRightString					= "y = 0.04x ~F29~-~F21~ 0.89"
res2@gsnRightStringOrthogonalPosF	= -0.94
res2@gsnRightStringParallelPosF		= 0.97
res2@gsnRightStringFontHeightF		= 0.022
res2@gsnLeftString					= "R = 0.54"
res2@gsnLeftStringOrthogonalPosF   = -1.0
res2@gsnLeftStringParallelPosF     = 0.6
res2@gsnLeftStringFontHeightF      = 0.022



xx = ispan(xmin,xmax,1)
yy = 0.0423*xx - 0.8906

plot2 = gsn_csm_xy(wks,xx,yy,res2)

draw(plot1)
draw(plot2)
frame(wks)











end
