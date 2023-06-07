load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

name = "WARN_BAR"

zoom = True

;WEATHER = "SUM"
WEATHER = "WIN"

datacheck = True
dataname = "WARN_DATA"

; WEATHER=SUM
;cst = 23
;ced = 37
;clen = 29

;WEATHER=WIN
;cst = 5
;ced = -24
;clen = 30


dir = "~/2021-win/model/"

; type = "x11"
 type = "png"
; type = "ps"
; type = "ncgm"

t_start = 12
t_end = 36
intt = 1


if zoom then
	name = name+"_zoom"
end if

if zoom then
; ========================================= Data Processing =================================================

if WEATHER .eq. "SUM" then
    datem = (/"08","08","08","08","08","08"/)
    dated = (/"03","04","10","11","12","21"/) ; for input file name (UTC)
    dateD = (/"04","05","11","12","13","22"/) ; for plotting (KST)
	vopt = "WBGT"
else if WEATHER .eq. "WIN" then
    datem = (/"01","01","01","01","01","01"/)
    dated = (/"17","18","19","22","23","24"/) ; for input file name (UTC)
    dateD = (/"18","19","20","23","24","25"/) ; for plotting (KST)
	vopt = "WDCH"
end if
end if
name = name + "_"+WEATHER

albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(0)+"-"+dated(0)+"_03:00:00"

pathf = dir+datem(0)+dated(0)+albf
nfil = dimsizes(pathf)

a = addfile(pathf(0),"r")

; ================= for zoom ====================

llat = 37.22
llon = 126.44
rlat = 37.92
rlon = 127.35

loc = wrf_user_ll_to_ij(a,(/llon,llon,rlon,rlon/),(/llat,rlat,llat,rlat/),True) -1
indi = loc(0,:)
indj = loc(1,:)

ist = min(indi)
iend = max(indi)
jst = min(indj)
jend = max(indj)

t2 = a->T2(t_start:t_end:intt,jst:jend,ist:iend)*1. -273.15

;=========== for full Domain ======================
else

t2 = a->T2(t_start:t_end:intt,:,:)*1. -273.15
ist = 0
iend = dimsizes(t2(0,0,:))-1
jst = 0
jend = dimsizes(t2(0,:,0))-1

end if
;============ Calculating ... ====================

ny = jend - jst + 1
nx = iend - ist + 1
nt = (t_end - t_start + 1)/intt
nd = dimsizes(datem)
nfil = dimsizes(pathf)

times = wrf_user_getvar(a,"times",-1)


lat = a->XLAT(0,jst:jend,ist:iend)
lon = a->XLONG(0,jst:jend,ist:iend)

varbox = new((/nd,nfil,nt,ny,nx/),float)

do jj = 0, nd -1
	albf = "/alb0."+tostring(ispan(1,9,1))+"/wrfout_d03_2016-"+datem(jj)+"-"+dated(jj)+"_03:00:00"
	pathf = dir+datem(jj)+dated(jj)+albf

	do ii = 0, nfil -1
		a1 = addfile(pathf(ii),"r")
		if vopt .eq. "WDCH" then
        T = a1->T2(t_start:t_end,jst:jend,ist:iend) - 273.15 ;deg
        V = (a1->U10(t_start:t_end,jst:jend,ist:iend)^2.+a1->V10(t_start:t_end,jst:jend,ist:iend)^2.)^0.5*3.6 ;km/h
        do k = 0, nt -1
            do j = 0, ny -1
                do i = 0, nx -1
                    Te = T(k,j,i)
                    Ve = V(k,j,i)
                    if Te .le. 10. .and. Ve .ge. 4.8 then
                        varbox(jj,ii,k,j,i) = 13.12+0.6215*Te-11.37*Ve^0.16+0.3965*Ve^0.16*Te
                    else
                        varbox(jj,ii,k,j,i) = Te
                    end if
                end do
            end do
        end do
		else if vopt .eq. "WBGT" then
        Ta = a1->T2(t_start:t_end,jst:jend,ist:iend) - 273.15
        RH = wrf_rh(a1->Q2(t_start:t_end,jst:jend,ist:iend),a1->PSFC(t_start:t_end,jst:jend,ist:iend),Ta) / 100.
        Tw = Ta*atan(0.151977*(RH+8.313659)^0.5)+atan(Ta+RH)-atan(RH-1.676331)+0.00391838*RH^1.5*atan(0.023101*RH)-4.686035
        varbox(jj,ii,:,:,:) = 3.255820 + 0.553991*Tw + 0.455346*Ta - 0.002170 * Tw^2. + 0.002782*Tw*Ta
    else
        varbox(jj,ii,:,:,:) = a1->$vopt$(t_start:t_end,:,:) - 273.15
		end if
		end if
		delete([/a1/])
	end do
end do

sb = asciiread("Seoul_Boundary.prn",(/647,2/),"float")
sblat = sb(:,1)
sblon = sb(:,0)
BON = gc_inout(lat,lon,sblat,sblon)

if vopt .eq. "WDCH" then
    colorscheme = (/"Red","Yellow","Green","Blue"/)
    colori = (/-15.4,-10.5,-3.2/)
else if vopt .eq. "WBGT" then
    colorscheme = (/"Blue","Green","Yellow","Orange","Red"/)
    colori = (/21,25,28,31/)
end if
end if

nc = dimsizes(colori) + 1

varcat = new((/nd,nfil,nt,nc/),float)
varcat = 0

do jj = 0, nd -1
	do ii = 0, nfil -1
		do tt = 0, nt -1
			nn = 0
			do i = 0, ny -1
				do j = 0, nx -1
					if BON(i,j) then
						nn = nn + 1
						do c = 0, nc -2
							if c .eq. 0 then
								if varbox(jj,ii,tt,i,j) .lt. colori(c) then
									varcat(jj,ii,tt,c) = varcat(jj,ii,tt,c) + 1
								end if
							else if c .eq. nc -2 then
								if varbox(jj,ii,tt,i,j) .ge. colori(c) then
									varcat(jj,ii,tt,c) = varcat(jj,ii,tt,c) + 1
								end if
							else
								if varbox(jj,ii,tt,i,j) .ge. colori(c-1) .and. varbox(jj,ii,tt,i,j) .lt. colori(c) then
									varcat(jj,ii,tt,c) = varcat(jj,ii,tt,c) + 1
								end if
							end if
							end if
						end do
					end if
				end do
			end do
		end do
	end do
end do

varcat = varcat/tofloat(nn)

;varcat11 = varcat(:,:,14,:)
varcat11 = varcat(:,:,9,:)

;varcat11 = dim_avg_n(varcat,2)
varcat1 = dim_avg_n(varcat11,0)

varcat2 = varcat1

dummy = new(nfil,float)
dummy = 0

do ii = 0, nc -1
	dummy = dummy + varcat1(:,ii)
	varcat2(:,ii) = dummy
end do

if datacheck then
setfileoption("nc","Format","LargeFile")
filo = dataname+"_"+vopt+".nc"
system("/bin/rm -f "+filo)
fout = addfile(filo,"c")
fout->$vopt$ = varcat
end if


print(lat(0,0))
print(lon(0,0))
print(lat(ny-1,nx-1))
print(lon(ny-1,nx-1))
print(max(varbox))
print(min(varbox))

print("time (UTC) : "+times(t_start))
print("time (UTC) : "+times(t_end))

 x_start = 0  ;smaller
 x_end   = nx-1  ;smaller
 y_start = 0  ;smaller
 y_end   = ny-1  ;smaller


;==================== Plotting Section ==============================


;  gsn_define_colormap(wks,colorb)

res							= True
res@gsnDraw					= False
res@gsnFrame				= False
res@gsnXYBarChart			= True
res@tmXTOn					= False
res@tmYROn					= False


res@trYMinF					= 0.0
res@trYMaxF					= 1.0 * 1.2
res@trXMinF					= 0.0
res@trXMaxF					= nfil + 1
res@tmXBMode				= "Explicit"
res@tmXBValues				= fspan(1,9,9)
res@tmXBLabels				= fspan(0.1,0.9,9)
res@tiXAxisString			= "roof albedo"


nameb = name

dum = new((/nfil,nc/),graphic)
wks = gsn_open_wks(type,name)
plot = gsn_csm_blank_plot(wks,res)
bres = True

print(varcat2)

do jj = 0, nfil -1
	nj = jj + 1
  name = nameb
;  name = name+"_"+datem(kk)+dateD(kk)+"_alb0."+tostring(jj+1)+"_"+sprinti("%0.2i",ii)+"LST"
	do cc = 0, nc -1
		if cc .eq. 0 then
			ybar = (/0,varcat2(jj,cc),varcat2(jj,cc),0,0/)
			xbar = (/nj-0.25,nj-0.25,nj+0.25,nj+0.25,nj-0.25/)
		else
			ybar = (/varcat2(jj,cc-1),varcat2(jj,cc),varcat2(jj,cc),varcat2(jj,cc-1),varcat2(jj,cc-1)/)
			xbar = (/nj-0.25,nj-0.25,nj+0.25,nj+0.25,nj-0.25/)
		end if
		bres@gsFillColor = colorscheme(cc)
		dum(jj,cc) = gsn_add_polygon(wks,plot,xbar,ybar,bres)
	end do

;  res_m@tiMainString = datem(kk)+dateD(kk)+" "+sprinti("%0.2i",ii)+" LST(alb 0."+tostring(jj+1)+")"
end do

draw(plot)
frame(wks)

end
