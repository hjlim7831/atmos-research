begin

;type = "x11"
type = "png"

wks = gsn_open_wks(type,"location_map")


  res                             = True
  res@mpFillOn                    = False        ; turn off gray fill
  res@mpDataBaseVersion			  = "HighRes"
  res@mpOutlineBoundarySets       = "National"   ; turn on country boundaries
  res@mpGeophysicalLineColor      = "Navy"       ; color of cont. outlines
  res@mpGeophysicalLineThicknessF = 1.5          ; thickness of outlines

  res@mpMaxLatF                   = 39           ; choose subregion           
  res@mpMinLatF                   = 32
  res@mpMaxLonF                   = 132
  res@mpMinLonF                   = 124
  res@gsnFrame					  = False
  res@gsnDraw					  = False
  plot = gsn_csm_map(wks,res)                 ; draw map

lat1 = (/37.5714,35.1047,35.5825,35.1729,55.878,36.372,37.4777,33.2938,37.4813/)
lat2 = (/37.5498,35.1531,35.5347,35.1549,35.8305,36.3724,37.4684,33.2925,37.5223/)

lon1 = (/126.9658,129.032,129.3347,126.8916,128.653,127.3721,126.6249,126.1628,130.8986/)
lon2 = (/126.9456,129.064,129.3081,126.8885,128.6316,127.3739,126.6348,126.1622,130.7967/)

gres = True
gres@gsMarkerColor = "green"
gres@gsMarkerIndex = 16
gres@gsLineThicknessF = 3.
gres@gsMarkerOpacityF = 0.7

Markers = new(9,graphic)
Markers2 = new(9,graphic)
do i = 0, 9 -1
	Markers(i) = gsn_add_polymarker(wks,plot,lon1(i),lat1(i),gres)
end do

gres@gsMarkerColor = "red"

do i = 0, 9-1
	Markers2(i) = gsn_add_polymarker(wks,plot,lon2(i),lat2(i),gres)
end do


draw(plot)
frame(wks)

end
