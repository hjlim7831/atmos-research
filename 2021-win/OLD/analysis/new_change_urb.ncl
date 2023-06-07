load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions

begin

diro = "./model/0821/met_em_nourb/" ;change!
pr = "ls "+diro+"*.nc"
;print(pr)
myFiles = systemfunc(pr)
print(myFiles)

filsiz = dimsizes(myFiles)

dom3 = myFiles(filsiz-1)
dom2 = myFiles(filsiz-2)
dom1 = myFiles(filsiz-3)

f1 = addfile(dom1,"w")
f2 = addfile(dom2,"w")
f3 = addfile(dom3,"w")

LON3 = f3->XLONG_C
LAT3 = f3->XLAT_C

maxlon3 = max(LON3)
minlon3 = min(LON3)
maxlat3 = max(LAT3)
minlat3 = min(LAT3)

lat_com = (/maxlat3,maxlat3,minlat3,minlat3/)
lon_com = (/maxlon3,minlon3,maxlon3,minlon3/)

opt = True
loc_bon1 = wrf_user_ll_to_ij(f1,lon_com,lat_com,opt) -1
loc_bon2 = wrf_user_ll_to_ij(f2,lon_com,lat_com,opt) -1

print(loc_bon1)

do i = 0, filsiz -1

fout = addfile(myFiles(i),"w")
lu_ind = fout->LU_INDEX
landuse = fout->LANDUSEF
dimx = dimsizes(lu_ind(0,0,:))
dimy = dimsizes(lu_ind(0,:,0))

if (i.le.filsiz-3) then ;domain 1
	maxi = max(loc_bon1(0,:))
	mini = min(loc_bon1(0,:))
	maxj = max(loc_bon1(1,:))
	minj = min(loc_bon1(1,:))

else if (i.eq.filsiz-2) then ; domain 2
	maxi = max(loc_bon2(0,:))
	mini = min(loc_bon2(0,:))
	maxj = max(loc_bon2(1,:))
	minj = min(loc_bon2(1,:))

else if (i.eq.filsiz-1) then ; domain 3
	maxi = dimx -1
	mini = 0
	maxj = dimy -1
	minj = 0

end if
end if
end if

landuse(0,30:,minj:maxj,mini:maxi) = 0.
landuse(0,12,minj:maxj,mini:maxi) = 0.

do j = minj, maxj
	do k = mini,maxi
		if (lu_ind(0,j,k) .eq. 13 .or. lu_ind(0,j,k) .gt. 30) then
			lu_ind(0,j,k) = 12
		end if
	end do
end do

fout->LU_INDEX = lu_ind
fout->LANDUSEF = landuse

delete([/fout,lu_ind,landuse,dimx,dimy,maxi,mini,maxj,minj/])

end do

end
