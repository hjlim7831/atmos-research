begin

diri1 = "../results/"
diri2 = "../data/"

name = "crosscor_t2m_ao"

fili = "cpct_rt2m.d"
fili2 = "AOindex.d"

fName1 = diri1+fili
fName2 = fili2

nt = 1440*6
fila = asciiread(fName1, (/1440,6/),"float")
fil = ndtooned(fila)

pt2m = reshape(fil,(/nt/432,432/))

fil2 = asciiread(fName2,(/850,3/),"float")

print(fil2(348,:))
print(fil2(779,:))

AO = fil2(348:779,2)



printVarSummary(pt2m)
print(pt2m(0,0))
print(pt2m(0,1))

mxlag = 20

var = new((/4,mxlag+1/),float)

do i = 0, 3
	var(i,:) = esccr(pt2m(i,:),AO,20)
end do

print(var(:,0))

tm = new((/4,mxlag+1/),float)

do i = 0, 3
	tm(i,:) = ispan(0,mxlag,1)
end do

;type = "x11"
type = "png"


wks = gsn_open_wks(type,name)

res = True
res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines"/)
res@xyLineThicknesses = (/4.0,4.0,4.0,4.0/)
res@xyDashPatterns = (/0,0,1,1/)
res@xyLineColors = (/"Black","Red","Black","Red"/)

res@xyExplicitLegendLabels = (/"PC1","PC2","PC3","PC4"/)
res@pmLegendDisplayMode = "Always"
res@lgPerimOn = False
res@pmLegendWidthF = 0.10
res@pmLegendHeightF = 0.10
res@pmLegendOrthogonalPosF = 0.
res@pmLegendParallelPosF = 0.
;res@trYMaxF	= 0.5
;res@trYMinF	= -0.5
res@trXMaxF	= 19

res@vpWidthF	= 0.6
res@vpHeightF	= 0.4

plot = gsn_csm_xy(wks,tm(:,:mxlag-1),var(:,:mxlag-1),res)








end
