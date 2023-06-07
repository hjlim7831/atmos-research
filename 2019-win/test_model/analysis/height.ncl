load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

 dir = "~/2019-win/test_model/"
 fileA  = "analysis/z3_a2wrf" ; change here!
 a1 = addfile(dir+fileA,"r")

z =  wrf_user_getvar(a1,"z",0)
;z1 = wrf_user_getvar(a1,"z",1)

d1 = dimsizes(z(:,0,0))
d2 = dimsizes(z(0,:,0))
d3 = dimsizes(z(0,0,:))

printVarSummary(z)

do i = 0, d1-1
	print(i+1)
	print(avg(z(i,:,:)))
end do





end





