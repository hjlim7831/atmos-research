begin

;diri1 = "~/2021-win/2D_wrf/model/main/sea_breeze/conv_roof/"
;diri2 = "~/2021-win/2D_wrf/model/main/sea_breeze/white_roof/"
diri1 = "~/2021-win/2D_wrf/model/main/plain_surface/conv_roof/"
diri2 = "~/2021-win/2D_wrf/model/main/plain_surface/white_roof/"

diro= "~/2021-win/2D_wrf/picture/"
;fil1 = "wrfout_d01_2008-06-20_00:00:00"
fil1 = "wrfout_d01_2008-08-01_18:00:00"
name = "HOV_TEMP_DIFF_NSB"
colorb = "NCV_blue_red"


 type = "x11"
; type = "png"
; type = "ps"
; type = "ncgm"

cst  = -2.0
ced  = 2.0
clen = 17


tstart = 0 + 36
tend = 144 + 36
intt = 1
dimt = (tend-tstart+1)/intt
diur = 144 ; 10 minutes interval
tm = fspan(0,tend-tstart,dimt)/6.


a1 = addfile(diri1+fil1,"r")
a2 = addfile(diri2+fil1,"r")

t2 = a2->T(tstart:tend:intt,0,0,:) - a1->T(tstart:tend:intt,0,0,:)

printVarSummary(t2)
printVarSummary(tm)

xx = ispan(-200,199,1)

t2!0 = "time"
t2!1 = "x"
t2&time = tm
t2&x = xx
;================= Drawing Resources =====================

cmap = read_colormap_file(colorb)


res								= True
res@cnFillOn					= True
res@cnLinesOn					= False
res@cnFillPalette				= cmap
res@cnLevelSelectionMode		= "ExplicitLevels"
res@cnLevels					= fspan(cst,ced,clen)
res@tmXBMode					= "Manual"
res@tmXBTickStartF				= -200
res@tmXBTickEndF				= 200
res@tmXBTickSpacingF			= 40


wks = gsn_open_wks(type,diro+name)

plot = gsn_csm_hov(wks,t2,res)







end
