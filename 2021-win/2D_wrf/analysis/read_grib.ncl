
begin

diri1 = "~/archive/ERA5_data/oldGRIB_whole/"
diri2 = "~/archive/ERA5_data/boxGRIB/70-80-0-170_0714-0820/"
diro= "~/2021-win/2D_wrf/picture/"

name = "READ_GRIB"

f1 = addfile(diri1+"1h_ERA5-20180801-pl.grib","r")
f2 = addfile(diri1+"1h_ERA5-20180802-pl.grib","r")
f3 = addfile(diri2+"1h_ERA5_20180714-20180820-sfc.grib","r")

varname1 = getfilevarnames(f1)
varname2 = getfilevarnames(f3)
vardim = getfiledimsizes(f1)
;print(varname1)

type = "x11"
;type = "png"

Slat = 37.5
Slon = 127


gridd = 0.25

jst = 40*4
jed = 60*4
ist = 120*4
ied = 140*4

jst2 = 20*4
jed2 = 40*4
ist2 = 40*4
ied2 = 60*4

tst2 = 24*18
ted2 = 24*20-1

lst18 = 9+18


lat1 = f1->g0_lat_2
lon1 = f1->g0_lon_3

lat2 = f3->g0_lat_1
lon2 = f3->g0_lon_2

siy1 = ind(lat1.eq.Slat)
six1 = ind(lon1.eq.Slon)

siy2 = ind(lat2.eq.Slat)
six2 = ind(lon2.eq.Slon)

Z1 = f1->Z_GDS0_ISBL(:,:,siy1,six1)
T1 = f1->T_GDS0_ISBL(:,:,siy1,six1)
R1 = f1->R_GDS0_ISBL(:,:,siy1,six1)

Z2 = f2->Z_GDS0_ISBL(:,:,siy1,six1)
T2 = f2->T_GDS0_ISBL(:,:,siy1,six1)
R2 = f2->R_GDS0_ISBL(:,:,siy1,six1)

Z = array_append_record(Z1,Z2,0)
T = array_append_record(T1,T2,0)
R = array_append_record(R1,R2,0)

delete([/Z1,Z2,T1,T2,R1,R2/])

SKT = f3->SKT_GDS0_SFC(tst2:ted2,siy2,six2)
STL1 = f3->STL1_GDS0_DBLY(tst2:ted2,siy2,six2)
STL2 = f3->STL2_GDS0_DBLY(tst2:ted2,siy2,six2)
STL3 = f3->STL3_GDS0_DBLY(tst2:ted2,siy2,six2)
STL4 = f3->STL4_GDS0_DBLY(tst2:ted2,siy2,six2)
SST = f3->SSTK_GDS0_SFC(tst2:ted2,:,:)

print(Z(lst18,:))
print(T(lst18,:))
print(R(lst18,:))
print(SKT(lst18))
print(STL1(lst18))
print(STL2(lst18))
print(STL3(lst18))
print(STL4(lst18))


res					= True
res@gsnAddCyclic	= False
res@mpMaxLonF		= 130
res@mpMinLonF		= 120
res@mpMaxLatF		= 40
res@mpMinLatF		= 35
res@cnLinesOn		= False
res@cnFillOn		= True

wks = gsn_open_wks(type,diro+name)


plot = gsn_csm_contour_map(wks,SST(0,:,:),res)


end
