begin

a = addfile("simple.nc","r")
;print(a)

T = a->avgT -273.15

d1 = dimsizes(T)

nn = d1/12

yrT = new(nn,float)
yrT2 = new(nn,float)
diffT = new(nn-1,float)

do i = 0, nn -1
	yrT(i) = avg(T(12*i:12*i+11))
end do

do i = 0, nn -1
	yrT2(i) = avg(T(12*i+6:12*i+17))
end do

do i = 0, nn -2
	diffT(i) = yrT2(i+1)-yrT2(i)
end do

;type = "x11"
type = "png"

wks = gsn_open_wks(type,"strat")

TIME = ispan(1,486,1)

res = True
res@vpWidthF			= 0.6
res@vpHeightF			= 0.2
res@xyLineThicknessF	= 1.5


res1 = res

res1@tmXBmode = "Explicit"
res1@tmXBValues = ispan(1,486,12)
res1@tmXBLabels = ispan(1979,2019,1)

plot1 = gsn_csm_xy(wks,TIME,T,res1)


wks2 = gsn_open_wks(type,"strat2")

TIME2 = ispan(1979,2018,1)

plot2 = gsn_csm_xy(wks2,TIME2,yrT,res)


wks3 = gsn_open_wks(type,"strat3")

TIME3 = ispan(1980,2018,1)

plot3 = gsn_csm_xy(wks3,TIME3,diffT,res)




end
