begin

diro = "~/archive/ERA5_data/ncfile/"
fil1 = "1h_ERA5-20180714-0820-1000hpa.nc"

type = "x11"
;type = "png"

blat = 36.5
tlat = 38.5
llon = 126
rlon = 128


wks = gsn_open_wks(type,"Geow")

file1 = addfile(diro+fil1,"r")

lon = file1->longitude
lat = file1->latitude
time = file1->time

bj = ind(lat.eq.blat)
tj = ind(lat.eq.tlat)
li = ind(lon.eq.llon)
ri = ind(lon.eq.rlon)
print(bj)
print(tj)
print(li)
print(ri)

dt = dimsizes(time)

Z = file1->z(:,bj:tj,li:ri)
sf = Z@scale_factor
ofs = Z@add_offset

Zr = (Z*sf)+ofs
;print(Zr)

lonr = lon(li:ri)
latr = lat(bj:tj)

geow = z2geouv(Zr,latr,lonr,0)

geou = geow(0,:,:,:)
geov = geow(1,:,:,:)

;print(geou)

geou!0 = "time"
geou!1 = "lat"
geou!2 = "lon"
geou&time = time
geou&lat = latr
geou&lon = lonr

geov!0 = "time"
geov!1 = "lat"
geov!2 = "lon"
geov&time = time
geov&lat = latr
geov&lon = lonr


;================= Plotting Section ======================

res_v							= True
res_v@gsnDraw					= True
res_v@gsnFrame					= True
res_v@gsnAddCyclic				= False

res_v@mpLimitMode				= "Corners"
res_v@mpLeftCornerLatF			= blat
res_v@mpLeftCornerLonF			= llon
res_v@mpRightCornerLatF			= tlat
res_v@mpRightCornerLonF			= rlon
res_v@mpDataBaseVersion			= "HighRes"

res_v@pmTickMarkDisplayMode		= "Always"
res_v@gsnMaximize				= False
res_v@vcRefMagnitudeF           = 100.0      ;
res_v@vcRefAnnoArrowLineColor   = "black"  ;
res_v@vcRefAnnoArrowUseVecColor = False    ;
res_v@vcRefLengthF              = 0.04     ;
res_v@vcMinDistanceF            = 0.02
res_v@vcLineArrowThicknessF     = 5.0      ;
res_v@vcRefAnnoString1          = res_v@vcRefMagnitudeF+" m s~S2~-1"                                           ;
res_v@vcRefAnnoFontHeightF      = 0.015    ;
res_v@vcRefAnnoString2On        = False    ;
res_v@vcRefAnnoSide             = "Bottom" ;
res_v@vcRefAnnoPerimOn          = False    ;
;res_v@vcRefAnnoArrowMinOffsetF = 0.2
res_v@vcRefAnnoOrthogonalPosF   = -1.12    ;
res_v@vcRefAnnoParallelPosF     = 0.98     ;
;res_v@vcRefAnnoArrowSpaceF     = 1.7
res_v@gsnLeftString             = ""
res_v@gsnRightString            = ""

do i = 0, dt -1
vector = gsn_csm_vector_map(wks,geou(i,:,:),geov(i,:,:),res_v)

end do



end
