begin

diri ="~/2021-win/2D_wrf/model/test/test7_sound/"
diro= "~/2021-win/2D_wrf/picture/"
name = "TEST_SOUND"

type = "x11"
;type = "png"


lis = systemfunc("ls "+diri)
print(lis)

nx = dimsizes(lis)

a = addfiles(diri+lis,"r")

ListSetType (a, "join")

tt = a[:]->TSK(:,3,0,:) - 273.15

printVarSummary(tt)


wks = gsn_open_wks(type,diro+name)

res										= True
res@gsnFrame							= False
res@gsnDraw								= False
;res@trXMaxF								= 21
;res@trXMinF								= 15
res@trYMaxF								= 35
res@trYMinF								= 21
res@xyMarkLineModes						= "Lines"

plot = new(nx,graphic)

xx = ispan(-200,199,1)

COLOR = (/"Green","Blue","Purple","Yellow","Orange","Red"/)

do ii = 0, nx -1
	var = tt(ii,:)
	res@xyLineColors = COLOR(ii)
	plot(ii) = gsn_csm_xy(wks,xx,var,res)
	draw(plot(ii))

end do

frame(wks)


end
