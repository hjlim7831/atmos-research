load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/time_axis_labels.ncl"

begin

diro = "~/2019-win/therm_env/"
lines = asciiread(diro+"var_maT.csv",-1,"string") ; bring variable data
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

he = fields(0,:)
vyear = tointeger(fields(1:,0))
vmonth = tointeger(fields(1:,1))
vday = tointeger(fields(1:,2))

rvar = tofloat(fields(1:,3:))

dlen = dimsizes(rvar(:,0))
dstn = dimsizes(rvar(0,:))

nrvar = dim_avg_n(rvar,1)

HWdays33 = new((/dlen/),float)
HWindex = new((/dlen,dstn/),integer)
;HWindex = 0 ;option!


do i = 0, dstn -1
	do j = 0, dlen -2
		if rvar(j,i) .ge. 33. .and. rvar(j+1,i) .ge. 33. then
			HWindex(j,i) = 1
			HWindex(j+1,i) = 1
		end if
	end do
end do

do j = 0, dlen -2
	if nrvar(j) .ge. 33. .and. nrvar(j+1) .ge. 33. then
		HWdays33(j) = nrvar(j)
		HWdays33(j+1) = nrvar(j+1)
	end if
end do


syr = vyear(0)
eyr = vyear(dlen-1)

ylen = eyr - syr + 1

DATE = new((/366,6/),integer)
DATE(:,3:5) = 0

yr = syr
iyr = 0
do i = 0, ylen -1
    if isleapyear(yr) then
		DATE(:,0) = vyear(iyr:iyr+365)
		DATE(:,1) = vmonth(iyr:iyr+365)
		DATE(:,2) = vday(iyr:iyr+365)
		break
    end if
    yr = yr + 1
	iyr = iyr + 365
end do
print(DATE(0,0))

HWdays33_yr = new((/366,ylen/),float)
HWdays_yr = new((/366,ylen/),float)
HWindex_yr = new((/366,ylen,dstn/),integer)


yr = syr
iyr = 0
do i = 0, ylen -1
	if isleapyear(yr) then
		HWindex_yr(:,i,:) = HWindex(iyr:iyr+365,:)
		HWdays_yr(:,i) = nrvar(iyr:iyr+365)
		HWdays33_yr(:,i) = HWdays33(iyr:iyr+365)
		iyr = iyr + 366
	else
		HWindex_yr(:58,i,:) = HWindex(iyr:iyr+58,:)
		HWindex_yr(60:365,i,:) = HWindex(iyr+59:iyr+364,:)
		HWdays_yr(:58,i) = nrvar(iyr:iyr+58)
		HWdays_yr(60:365,i) = nrvar(iyr+59:iyr+364)
		HWdays33_yr(:58,i) = HWdays33(iyr:iyr+58)
		HWdays33_yr(60:365,i) = HWdays33(iyr+59:iyr+364)
		iyr = iyr + 365
	end if
	yr = yr + 1
end do
	
;print(HWindex_yr)

nHWindex_yr = dim_sum_n(HWindex_yr,2)/tofloat(dstn) * 100

;print(nHWindex_yr)
;print(HWdays_yr)

;type = "x11"
type = "png"
;type = "oldps"

var = nHWindex_yr
var2 = HWdays_yr

var!0 = "days of the year"
var!1 = "year"
var2!0 = "days of the year"
var2!1 = "year"


var&year = ispan(syr,eyr,1)
var2&year = ispan(syr,eyr,1)

sDATE = (/(/1976,5,1,0,0,0/),\
		  (/1976,6,1,0,0,0/),\
		  (/1976,7,1,0,0,0/),\
		  (/1976,8,1,0,0,0/),\
		  (/1976,9,1,0,0,0/),\
		  (/1976,10,1,0,0,0/)/)  ; 7/9 ~ 8/28

wks  = gsn_open_wks(type,"HW_frc")

;cmap = read_colormap_file("MPL_hot")
;cmap = read_colormap_file("MPL_YlOrRd")
cmap = read_colormap_file("MPL_Greys")

res 						= True
res@gsnFrame				= False
res@gsnDraw					= False
res@cnFillOn				= True
res@cnFillMode				= "RasterFill"
res@cnLinesOn				= False
;res@cnFillPalette			= cmap(20:,:)
res@cnFillPalette			= cmap(20:,:)
;res@cnFillPalette  			= "MPL_YlOrRd"
res@cnLevelSelectionMode	= "ManualLevels"
res@cnMaxLevelValF			= 100.
res@cnMinLevelValF			= 0.
res@cnLevelSpacingF			= 10.
res@tmXTOn					= False
res@tmYROn					= False

;res@trXMaxF				= 1970
;res@trXMinF				= 2020
res@trYMaxF					= 270
res@trYMinF					= 120
res@tmXBMode				= "Explicit"
res@vpWidthF				= 0.6
res@vpHeightF				= 0.4
res@tmXBMajorThicknessF		= 5.0
res@tmXBMinorThicknessF		= 5.0
res@tmYLMajorThicknessF		= 5.0
res@tmBorderThicknessF		= 5.0


res@lbBoxLineThicknessF		= 5.0
res@lbTitleString			= "occurrence (%)"
res@pmLabelBarWidthF		= 0.60
res@pmLabelBarHeightF		= 0.10
res@lbTitlePosition			= "Bottom"
res@lbLabelFontHeightF		= 0.018
res@lbTitleFontHeightF		= 0.025
res@pmLabelBarOrthogonalPosF= 0.1

res@gsnCenterString         		= "year"
res@gsnCenterStringOrthogonalPosF 	= -1.2
res@gsnCenterStringFontHeightF		= 0.02



sres									= True
sres@gsnDraw							= False
sres@gsnFrame							= False
sres@cnInfoLabelOn						= False
sres@cnLevelSelectionMode				= "ExplicitLevels"
sres@cnLevels							= (/33./)
sres@gsnContourLineThicknessesScale		= 6.0
sres@cnLineColor 						= "gold"


restick					= True
;restick@ttmValues		= sDATE
restick@ttmValues      = sDATE
restick@ttmFormat		= "%c %D"
restick@ttmAxis			= "YL"
time				= int2flt(ispan(1,366,1))

time@units			= "days since 1976-01-01 00:00:00"

time_axis_labels(time,res,restick)

plot = gsn_csm_contour(wks,var,res)
plot_ov = gsn_csm_contour(wks,var2,sres)

sres@cnLevels = (/35./)
sres@cnLineColor = "Red"

plot_ov2 = gsn_csm_contour(wks,var2,sres)

overlay(plot,plot_ov)
overlay(plot,plot_ov2)
draw(plot)
frame(wks)






end
