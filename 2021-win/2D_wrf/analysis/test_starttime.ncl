begin

diri ="~/2021-win/2D_wrf/model/test/test6_stime/"
diro= "~/2021-win/2D_wrf/picture/"
name = "TEST_STTIME"

type = "x11"
;type = "png"


lis = systemfunc("ls "+diri)
print(lis)

a = addfiles(diri+lis,"r")

t15 = a[0]->TSK(:,0,:) - 273.15

ListSetType (a, "join")

tt = a[1:]->TSK(:,3,0,:) - 273.15

printVarSummary(t15)
printVarSummary(tt)

ix = (/210,230,250/)
ymax = (/40,40,40/)
ymin = (/12,8,12/)

nx = dimsizes(ix)


wks = gsn_open_wks(type,diro+name)

res										= True
res@gsnFrame							= False
res@gsnDraw								= False
res@trXMaxF								= 21
res@trXMinF								= 15
;res@trYMaxF								= 
;res@trYMinF								=


res1									= res
res1@xyMarkLineModes					= "Lines"


res2									= res
res2@xyMarkLineModes					= "Markers"


time1 = fspan(15,21,37)
time2 = ispan(16,21,1)

do ii = 0, nx -1
	iix = ix(ii)
	var15 = t15(:,iix)
	var = tt(:,iix)
	res1@trYMaxF	= ymax(ii)
	res1@trYMinF	= ymin(ii)
	res2@trYMaxF	= ymax(ii)
	res2@trYMinF	= ymin(ii)

	
	plot1 = gsn_csm_xy(wks,time1,var15,res1)
	plot2 = gsn_csm_xy(wks,time2,var,res2)
	draw(plot1)
	draw(plot2)
	frame(wks)





end do




end
