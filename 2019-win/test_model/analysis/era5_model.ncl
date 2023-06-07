begin

diro = "~/2019-win/test_model/"
fil1 = "analysis/1h_ERA5_20180714-20180820-sfanal.nc"
fil2 = "analysis/z3_a2wrf"

a1 = addfile(diro+fil1,"r")
a2 = addfile(diro+fil2,"r")


erpbl = a1->blh
erlh = a1->mslhf
ersh = a1->ishf

ofs = erpbl@add_offset
sf = erpbl@scale_factor

epbl = (erpbl*sf)+ofs

ofs = erlh@add_offset
sf = erlh@scale_factor

elh = -( (erlh*sf)+ofs )

ofs = ersh@add_offset
sf = ersh@scale_factor

esh = -( (ersh*sf)+ofs )


mpbl = a2->PBLH(3:890,:,:)
mlh = a2->LH(3:890,:,:)
msh = a2->HFX(3:890,:,:)

printVarSummary(epbl)
printVarSummary(mpbl)

elat = erpbl&latitude
elon = erpbl&longitude

mlat = a2->XLAT(0,:,:)
mlon = a2->XLONG(0,:,:)

;print(mlat)
;print(mlon)

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

BON = gc_inout(mlat,mlon,sblat,sblon)

;print(max(sblat))
;print(min(sblat))
;print(max(sblon))
;print(min(sblon))

slat = 37.5
slon = 127

lai = ind(elat.eq.slat)
loi = ind(elon.eq.slon)
print(lai)
print(loi)

etpbl = epbl(15:911-9,lai,loi)
etlh = elh(15:911-9,lai,loi)
etsh = esh(15:911-9,lai,loi)
printVarSummary(etpbl)

d1 = dimsizes(mlat(:,0))
d2 = dimsizes(mlat(0,:))

mtpbl = new(888,float)
mtlh = new(888,float)
mtsh = new(888,float)
mtpbl = 0.
mtlh = 0.
mtsh = 0.
n = 0

do i = 0, d1 -1
	do j = 0, d2 -1
		if BON(i,j) then
			mtpbl = mtpbl + mpbl(:,i,j)
			mtlh = mtlh + mlh(:,i,j)
			mtsh = mtsh + msh(:,i,j)
			n = n + 1
		end if
	end do
end do

mtpbl = mtpbl/tofloat(n)
mtlh = mtlh/tofloat(n)
mtsh = mtsh/tofloat(n)

;print(etpbl)
;print(mtpbl)

setfileoption("nc","Format","LargeFile")
filo = "analysis/diff_era_model.nc"
system("/bin/rm -rf "+diro+filo)
fout = addfile(diro+filo,"c")
fout->etpbl = etpbl
fout->etlh = etlh
fout->etsh = etsh
fout->mtpbl = mtpbl
fout->mtlh = mtlh
fout->mtsh = mtsh



















end
