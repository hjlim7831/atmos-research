begin

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"e2wrfout_d03_2018-07-14_12:00:00","r")

LAT = a1->XLAT(0,:,:)
LON = a1->XLONG(0,:,:)

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

aBON = gc_inout(LAT,LON,sblat,sblon)

d1 = dimsizes(aBON(:,0))
d2 = dimsizes(aBON(0,:))
BON = new((/d1,d2/),integer)

do i = 0, d1-1
	do j = 0, d2-1
		if aBON(i,j) then
			BON(i,j) = 1
		else
			BON(i,j) = 0
		end if
	end do
end do

printVarSummary(BON)

setfileoption("nc","Format","LargeFile")
filo = "bon_seoul.nc"
system("/bin/rm -f "+diro+filo)
fout = addfile(diro+filo, "c")
fout->BON = BON
fout->XLAT = LAT
fout->XLONG = LON






end
