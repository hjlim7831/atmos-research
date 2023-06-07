begin

diri1 = "../results/"
diri2 = "../data/"

fili = "pct_t2m.d"

name = "t2m_month"

fName1 = diri1+fili

nt = 1224
nn = 6
fil = asciiread(fName1, (/nt/),"float")

pt2m = reshape(fil,(/nt/432,432/))

printVarSummary(pt2m)
print(pt2m(0,0))
print(pt2m(0,1))

varm = new((/4,12/),float)

do ii = 0, 3
	do j = 0, 11
		varm(ii,j) = dim_avg_n(pt2m(ii,j::12)^2.0,0)/dim_avg_n(pt2m(ii,:)^2.,0)
	end do
end do

tm = new((/4,12/),integer)
tm(0,:) = ispan(0,11,1)
tm(1,:) = ispan(0,11,1)
tm(2,:) = ispan(0,11,1)
tm(3,:) = ispan(0,11,1)
;print(tm)

;================ Plotting Section ===================
;type = "x11"
type = "png"

wks = gsn_open_wks(type,name)

res = True
res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines"/)
res@xyLineThicknesses = (/4.0,4.0,4.0,4.0/)
res@xyDashPatterns = (/0,0,0,0/)
res@xyLineColors = (/"Black","Red","Blue","Green"/)
res@tmXBMode = "Explicit"
res@tmXBValues = ispan(0,11,1)
res@tmXBLabels = (/"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"/)

res@xyExplicitLegendLabels = (/"Mode 1","Mode 2","Mode 3","Mode 4"/)
res@pmLegendDisplayMode = "Always"
res@lgPerimOn = False
res@pmLegendWidthF = 0.15
res@pmLegendHeightF = 0.10
res@pmLegendOrthogonalPosF = -1.15
res@pmLegendParallelPosF = 0.85


plot = gsn_csm_xy(wks,tm,varm,res)







end
