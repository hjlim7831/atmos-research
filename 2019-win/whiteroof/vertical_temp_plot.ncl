begin

diro = "~/2019-win/whiteroof/"
a1 = addfile(diro+"e2wrfout_d03_2018-07-14_12:00:00","r")
a2 = addfile(diro+"temp_z_interp.nc","r")

tstart = 3
tend = 890
intt = 1
dimt = (tend-tstart+1)/intt
diur = 24
tm = fspan(0,diur-1,diur)

ist = 30
iend = 100
jst = 55
jend = 110

LAT = a1->XLAT(0,jst:jend,ist:iend)
LON = a1->XLONG(0,jst:jend,ist:iend)
lui = a1->LU_INDEX(0,jst:jend,ist:iend)

za = ispan(0,2000,50)
dimz = dimsizes(za)

dimj = jend - jst + 1
dimi = iend - ist + 1

th2 = a2->th2
th7 = a2->th7

printVarSummary(th2)
printVarSummary(th7)

ttheta = new((/2,dimt,dimz/),float)
ttheta = 0.

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)

BON = gc_inout(LAT,LON,sblat,sblon)


nn = new((/2,dimt,dimz/),integer)

nn = 0
do j = 0, dimj -1
	do k = 0, dimi -1
		if (lui(j,k) .eq. 13 .or. lui(j,k) .gt. 30) .and. BON(j,k) then
			do tt = 0, dimt -1
				do zz = 0, dimz -1
					if .not. ismissing(th7(tt,zz,j,k)) then
						ttheta(0,tt,zz) = ttheta(0,tt,zz) + th7(tt,zz,j,k)
						nn(0,tt,zz) = nn(0,tt,zz) + 1
					end if
				end do
			end do
		end if
	end do
end do

do j = 0, dimj -1
    do k = 0, dimi -1
        if (lui(j,k) .eq. 13 .or. lui(j,k) .gt. 30) .and. BON(j,k) then
            do tt = 0, dimt -1
                do zz = 0, dimz -1
                    if .not. ismissing(th2(tt,zz,j,k)) then
                        ttheta(1,tt,zz) = ttheta(1,tt,zz) + th2(tt,zz,j,k)
                        nn(1,tt,zz) = nn(1,tt,zz) + 1
                    end if
                end do
            end do
        end if
    end do
end do

do tt = 0, dimt -1
	do zz = 0, dimz -1
		if .not. nn(0,tt,zz) .eq. 0 then
		ttheta(0,tt,zz) = ttheta(0,tt,zz)/tofloat(nn(0,tt,zz))
		else
		ttheta(0,tt,zz) = 9.96921e+36
		end if
	end do
end do

do tt = 0, dimt -1
    do zz = 0, dimz -1
        if .not. nn(1,tt,zz) .eq. 0 then
        ttheta(1,tt,zz) = ttheta(1,tt,zz)/tofloat(nn(1,tt,zz))
		else
		ttheta(1,tt,zz) = 9.96921e+36
		end if
    end do
end do

nnn = dim_sum_n(nn,1)
;print(nnn)


;print(nn)

tmtheta = new((/2,diur,dimz/),float)
tmtheta = 0.

do i = 0, diur -1
	n = 0
	do j = i, dimt -1, diur
		tmtheta(:,i,:) = tmtheta(:,i,:) + ttheta(:,j,:)
		n = n + 1
	end do
	tmtheta(:,i,:) = tmtheta(:,i,:)/tofloat(n)
end do

setfileoption("nc","Format","LargeFile")
filo = "tmtc.nc"
system("/bin/rm -f "+diro+filo)
fout = addfile(diro+filo, "c")
fout->tmtheta = tmtheta



; type = "x11"
  type = "png"
 ;type = "oldps"
 wks = gsn_open_wks(type,"Compare_vertical_diurnal_temp")

res = True
res@xyMarkLineModes = (/"Lines","Lines"/)
res@xyLineThicknesses = (/4.0,4.0/)
res@xyDashPatterns = (/0,0/)
res@xyLineColors = (/"Blue","Red"/)
res@tiMainOn		= "True"
res@tiXAxisString = "potential temperature (K)"
res@tiYAxisString = "height (m)"

res@vpHeightF	= 0.6
res@vpWidthF	= 0.3

plots = new(diur,graphic)

zbox = new((/2,dimz/),float)
zbox(0,:) = za
zbox(1,:) = za

do ii = 0, diur -1
	res@tiMainString = sprinti("%2.2i",ii) + "00 LST"
	plots(ii) = gsn_csm_xy(wks,tmtheta(:,ii,2:),zbox(:,2:),res)
end do





end
