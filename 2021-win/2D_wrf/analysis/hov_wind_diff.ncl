begin

;diri1 = "~/2021-win/2D_wrf/model/sea_breeze/conv_roof/"
;diri2 = "~/2021-win/2D_wrf/model/sea_breeze/white_roof/"
diri1 = "~/2021-win/2D_wrf/model/plain_surface/conv_roof/"
diri2 = "~/2021-win/2D_wrf/model/plain_surface/white_roof/"

diro= "~/2021-win/2D_wrf/picture/"
fil1 = "wrfout_d01_2008-06-20_00:00:00"
name = "HOV_WIND_DIFF_NSB"
colorb = "NCV_blue_red"


; type = "x11"
 type = "png"
; type = "ps"
; type = "ncgm"

cst  = -5.0
ced  = 5.0
clen = 21


tstart = 0
tend = 144
intt = 1
dimt = (tend-tstart+1)/intt
diur = 144 ; 10 minutes interval
tm = fspan(0,diur,dimt)/6.


a1 = addfile(diri1+fil1,"r")
a2 = addfile(diri2+fil1,"r")

t2 = a2->U10(:,0,:) - a1->U10(:,0,:)

printVarSummary(t2)
printVarSummary(tm)

t2!0 = "time"
t2!1 = "x"
t2&time = tm

;================= Drawing Resources =====================

cmap = read_colormap_file(colorb)


res								= True
res@cnFillOn					= True
res@cnLinesOn					= False
res@cnFillPalette				= cmap
res@cnLevelSelectionMode		= "ExplicitLevels"
res@cnLevels					= fspan(cst,ced,clen)
res@tmXBMode					= "Manual"
res@tmXBTickStartF				= 0
res@tmXBTickEndF				= 200
res@tmXBTickSpacingF			= 20


wks = gsn_open_wks(type,diro+name)

plot = gsn_csm_hov(wks,t2,res)



























end
