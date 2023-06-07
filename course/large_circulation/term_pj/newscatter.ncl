load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"  ; Add special wrf functions
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

;==================for U wind ====================

diro1 = "./Data/"
filo1 = "u.mon.7918.nc"  ; 1979 ~ 2018

a = addfile(diro1+filo1,"r")
 u = a->U(:,15,6:60-12,:) ; 60 -> 0 degree, "1" -> 1.5 degree

dimt = dimsizes(u(:,0,0))
dimy = dimsizes(u(0,:,0))
dimx = dimsizes(u(0,0,:))


 printVarSummary(u)

;;; case 1: winter, 1995 - 2013

ts = (1995-1979)*12
te = (2014-1979)*12-1

u1 = new((/4,dimy,dimx/),float,-999)
u1 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u1(0,:,:) = u1(0,:,:) + u(j,:,:)
        u1(1,:,:) = u1(1,:,:) + u(j+3,:,:)
        u1(2,:,:) = u1(2,:,:) + u(j+6,:,:)
        u1(3,:,:) = u1(3,:,:) + u(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u1 = u1 / tofloat(n)


;;; case 2: winter, 1981 - 2010

ts = (1981-1979)*12
te = (2011-1979)*12-1

u2 = new((/4,dimy,dimx/),float,-999)
u2 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u2(0,:,:) = u2(0,:,:) + u(j,:,:)
        u2(1,:,:) = u2(1,:,:) + u(j+3,:,:)
        u2(2,:,:) = u2(2,:,:) + u(j+6,:,:)
        u2(3,:,:) = u2(3,:,:) + u(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u2 = u2 / tofloat(n)
ud = u1 - u2

;========special for u2


jet = new((/4,dimy*dimx/),float,-999)
jets = new((/4,dimy*dimx/),float,-999)

jet1 = ndtooned(abs(u2(0,:,:)))
jet2 = ndtooned(abs(u2(1,:,:)))
jet3 = ndtooned(abs(u2(2,:,:)))
jet4 = ndtooned(abs(u2(3,:,:)))

qsort(jet1)
qsort(jet2)
qsort(jet3)
qsort(jet4)

thres = new(4,float,-999)

thres(0) = jet1(dimy*dimx/10*9)
thres(1) = jet2(dimy*dimx/10*9)
thres(2) = jet3(dimy*dimx/10*9)
thres(3) = jet4(dimy*dimx/10*9)

print(thres)

ust = new((/4,dimy,dimx/),float,-999)
ust = 0
do k = 0, 3
	do j = 0, dimy -1
		do i = 0, dimx -1
			if thres(k) .le. u2(k,j,i) then
				ust(k,j,i) = 1
			end if
		end do
	end do
end do


delete([/a,u,u1,u2/])

;=================== for V wind ==================

diro1 = "./Data/"
filo1 = "v.mon.7918.nc"  ; 1979 ~ 2018

a = addfile(diro1+filo1,"r")
 u = a->V(:,15,6:60-12,:) ; 60 -> 0 degree, "1" -> 1.5 degree

; u = dim_sum_n(uu,1)

dimt = dimsizes(u(:,0,0))
dimy = dimsizes(u(0,:,0))
dimx = dimsizes(u(0,0,:))


 printVarSummary(u)

;;; case 1: winter, 1995 - 2013

ts = (1995-1979)*12
te = (2014-1979)*12-1

u1 = new((/4,dimy,dimx/),float,-999)
u1 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u1(0,:,:) = u1(0,:,:) + u(j,:,:)
        u1(1,:,:) = u1(1,:,:) + u(j+3,:,:)
        u1(2,:,:) = u1(2,:,:) + u(j+6,:,:)
        u1(3,:,:) = u1(3,:,:) + u(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u1 = u1 / tofloat(n)

;;; case 2: winter, 1981 - 2010

ts = (1981-1979)*12
te = (2011-1979)*12-1

u2 = new((/4,dimy,dimx/),float,-999)
u2 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u2(0,:,:) = u2(0,:,:) + u(j,:,:)
        u2(1,:,:) = u2(1,:,:) + u(j+3,:,:)
        u2(2,:,:) = u2(2,:,:) + u(j+6,:,:)
        u2(3,:,:) = u2(3,:,:) + u(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u2 = u2 / tofloat(n)

vd = u1 - u2

delete([/a,u,u1,u2/])


; ==========================for 1000-500 hPa thickness ========

diro1 = "./Data/"
filo1 = "z.mon.7918.nc"  ; 1979 ~ 2018

a = addfile(diro1+filo1,"r")
 u = a->Z(:,15,6:60-12,:) ; 60 -> 0 degree, "1" -> 1.5 degree
 zz = a->Z(:,15,5:60-12,:)
; u = dim_sum_n(uu,1)

dimt = dimsizes(u(:,0,0))
dimy = dimsizes(u(0,:,0))
dimx = dimsizes(u(0,0,:))
dimy2 = dimsizes(zz(0,:,0))

 printVarSummary(u)

;;; case 1: winter, 1995 - 2013

ts = (1995-1979)*12
te = (2014-1979)*12-1

u1 = new((/4,dimy,dimx/),float,-999)
z1 = new((/4,dimy2,dimx/),float,-999)
u1 = 0
z1 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u1(0,:,:) = u1(0,:,:) + u(j,:,:)
        u1(1,:,:) = u1(1,:,:) + u(j+3,:,:)
        u1(2,:,:) = u1(2,:,:) + u(j+6,:,:)
        u1(3,:,:) = u1(3,:,:) + u(j+9,:,:)
        z1(0,:,:) = z1(0,:,:) + zz(j,:,:)
        z1(1,:,:) = z1(1,:,:) + zz(j+3,:,:)
        z1(2,:,:) = z1(2,:,:) + zz(j+6,:,:)
        z1(3,:,:) = z1(3,:,:) + zz(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u1 = u1 / tofloat(n)
z1 = z1 / tofloat(n)
		


;;; case 2: winter, 1981 - 2010

ts = (1981-1979)*12
te = (2011-1979)*12-1

u2 = new((/4,dimy,dimx/),float,-999)
u2 = 0
z2 = new((/4,dimy2,dimx/),float,-999)
z2 = 0
n = 0
do i = 0, 2
    do j = ts+i, te, 12
        u2(0,:,:) = u2(0,:,:) + u(j,:,:)
        u2(1,:,:) = u2(1,:,:) + u(j+3,:,:)
        u2(2,:,:) = u2(2,:,:) + u(j+6,:,:)
        u2(3,:,:) = u2(3,:,:) + u(j+9,:,:)
        z2(0,:,:) = z2(0,:,:) + zz(j,:,:)
        z2(1,:,:) = z2(1,:,:) + zz(j+3,:,:)
        z2(2,:,:) = z2(2,:,:) + zz(j+6,:,:)
        z2(3,:,:) = z2(3,:,:) + zz(j+9,:,:)
        n = n + 1
    end do
end do
print(n)
u2 = u2 / tofloat(n)
z2 = z2 / tofloat(n)

zd = (u1 - u2)/9.8
zd2 = (z1 - z2)/9.8

thd = (zd2(:,1:,:) - zd2(:,:dimy2-2,:))/1.5


delete([/a,u,u1,u2/])

;========== Data input for MCI =================

diro1 = "./Data/"
filo1 = "u500.day.7918.nc"
filo2 = "v500.day.7918.nc"

a1 = addfile(diro1+filo1,"r")
a2 = addfile(diro1+filo2,"r")

u = a1->U(:,:,6:60-12,:)
v = a2->V(:,:,6:60-12,:)

;=========  Calculating MCI ==============

dimt = dimsizes(u(:,0,0,0))
dimy = dimsizes(u(0,0,:,0))
dimx = dimsizes(u(0,0,0,:))

v_bar = dim_avg_n(v,2)
MCI = new((/dimt,dimy,dimx/),float)

do i = 0, dimy -1
    print(i)
    MCI(:,i,:) = (v(:,0,i,:) - v_bar(:,0,:)) * abs(v(:,0,i,:))/(u(:,0,i,:)^2+v(:,0,i,:)^2)
end do

;printVarSummary(u)

;======== Separating MCI ==============

;-------- Calculate Date -------------

tst = 1979

yearl = 2018 - 1979 + 1
ly = new(yearl,integer) ; if ly = 1, total days in a year : 366

ly = 0

do i = 0, yearl -1
    year = i + 1979
    if mod(year,4) .eq. 0 then
        ly(i) = 1
    end if
end do

do i = 0, yearl -1
    year = i + 1979
    if mod(year,100) .eq. 0 then
        ly(i) = 0
    end if
end do

do i = 0, yearl -1
    year = i + 1979
    if mod(year,400) .eq. 0 then
        ly(i) = 1
    end if
end do

print(ly)

;;case 1: 1995 - 2013

start_year1 = 1995
end_year1 = 2013

ist1 = 0
do i = 0, start_year1 - tst -1
    year = i + tst
    if ly(i) .eq. 1 then
        ist1 = ist1 + 366
    else
        ist1 = ist1 + 365
    end if
end do

iend1 = 0
do i = 0, end_year1 - tst -1
    year = i + tst
    if ly(i) .eq. 1 then
        iend1 = iend1 + 366
    else
        iend1 = iend1 + 365
    end if
end do


MCI1 = new((/4,dimy,dimx/),float,-999)
MCI2 = new((/4,dimy,dimx/),float,-999)
MCI1 = 0
MCI2 = 0

nn = new(4,integer)
nn = 0

ii = ist1
do i = start_year1 - tst, end_year1 - tst
    year = i + tst
    if ly(i) .eq. 1 then
    MCI1(0,:,:) = MCI1(0,:,:) + dim_sum_n(MCI(ii:ii+31+29+31-1,:,:),0)
    MCI1(1,:,:) = MCI1(1,:,:) + dim_sum_n(MCI(ii+91:ii+91+30+31+30-1,:,:),0)
    MCI1(2,:,:) = MCI1(2,:,:) + dim_sum_n(MCI(ii+182:ii+182+31+31+30-1,:,:),0)
    MCI1(3,:,:) = MCI1(3,:,:) + dim_sum_n(MCI(ii+274:ii+274+31+30+31-1,:,:),0)
    ii = ii + 366
    nn(0) = nn(0) + 31+29+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
    else
    MCI1(0,:,:) = MCI1(0,:,:) + dim_sum_n(MCI(ii:ii+31+28+31-1,:,:),0)
    MCI1(1,:,:) = MCI1(1,:,:) + dim_sum_n(MCI(ii+90:ii+90+30+31+30-1,:,:),0)
    MCI1(2,:,:) = MCI1(2,:,:) + dim_sum_n(MCI(ii+181:ii+181+31+31+30-1,:,:),0)
    MCI1(3,:,:) = MCI1(3,:,:) + dim_sum_n(MCI(ii+273:ii+273+31+30+31-1,:,:),0)
    ii = ii + 365
    nn(0) = nn(0) + 31+28+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
    end if
end do
print(nn)

do i = 0, 3
    MCI1(i,:,:) = MCI1(i,:,:)/tofloat(nn(i))
end do


;; case 2: 1981 - 2010

start_year2 = 1981
end_year2 = 2010

ist2 = 0
do i = 0, start_year2 - tst -1
    year = i + tst
    if ly(i) .eq. 1 then
        ist2 = ist2 + 366
    else
        ist2 = ist2 + 365
    end if
end do

iend2 = 0
do i = 0, end_year2 - tst -1
    year = i + tst
    if ly(i) .eq. 1 then
        iend2 = iend2 + 366
    else
        iend2 = iend2 + 365
    end if
end do

nn = new(4,integer)
nn = 0
ii = ist2
do i = start_year2 - tst, end_year2 - tst
    year = i + tst
    if ly(i) .eq. 1 then
    MCI2(0,:,:) = MCI2(0,:,:) + dim_sum_n(MCI(ii:ii+31+29+31-1,:,:),0)
    MCI2(1,:,:) = MCI2(1,:,:) + dim_sum_n(MCI(ii+91:ii+91+30+31+30-1,:,:),0)
    MCI2(2,:,:) = MCI2(2,:,:) + dim_sum_n(MCI(ii+182:ii+182+31+31+30-1,:,:),0)
    MCI2(3,:,:) = MCI2(3,:,:) + dim_sum_n(MCI(ii+274:ii+274+31+30+31-1,:,:),0)
    ii = ii + 366
    nn(0) = nn(0) + 31+29+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
    else
    MCI2(0,:,:) = MCI2(0,:,:) + dim_sum_n(MCI(ii:ii+31+28+31-1,:,:),0)
    MCI2(1,:,:) = MCI2(1,:,:) + dim_sum_n(MCI(ii+90:ii+90+30+31+30-1,:,:),0)
    MCI2(2,:,:) = MCI2(2,:,:) + dim_sum_n(MCI(ii+181:ii+181+31+31+30-1,:,:),0)
    MCI2(3,:,:) = MCI2(3,:,:) + dim_sum_n(MCI(ii+273:ii+273+31+30+31-1,:,:),0)
    ii = ii + 365
    nn(0) = nn(0) + 31+28+31
    nn(1) = nn(1) + 30+31+30
    nn(2) = nn(2) + 31+31+30
    nn(3) = nn(3) + 31+30+31
    end if
    print(ii)
end do

do i = 0, 3
    MCI2(i,:,:) = MCI2(i,:,:)/tofloat(nn(i))
end do

MCId = abs(MCI1) - abs(MCI2)

printVarSummary(ud)
printVarSummary(vd)
printVarSummary(zd)
printVarSummary(MCId)

; ======== thres, highest 10% ==========================

; ust

udst = new((/4,dimx*dimy/),float,-999)
vdst = new((/4,dimx*dimy/),float,-999)
zdst = new((/4,dimx*dimy/),float,-999)
MCIdst = new((/4,dimx*dimy/),float,-999)
thdst = new((/4,dimx*dimy/),float,-999)

do k = 0, 3
	n = 0
	do j = 0, dimy -1
		do i = 0, dimx -1
			if ust(k,j,i) .eq. 1 then
				udst(k,n) = ud(k,j,i)
				vdst(k,n) = vd(k,j,i)
				zdst(k,n) = zd(k,j,i)
				thdst(k,n) = thd(k,j,i)
				MCIdst(k,n) = MCId(k,j,i)
				n = n + 1
			end if
		end do
	end do
end do



ud_t = new((/2,4,dimx*dimy/),float,-999)
vd_t = new((/2,4,dimx*dimy/),float,-999)
zd_t = new((/2,4,dimx*dimy/),float,-999)
MCId_t = new((/2,4,dimx*dimy/),float,-999)
thd_t = new((/2,4,dimx*dimy/),float,-999)

do i = 0, 3
	ud_t(0,i,:) = ndtooned(ud(i,:,:))
	vd_t(0,i,:) = ndtooned(vd(i,:,:))
	zd_t(0,i,:) = ndtooned(zd(i,:,:))
	MCId_t(0,i,:) = ndtooned(MCId(i,:,:))
	thd_t(0,i,:) = ndtooned(thd(i,:,:))
end do

ud_t(1,:,:) = udst
vd_t(1,:,:) = vdst
zd_t(1,:,:) = zdst
MCId_t(1,:,:) = MCIdst
thd_t(1,:,:) = thdst


;====================== plotting =============

;type = "x11"
type = "png"
wks = gsn_open_wks(type,"newSCATTER")

res = True

res@gsnFrame    = False
res@gsnDraw     = False
;res@vpWidthF    = 0.8
;res@vpHeightF   = 0.6
res@xyMarkLineModes = (/"Markers","Markers"/)
res@xyMarkerSizeF  = (/0.025,0.025/)
res@xyMarkers 	   = (/1,1/)
res@tiMainFontHeightF = 0.035

plot = new((/16/),graphic)

season = (/" JFM"," AMJ"," JAS"," OND"/)


do i = 0, 3

; 1
x = ud_t(:,i,:)
y = thd_t(:,i,:)
res@tiMainString = "U500 vs. Thickness gradient" + season(i)
res@trXMaxF      =  3.0
res@trXMinF      = -3.0
res@trYMaxF		 =  3.0
res@trYMinF		 = -3.0
res@tiXAxisString= "U500 Wind Change"
res@tiYAxisString= "1000-500hPa Thickness change"
res@xyMarkerColors= (/"Blue","Black"/)

plot(4*i+0) = gsn_csm_xy(wks,x,y,res)


; 2
x = ud_t(:,i,:)
y = MCId_t(:,i,:)
res@tiMainString = "U500 vs. abs(MCI)" + season(i)
res@trXMaxF		 =  3.0
res@trXMinF		 = -3.0
res@trYMaxF      =  0.1
res@trYMinF      = -0.1
res@tiXAxisString= "U500 Wind Change"
res@tiYAxisString= "abs(MCI)"
res@xyMarkerColors= (/"Green","Black"/)

plot(4*i+1) = gsn_csm_xy(wks,x,y,res)


; 3
x = vd_t(:,i,:)
y = MCId_t(:,i,:)
res@tiMainString = "V500 vs. abs(MCI)" + season(i)
res@trXMaxF      =  2.0
res@trXMinF      = -2.0
res@tiXAxisString= "V500 Wind Change"
res@tiYAxisString= "abs(MCI)"
res@xyMarkerColors= (/"cyan","Black"/)

plot(4*i+2) = gsn_csm_xy(wks,x,y,res)


; 4
x = thd_t(:,i,:)
y = MCId_t(:,i,:)
res@tiMainString = "Thickness gradient vs. abs(MCI)" + season(i)
res@trXMaxF      =  3.0
res@trXMinF      = -3.0
res@tiXAxisString= "1000-500hPa Thickness change"
res@tiYAxisString= "abs(MCI)"
res@xyMarkerColors= (/"Red","Black"/)

plot(4*i+3) = gsn_csm_xy(wks,x,y,res)



end do

pnlres = True
pnlres@vpWidthF = 1.4
pnlres@vpHeightF = 1.4
pnlres@gsnPanelBottom = 0.2
gsn_panel(wks,(/plot/),(/4,4/),pnlres)



end

