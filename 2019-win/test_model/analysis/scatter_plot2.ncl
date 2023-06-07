begin

diro = "~/2019-win/whiteroof/"
diri = "csv/"

fil = "scatter_data.csv"

lines = asciiread(diro+diri+fil,-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

printVarSummary(fields)

dv = dimsizes(fields(0,:))
dt = dimsizes(fields(:,0))

;maxt_nor = tofloat(fields(:,0))
;maxtdf_nor = tofloat(fields(:,1))
;15windano_nor = tofloat(fields(:,2))
;maxt_r = tofloat(fields(:7,3))
;maxtdf_r = tofloat(fields(:7,4))
;15windano_r = tofloat(fields(:7,5)


xbox = new((/2,dt/),float)
ybox = new((/2,dt/),float)

xbox(0,:) = tofloat(fields(:,2))
xbox(1,:) = tofloat(fields(:,5))
ybox(0,:) = tofloat(fields(:,1))
ybox(1,:) = tofloat(fields(:,4))

;print(maxt_nor)
;print(maxt_r)
;print(maxtdf_nor)
;print(maxtdf_r)

xmax = 0.6
xmin = -0.2
ymax = 0.8
ymin = -0.2

res						= True
res@gsnFrame			= False
res@gsnDraw				= False
res@tmXBMode			= "Explicit"
res@tmYLMode			= "Explicit"
res@tmXBValues			= fspan(xmin,xmax,6)
res@tmXBLabels			= (/"~F18~-~F21~0.2","0","0.2","0.4","0.6","0.8"/)
res@tmXBMinorValues		= fspan(xmin,xmax,21)

res@tmYLValues			= (/-0.2,0,0.2,0.4,0.6,0.8/)
res@tmYLLabels			= (/"~F18~-~F21~0.2","0","0.2","0.4","0.6","0.8"/)
res@tmYLMinorValues		= fspan(ymin,ymax,21)
res@tiXAxisString		= "wind anomalies differences at 15:00 (m s~S2~-1  )"
res@tiYAxisString		= "daily maximum temperature differences (~F34~0~F~C)"


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
  wks = gsn_open_wks(type,"SCATTER_TEMP_RAIN2")



plot1 = gsn_csm_xy(wks,xbox,ybox,res1)

res2								= res
res2@xyLineThicknesses				= 4.0
res2@xyDashPatterns					= 0
res2@trYMaxF						= ymax
res2@trYMinF						= ymin
res2@trXMaxF						= xmax
res2@trXMinF						= xmin
res2@gsnRightString					= "y = 0.55x + 0.42"
res2@gsnRightStringOrthogonalPosF	= -1.0
res2@gsnRightStringParallelPosF		= 0.97


xx = fspan(xmin,xmax,20)
yy = 0.5457*xx + 0.4167

plot2 = gsn_csm_xy(wks,xx,yy,res2)

draw(plot1)
draw(plot2)
frame(wks)











end
