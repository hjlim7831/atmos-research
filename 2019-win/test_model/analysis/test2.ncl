begin

diro = "~/2019-win/test_model/"

a1 = addfile("tempd_seoul.nc","r")
a2 = addfile(diro+"analysis/z3_a2wrf","r")


lui = a2->LU_INDEX(0,:,:)

LAT = a2->XLAT(0,:,:)
LON = a2->XLONG(0,:,:)


sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

BON = gc_inout(LAT,LON,sblat,sblon)


tt = a1->t2box(2,12,:,:)

temp = 0.
n = 0

dimy = dimsizes(tt(:,0))
dimx = dimsizes(tt(0,:))

do i = 0, dimy -1
	do j = 0, dimx -1
		if (lui(i,j) .eq. 13 .or. lui(i,j) .gt. 30) .and. BON(i,j) then
			n = n + 1
			temp = temp + tt(i,j)
		end if
	end do
end do

print(temp/tofloat(n))







end
