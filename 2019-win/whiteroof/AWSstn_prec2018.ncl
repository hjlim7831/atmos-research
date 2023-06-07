load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

diro1 = "~/2019-win/whiteroof/csv/20180715_20180820_prec_aws.csv"  ; data file
diro2 = "~/archive/CSV/META_AWS_wholeM.csv" ; stnInfo file


lines = asciiread(diro1,-1,"string")
nlines = dimsizes(lines)
delim = ","
fields = str_split_csv(lines,delim,0)

dates = fields(1,:) ; to compare dates
;;;;; to change date, modify here!!
dsize = 37
start_day = 15
ldm = 31 ; (Last Day of Month) July and August
;;;;;

DATE = new(dsize,string)

do i = 0, dsize -1
	s = "2018-77-88"
	day = start_day + i
	if day .le. ldm then
		s = str_sub_str(s,"77","07")
		s = str_sub_str(s,"88",sprinti("%0.2i",day))
		DATE(i) = s
	else
		s = str_sub_str(s,"77","08")
		s = str_sub_str(s,"88",sprinti("%0.2i",day-ldm))
		DATE(i) = s
	end if
end do

print(DATE)

stnnum = new((/493/),string)

same = new((/493/),integer) ; each station's data number
z = 1
n = 0
do i = 0, nlines -1
    if i .eq. nlines -1 then
        same(n) = z
        stnnum(n) = fields(0,i)
    else
        if fields(0,i) .eq. fields(0,i+1) then
            z = z + 1
        else
            same(n) = z
            stnnum(n) = fields(0,i)
            z = 1
            n = n + 1
        end if
    end if
end do
dim = dimsizes(same) ; total station number

mis = dsize - same ; each station's missing data number
n = 0
do i = 0, dim -1
    if( mis(i) .eq. 0) then
        DATE = dates(n:n+dsize-1)
        break
    else
        n = n + same(i)
    end if
end do

data_daily_prec = new((/dsize,dim/),float,-9999)

; dsize = 37, dim = 95
n = 0
do i = 0, dim -1
	do j = 0, dsize -1
	if n .lt. nlines then
        if (DATE(j) .eq. dates(n)) then
            data_daily_prec(j,i) = stringtofloat(fields(2,n))
            n = n + 1
        end if
	end if
    end do
end do

stn = asciiread(diro2,-1,"string")
nstn = dimsizes(stn)
delim = ","
stnData(nf,:) = str_split_csv(lines,delim,0)

stnNum = stringtofloat(stnData(0,:))
stnSD = stringtofloat(stnData(1,:))
stnED = stringtofloat(stnData(2,:))
stnLat = stringtofloat(stnData(3,:))
stnLon = stringtofloat(stnData(4,:))

; we have : data_daily_prec, stnNum, stnLat, stnLon

do i = 0, dsize -1
	do j = 0, dim -1
	if ismissing(data_daily_prec(i,j)) then
		data_daily_prec(i,j) = 0
	end if
	end do
end do
;print(data_daily_prec)

;;;;; Seoul boundary
  SeoulBND = asciiread("./Seoul_Boundary.prn",(/647,2/),"float")
  x = SeoulBND(:,0) ; longitude
  y = SeoulBND(:,1) ; latitude
  boundary = new(646,graphic)
  resp                         = True
  resp@gsLineColor             = "Black"
  resp@gsLineThicknessF        = 5


; type = "x11"
 type = "png"
 wks = gsn_open_wks(type,"2018_AWS_Prec")
 gsn_define_colormap(wks,"StepSeq25")
 
 res								= True
 res@gsnMaximize					= True
 res@gsnFrame						= False
 res@gsnDraw						= False

 res@cnLineLabelPlacementMode		= "Constant"
 res@cnLineLabelFontColor			= "Gray15"
 res@cnLineDashSegLenF				= 0.3

 res@cnLevelSelectionMode			= "ExplicitLevels"
 res@cnLevels						= ispan(0,24,1)
 res@cnFillOn						= True

;;;Just for Seoul area
 res@mpMinLatF						= 37.32
 res@mpMinLonF						= 126.54
 res@mpMaxLatF						= 37.82
 res@mpMaxLonF						= 127.25

;;;for Korea
; res@mpMinLatF              	    = min(stnLat)-.5
; res@mpMinLonF                  	= min(stnLon)-.5
; res@mpMaxLatF                  	= max(stnLat)+.5
; res@mpMaxLonF                  	= max(stnLon)+.5

 res@mpFillOn						= False
 res@mpOutlineDrawOrder				= "PostDraw"
 res@mpOutlineOn					= True
 res@mpOutlineBoundarySets			= "National"

 res@mpDataBaseVersion				= "HighRes"
 res@mpNationalLineThicknessF		= 4.0
 res@mpGeophysicalLineThicknessF	= 4.0
 res@mpLimbLineThicknessF			= 1.5


do ii = 0, dsize -1
DATA = data_daily_prec(ii,:)

DATA@lat1d = stnLat
DATA@lon1d = stnLon

;printVarSummary(DATA)

 res@tiMainString				= "Precipitation "+(ii+15)
 plot = gsn_csm_contour_map(wks,DATA,res)

 mkres							= True
 mkres@gsMarkerIndex			= 16
 mkres@gsMarkerSizeF			= 0.0035
 mkres@gsnFrame					= False
; mkres@gsnDraw					= False
do i = 0, 645
	boundary(i) = gsn_add_polyline(wks,plot,x(i:i+1),y(i:i+1),resp)
end do

 gsn_coordinates(wks,plot,DATA,mkres)

frame(wks)


end do


end
