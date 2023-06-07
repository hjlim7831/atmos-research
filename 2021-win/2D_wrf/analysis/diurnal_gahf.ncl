begin

diri1 = "~/2021-win/2D_wrf/analysis/"
diri2 = "~/2019-win/whiteroof/model/ERA5/wrf_out_alb0.2/"

fil1 = "gahf_d03_0714-0820_2016.nc"
fil2 = "wrfout_d03_2018-07-14_12:00:00"

a1 = addfile(diri1+fil1,"r")
a2 = addfile(diri2+fil2,"r")

day = 20

gahf = a1->GAHF(3+day*24:3+23+day*24,:,:)
printVarSummary(gahf)

LAT = a2->XLAT(0,:,:)
LON = a2->XLONG(0,:,:)
lui = a2->LU_INDEX(0,:,:)

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

BON = gc_inout(LAT,LON,sblat,sblon)

dimj = dimsizes(lui(:,0))
dimi = dimsizes(lui(0,:))

dgahf = new(24,float)
dgahf = 0.
n = 0
do j = 0, dimj -1
	do i = 0, dimi -1
		if (lui(j,i) .eq. 13 .or. lui(j,i) .gt. 30) .and. BON(j,i) then
			dgahf = dgahf + gahf(:,j,i)
			n = n + 1
		end if
	end do
end do

dgahf = dgahf/tofloat(n)

print(dgahf)






















end
