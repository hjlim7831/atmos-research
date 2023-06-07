load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These two libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"    ; loaded from NCL V6.4.0 onward.

begin
; ===================================== Data input =====================================
diro = "~/class/History/num_model2/"

filname = (/"yswrfout_d03_2016-08-02_12:00:00","mynnwrfout_d03_2016-08-02_12:00:00","qnsewrfout_d03_2016-08-02_12:00:00"/)

varname = (/"potential temperature (K)","wind speed (m/s)","wind direction (degree)"/)
tiname = (/"0300 LST","0900 LST","1500 LST", "2100 LST"/)

csvname = (/"osan_0803_03.csv","osan_0803_09.csv","osan_0803_15.csv","osan_0803_21.csv"/)

xmax = new((/4,2/),float)
xmin = new((/4,2/),float)

xmax(:,0) = (/312.,312.,306.,315./)
xmax(:,1) = (/5.,6.,10.,9./)
xmin(:,0) = (/298.,298.,300.,297./)
xmin(:,1) = (/0.,0.,0.,0./)

osanm = (/37.100, 127.0333/)


var4dname = (/"th","ua","va"/)

tidx = (/0, 6, 12, 18/) + 3

nfil = 3
nti = dimsizes(tidx)

; ======================================= Options ======================================

opt = True


; ================================== Calculate Variables ===============================
nz = 55
onz = 134
nvar = 3 ; 1. theta, 2. wind speed, 3. wind direction
varbox = new((/nfil,nti,nvar,nz/),float)
obbox = new((/nti,nvar,onz/),float)
obpbox = new((/nti,onz/),float)
pbox = new((/nfil,nti,nvar,nz/),float)

cp = 1005.
cv = 718.
p0 = 1000.
k = (cp-cv)/cp

do ii = 0, nfil -1
;ii = 0
a = addfile(diro+filname(ii),"r")
 do nn = 0, nti -1
;nn = 0
obsij = wrf_user_ll_to_ij(a,osanm(1),osanm(0),True) -1
obsi = obsij(0)
obsj = obsij(1)

lines = asciiread(diro+"csv/"+csvname(nn),-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)
printVarSummary(fields)

obpr = tofloat(fields(:,0)) ; hPa
obz = tofloat(fields(:,1)) ; gpm
obt = tofloat(fields(:,2)) + 273.15 ; K
obdt = tofloat(fields(:,3)) + 273.15 ; K
obwd = tofloat(fields(:,4)) ; deg
obws = tofloat(fields(:,5))*0.5144 ; m/s

obbox(nn,0,:nlines-1) = obt*(p0/obpr)^k
obbox(nn,1,:nlines-1) = obws
obbox(nn,2,:nlines-1) = obwd
obpbox(nn,:nlines-1) = obpr

ua = wrf_user_getvar(a,"ua",tidx(nn))
va = wrf_user_getvar(a,"va",tidx(nn))
tk = wrf_user_getvar(a,"tk",tidx(nn))
p = wrf_user_getvar(a,"p",tidx(nn))

p = p/100.

uam = ua(:,obsj,obsi)
vam = va(:,obsj,obsi)
tkm = tk(:,obsj,obsi)
pm = p(:,obsj,obsi)
printVarSummary(pm)
printVarSummary(tkm)
;print(max(tk))
;print(min(tk))

r2d = 45.0/atan(1.0)

varbox(ii,nn,0,:) = tkm*(p0/pm)^k
varbox(ii,nn,1,:) = (uam^2.+vam^2.)^0.5
varbox(ii,nn,2,:) = atan2(uam,vam) * r2d + 180
pbox(ii,nn,0,:) = pm
pbox(ii,nn,1,:) = pm
pbox(ii,nn,2,:) = pm

delete([/lines,fields,obpr,obz,obt,obdt,obwd,obws/])

 end do
delete([/a/])
end do

delete([/varbox@description/])

;=============================== Plotting Section ===============================
; type = "x11"
 type = "png"
wks = gsn_open_wks(type,"Compare_vertv2")
 res = True
 res@gsnFrame = False
 res@gsnDraw = False
 res@xyLineThicknesses = (/4.0,4.0,4.0,4.0/)
 res@xyDashPatterns = (/0,0,0,0/)
 res@xyLineColors = (/"Red","Blue","Green","Black"/)
 res@xyMarkerColors = (/"Red","Blue","Green","Black"/)
 res@xyMarkers = (/16,16,16,16/)
 res@xyMarkerSizes = (/0.02,0.02,0.02,0.02/)

res@pmLegendDisplayMode         = True
res@pmLegendWidthF              = 0.12
res@pmLegendHeightF             = 0.10
res@pmLegendParallelPosF        = .19
res@pmLegendOrthogonalPosF      = -1.15
res@lgLabelFontHeightF          = 0.020
res@lgPerimOn                   = False
res@xyExplicitLegendLabels      = (/"YSU","MYNN","QNSE","OBS"/)
res@trYMaxF						= 1000
res@trYMinF						= 700
res@trYReverse					= True
res@tiYAxisString				= "Pressure (hPa)"

ores = True
ores@gsnFrame                    = False
ores@gsnDraw                     = False
ores@xyMarkLineModes            = "Markers"
ores@xyLineThicknesses          = 4.0
ores@xyDashPatterns             = 0
ores@xyLineColors               = "Black"
ores@xyMarkers = 16
ores@xyMarkerSizes = 0.02

ores@pmLegendDisplayMode         = True
ores@pmLegendWidthF              = 0.12
ores@pmLegendHeightF             = 0.03
ores@pmLegendParallelPosF        = .165
ores@pmLegendOrthogonalPosF      = -0.99
ores@lgLabelFontHeightF          = 0.020
ores@lgPerimOn                   = False
ores@xyExplicitLegendLabels      = (/"OBS"/)


plots = new((/nvar,nti/),graphic)
ov = new((/nvar,nti/),graphic)

do ii = 0, nvar -1
	do jj = 0, nti -1
		if ii .eq. 2 then
        res@xyMarkLineModes = (/"Markers","Markers","Markers","Markers"/)
        res@tmXBMode        = "Explicit"
        res@tmXBValues      = (/90,180,270,360/)
        res@tmXBLabels      = (/"E","S","W","N"/)
        res@trXMaxF         = 360.
		res@trXMinF			= 0.
    else
        res@tmYLMode        = "Automatic"
        res@xyMarkLineModes = (/"Lines","Lines","Lines","Lines"/)
		res@trXMaxF			= xmax(jj,ii)
		res@trXMinF			= xmin(jj,ii)
    end if
		if ii .eq. 0 then
		res@pmLegendDisplayMode = True
		ores@pmLegendDisplayMode = True
		else
		res@pmLegendDisplayMode = False
		ores@pmLegendDisplayMode = False
		end if
		
	res@tiXAxisString = varname(ii)
	res@tiMainString = tiname(jj)
	plots(ii,jj) = gsn_csm_xy(wks,varbox(:,jj,ii,:),pbox(:,jj,ii,:),res)
	ov(ii,jj) = gsn_csm_xy(wks,obbox(jj,ii,:),obpbox(jj,:),ores)
	overlay(plots(ii,jj),ov(ii,jj))

	end do
end do



pnlres = True
gsn_panel(wks,(/plots(:,0)/),(/1,3/),pnlres)
gsn_panel(wks,(/plots(:,1)/),(/1,3/),pnlres)
gsn_panel(wks,(/plots(:,2)/),(/1,3/),pnlres)
gsn_panel(wks,(/plots(:,3)/),(/1,3/),pnlres)



end
