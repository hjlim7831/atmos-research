load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"

begin

;diri = "~/2021-win/2D_wrf/model/main/sea_breeze/white_roof/"
diri = "~/2021-win/2D_wrf/model/main/plain_surface/white_roof/"
;diri = "~/2021-win/2D_wrf/model/test/test5_per/"
diro= "~/2021-win/2D_wrf/picture/"
fil1 = "wrfout_d01_2008-08-01_18:00:00"
name = "CROSS_EVOL_NSB_WHITE"
;name = "CROSS_EVOL_SB_CONV_PER"


;type = "x11"
 type = "png"
; type = "ps"

cst = 291
ced = 309
clen = ced-cst+1

dx = 1000.
zst = 0
zed = 70


; for 200 km
ist = 0
ied = 199

; for 400 km
;ist = 170
;ied = 230

;ist = 0
;ied = 399

;xtick = ispan(-200,200,1)
xtick = ispan(-100,100,1)

tstart = 0 + 36
tend = 144 + 36

intt = 1
dimt = (tend-tstart+1)/intt
diur = 144 ; 10 minutes interval
tm = fspan(0,diur,dimt)/6.

a1 = addfile(diri+fil1,"r")


t_L = wrf_user_getvar(a1,"th",-1)*1.
u_L = wrf_user_getvar(a1,"ua",-1)*1.
w_L = wrf_user_getvar(a1,"wa",-1)*1.
z_L = wrf_user_getvar(a1,"z",-1)*1./1000.

;printVarSummary(t_L)

t = t_L(tstart:tend,zst:zed,0,ist:ied)
u = u_L(tstart:tend,zst:zed,0,ist:ied)
w = w_L(tstart:tend,zst:zed,0,ist:ied)
z = z_L(tstart:tend,zst:zed,0,ist:ied)

zout = tofloat(ispan(50,3000,50))/1000.

dimz = dimsizes(zout)

delete([/t_L,u_L,w_L,z_L/])

opts = True

dimi = dimsizes(t(0,0,:))

t_intrp = new((/dimt,dimz,dimi/),float)
u_intrp = new((/dimt,dimz,dimi/),float)
w_intrp = new((/dimt,dimz,dimi/),float)


do tt = 0, dimt -1
	do i = 0, dimi -1
		t_intrp(tt,:,i) = wrf_interp_1d(t(tt,:,i),z(tt,:,i),zout)
		u_intrp(tt,:,i) = wrf_interp_1d(u(tt,:,i),z(tt,:,i),zout)
		w_intrp(tt,:,i) = wrf_interp_1d(w(tt,:,i),z(tt,:,i),zout)
	end do
end do

print(max(t_intrp))
print(min(t_intrp))

TIM = a1->Times(tstart:tend,:)
;print(TIM)

TIM2= wrf_times_c(TIM,2)
TIM3 = str_split_by_length(tostring(TIM2),2)
;print(TIM3)
MM = TIM3(:,2)
DD = TIM3(:,3)
HH = TIM3(:,4)
MN = TIM3(:,5)

TIM4 = MM+"-"+DD+" "+HH+":"+MN
;print(TIM4)

wks = gsn_open_wks(type,diro+name)

; ======================================= Drawing Resources ===============================================

res										= True
res@gsnDraw								= False
res@gsnFrame							= False
res@vpWidthF							= 0.6
res@vpHeightF							= 0.4

opts_xy									= res
opts_xy@tiYAxisString					= "height (km)"
opts_xy@tiMainOn						= False


opts_t									= opts_xy
opts_t@cnLinesOn						= False
opts_t@cnFillOn							= True
opts_t@tiMainOn							= True
opts_t@cnLevelSelectionMode				= "ExplicitLevels"
opts_t@cnLevels							= fspan(cst,ced,clen)


opts_vec 								= opts_xy
opts_vec@vcMinDistanceF					= 0.01
opts_vec@vcGlyphStyle					= "CurlyVector"
opts_vec@vcRefMagnitudeF				= 1.5
opts_vec@vcRefLengthF					= 0.04
opts_vec@vcRefAnnoOn					= True
;opts_vec@vcRefAnnoOrthogonalPosF		= -1.25
opts_vec@vcLineArrowThicknessF			= 2.5
opts_vec@vcRefAnnoString1				= opts_vec@vcRefMagnitudeF+" m s~S2~-1"
opts_vec@vcRefAnnoString2On				= False
opts_vec@vcRefAnnoPerimOn				= False
opts_vec@vcRefAnnoFontHeightF			= 0.018

pltres									= True
pltres@PanelPlot						= True
pltres@FramePlot						= False
pltres@CommonTitle						= True

do ii = 0, dimt -1
	print(ii)
	t_plane = t_intrp(ii,:,:)
	u_plane = u_intrp(ii,:,:)
	w_plane = w_intrp(ii,:,:)
	t_plane!0 = "height"
	t_plane!1 = "xaxis"

	u_plane!0 = "height"
	u_plane!1 = "xaxis"

	w_plane!0 = "height"
	w_plane!1 = "xaxis"

	t_plane&height = zout
	u_plane&height = zout
	w_plane&height = zout
	t_plane&xaxis = xtick(ist:ied)
	u_plane&xaxis = xtick(ist:ied)
	w_plane&xaxis = xtick(ist:ied)

;	printVarSummary(t_plane)
	opts_t@tiMainString = TIM4(ii)
;	contour_t = wrf_contour(a1,wks,t_plane,opts_t)
	contour_t = gsn_csm_contour(wks,t_plane,opts_t)
;	vector = wrf_vector(a1,wks,u_plane,w_plane,opts_vec)
	vector = gsn_csm_vector(wks,u_plane,w_plane,opts_vec)
;	plot = wrf_overlays(a1,wks,(/contour_t,vector/),pltres)
	overlay(contour_t,vector)
	draw(contour_t)
	frame(wks)
	delete([/contour_t,vector,u_plane,w_plane,t_plane/])
end do

com1 = "convert -delay 30 -density 100 "+diro+name+".ps "+diro+name+".gif"
;system("convert -delay 30 -density 100 "+diro+name+".ps "+diro+name+".gif")

print(com1)





end
