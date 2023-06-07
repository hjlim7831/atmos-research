begin

diri = "~/2021-win/2D_wrf/model/sea_breeze/conv_roof/"
diro= "~/2021-win/2D_wrf/picture/"
fil1 = "wrfout_d01_2008-06-20_00:00:00"
name = "CROSS_DIURNAL"
colorb = "NCV_blue_red"

var_name = (/"U","W"/)

; type = "x11"
 type = "png"
; type = "ps"
; type = "ncgm"

cst  = -2.0
ced  = 2.0
clen = 17


tstart = 0
tend = 144
intt = 1
dimt = (tend-tstart+1)/intt
tm = fspan(tstart,tend,dimt)/6.

a1 = addfile(diri+fil1,"r")

left_string = (/"u (m s~S2~-1  )", "w (m s~S2~-1  )"/)

vardim = getfilevardimsizes(a1,"P")

dimz = vardim(0)
dimy = vardim(2)
dimx = vardim(3)

varn = dimsizes(var_name)

; ======================== Drawing Resources ============================

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


; ========================= Loop Section ================================

varbox = new((/varn,dimt,dimy,dimx/),float)

do vi = 0, varn -1
	varbox(vi,:,:,:) = a1->$var_name(vi)$(tstart:tend:intt,:,:)











end
