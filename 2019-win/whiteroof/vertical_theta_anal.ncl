begin

za = ispan(0,2000,50)
dimz = dimsizes(za)
diur = 24

targ = 22

print(za(targ))

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"tmtheta.nc","r")

zturn = new(24,float)
zind = new(24,integer)

tmtheta = a1->tmtheta

printVarSummary(tmtheta)

;tt = dim_avg_n(tmtheta(:,12,:targ),(/1/))
;print(tt(1) - tt(0))

do ii = 0, 24 -1
	tt2 = tmtheta(:,ii,:)
	targtemp = tt2(1,:)-tt2(0,:)
	print(ii)
	print(targtemp)
	do j = 0, dimz -2
		if .not. ismissing(targtemp(j)) .and. .not. ismissing(targtemp(j+1)) then
		if targtemp(j)*targtemp(j+1).lt.0.05 then
			zturn(ii) = za(j)
			zind(ii) = j
			break
		end if
		end if
	end do
end do

print(zturn)

print(zind(15))

tt = dim_avg_n(tmtheta(:,15,:zind(15)),1)
print(tt(1) - tt(0))

end
