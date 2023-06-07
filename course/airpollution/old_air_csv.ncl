load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"

begin

diro = "~/class/airpollution/csv_file/"


;===== read air pollution data
pr = "ls "+diro+"*_whole.csv"
myFiles = systemfunc(pr)
print(myFiles)
filsiz = dimsizes(myFiles)

lines = asciiread(myFiles(0),-1,"string")
nlines = dimsizes(lines)
delim = ","
fields1 = str_split_csv(lines,delim,0) ; 2016

dim = 10

delete([/lines/])

stnnum1 = new(dim,string)
same1 = new(dim,integer)
z = 1
n = 0
do i = 0, nlines -1
    if i .eq. nlines -1 then
        same1(n) = z
        stnnum1(n) = fields1(i,0)
;       print(i)
    else
;       print(fields1(i,0))
;       print(fields1(i+1,0))
        if fields1(i,0) .eq. fields1(i+1,0) then
            z = z + 1
;           print(i)
        else
            same1(n) = z
            stnnum1(n) = fields1(i,0)
            z = 1
            n = n + 1
        end if
    end if
end do



y1 = 366
M1 = (/31,29,31,30,31,30,31,31,30,31,30,31/)

dsize = y1 * 24 ; for 00 ~ 23
print(dsize)
DATE_R1 = new(dsize,"string",-9999)

D = 0
do i = 0, 11
    do j = 1, M1(i)
        do k = 1, 24  ;change hour (00 ~ 23)
        year = 2016
        s = "778899"
		s = str_sub_str(s,"99",sprinti("%0.2i",k))
		s = str_sub_str(s,"88",sprinti("%0.2i",j))
        s = str_sub_str(s,"77",sprinti("%0.2i",i+1))
        ss = year+s
        DATE_R1(D) = ss
        D = D + 1
        end do
    end do
end do

;print(DATE_R1)

SO2_16r = new((/dim,dsize/),float,-999)
CO_16r = new((/dim,dsize/),float,-999)
O3_16r = new((/dim,dsize/),float,-999)
NO2_16r = new((/dim,dsize/),float,-999)
PM10_16r = new((/dim,dsize/),float,-999)
PM25_16r = new((/dim,dsize/),float,-999)
rawdate_16r = new((/dim,dsize/),string,-999)

n = 0
do i = 0, dim -1
	do j = 0, same1(i) -1
		if n .le. nlines -1 then
		SO2_16r(i,j) = stringtofloat(fields1(n,2))
		CO_16r(i,j) = stringtofloat(fields1(n,3))
		O3_16r(i,j) = stringtofloat(fields1(n,4))
		NO2_16r(i,j) = stringtofloat(fields1(n,5))
		PM10_16r(i,j) = stringtofloat(fields1(n,6))
		PM25_16r(i,j) = stringtofloat(fields1(n,7))
		rawdate_16r(i,j) = fields1(n,1)
		n = n + 1
		end if
	end do
end do		

;print(rawdate_16r)


;print(SO2_16r)

SO2_16 = new((/dim,dsize/),float,-999)
CO_16 = new((/dim,dsize/),float,-999)
O3_16 = new((/dim,dsize/),float,-999)
NO2_16 = new((/dim,dsize/),float,-999)
PM10_16 = new((/dim,dsize/),float,-999)
PM25_16 = new((/dim,dsize/),float,-999)

do i = 0, dim -1
	n = 0
	do j = 0, dsize -1
		if .not. ismissing(rawdate_16r(i,n)) then
		if (DATE_R1(j) .eq. rawdate_16r(i,n)) then
			SO2_16(i,j) = SO2_16r(i,n)
			CO_16(i,j) = CO_16r(i,n)
			O3_16(i,j) = O3_16r(i,n)
			NO2_16(i,j) = NO2_16r(i,n)
			PM10_16(i,j) = PM10_16r(i,n)
			PM25_16(i,j) = PM25_16r(i,n)
			n = n + 1
		end if
		end if
	end do
end do

;print(SO2_16)

lines = asciiread(myFiles(1),-1,"string")
nlines = dimsizes(lines)
delim = ","
fields2 = str_split_csv(lines,delim,0) ; 2018

delete([/lines/])

stnnum2 = new(dim,string)
same2 = new(dim,integer)
z = 1
n = 0
do i = 0, nlines -1
    if i .eq. nlines -1 then
        same2(n) = z
        stnnum2(n) = fields2(i,0)
;       print(i)
    else
;       print(fields2(i,0))
;       print(fields2(i+1,0))
        if fields2(i,0) .eq. fields2(i+1,0) then
            z = z + 1
;           print(i)
        else
            same2(n) = z
            stnnum2(n) = fields2(i,0)
            z = 1
            n = n + 1
        end if
    end if
end do

y1 = 365
M2 = (/31,28,31,30,31,30,31,31,30,31,30,31/)

dsize = y1 * 24 ; for 00 ~ 23

DATE_R2 = new(dsize,"string",-9999)

D = 0
do i = 0, 11
    do j = 1, M2(i)
        do k = 1, 24  ;change hour (00 ~ 23)
        year = 2018
        s = "778899"
		s = str_sub_str(s,"99",sprinti("%0.2i",k))
		s = str_sub_str(s,"88",sprinti("%0.2i",j))
        s = str_sub_str(s,"77",sprinti("%0.2i",i+1))
        ss = year+s
        DATE_R2(D) = ss
        D = D + 1
        end do
    end do
end do

SO2_18r = new((/dim,dsize/),float,-999)
CO_18r = new((/dim,dsize/),float,-999)
O3_18r = new((/dim,dsize/),float,-999)
NO2_18r = new((/dim,dsize/),float,-999)
PM10_18r = new((/dim,dsize/),float,-999)
PM25_18r = new((/dim,dsize/),float,-999)
rawdate_18r = new((/dim,dsize/),string,-999)

n = 0
do i = 0, dim -1
    do j = 0, same2(i) -1
        if n .le. nlines -1 then
        SO2_18r(i,j) = stringtofloat(fields2(n,2))
        CO_18r(i,j) = stringtofloat(fields2(n,3))
        O3_18r(i,j) = stringtofloat(fields2(n,4))
        NO2_18r(i,j) = stringtofloat(fields2(n,5))
        PM10_18r(i,j) = stringtofloat(fields2(n,6))
        PM25_18r(i,j) = stringtofloat(fields2(n,7))
        rawdate_18r(i,j) = fields2(n,1)
        n = n + 1
        end if
    end do
end do

;print(rawdate_18r)


;print(SO2_18r)

SO2_18 = new((/dim,dsize/),float,-999)
CO_18 = new((/dim,dsize/),float,-999)
O3_18 = new((/dim,dsize/),float,-999)
NO2_18 = new((/dim,dsize/),float,-999)
PM10_18 = new((/dim,dsize/),float,-999)
PM25_18 = new((/dim,dsize/),float,-999)

do i = 0, dim -1
    n = 0
    do j = 0, dsize -1
        if .not. ismissing(rawdate_18r(i,n)) then
        if (DATE_R2(j) .eq. rawdate_18r(i,n)) then
            SO2_18(i,j) = SO2_18r(i,n)
            CO_18(i,j) = CO_18r(i,n)
            O3_18(i,j) = O3_18r(i,n)
            NO2_18(i,j) = NO2_18r(i,n)
            PM10_18(i,j) = PM10_18r(i,n)
            PM25_18(i,j) = PM25_18r(i,n)
            n = n + 1
        end if
        end if
    end do
end do

;print(SO2_18)

;========== read ASOS data
pr2 = "ls "+diro+"ASOS*.csv"

myFiles2 = systemfunc(pr2)
filsiz2 = dimsizes(myFiles2)

lines = asciiread(myFiles2(0),-1,"string")
nlines2 = dimsizes(lines)
delim = ","
fields3 = str_split_csv(lines,delim,0)
;print(fields3)
delete([/lines/])

y1 = 366
M1 = (/31,29,31,30,31,30,31,31,30,31,30,31/)

dsize = y1 * 24 ; for 00 ~ 23
print(dsize)
print(nlines2)
DATE_R3 = new(dsize,"string",-9999)

D = 0
do i = 0, 11
    do j = 1, M1(i)
        do k = 0, 23  ;change hour (00 ~ 23)
        year = 2016
        s = "-77-88 99:00"
        s = str_sub_str(s,"77",sprinti("%0.2i",i+1))
        s = str_sub_str(s,"88",sprinti("%0.2i",j))
        s = str_sub_str(s,"99",sprinti("%0.2i",k))
        ss = year+s
        DATE_R3(D) = ss
        D = D + 1
        end do
    end do
end do

;print(DATE_R3)


stnnum3 = new(dim,string)
same3 = new(dim,integer)
z = 1
n = 0
do i = 0, nlines2 -1
    if i .eq. nlines2 -1 then
        same3(n) = z
        stnnum3(n) = fields3(i,0)
;		print(i)
    else
;		print(fields3(i,0))
;		print(fields3(i+1,0))
        if fields3(i,0) .eq. fields3(i+1,0) then
            z = z + 1
;			print(i)
        else
            same3(n) = z
            stnnum3(n) = fields3(i,0)
            z = 1
            n = n + 1
        end if
    end if
end do

print(same3)

temp_16r = new((/dim,dsize/),float,-999)
pre_16r = new((/dim,dsize/),float,-999)
ws_16r = new((/dim,dsize/),float,-999)
wd_16r = new((/dim,dsize/),float,-999)
humid_16r = new((/dim,dsize/),float,-999)
cl_16r = new((/dim,dsize/),float,-999)
rawdate_16mr = new((/dim,dsize/),string,-999)

n = 0
do i = 0, dim -1
    do j = 0, same3(i) -1
        if n .le. nlines2 -1 then
        temp_16r(i,j) = stringtofloat(fields3(n,2))
        pre_16r(i,j) = stringtofloat(fields3(n,3))
        ws_16r(i,j) = stringtofloat(fields3(n,4))
        wd_16r(i,j) = stringtofloat(fields3(n,5))
        humid_16r(i,j) = stringtofloat(fields3(n,6))
        cl_16r(i,j) = stringtofloat(fields3(n,9))
        rawdate_16mr(i,j) = fields3(n,1)
        n = n + 1
        end if
    end do
end do

temp_16 = new((/dim,dsize/),float,-999)
pre_16 = new((/dim,dsize/),float,-999)
ws_16 = new((/dim,dsize/),float,-999)
wd_16 = new((/dim,dsize/),float,-999)
humid_16 = new((/dim,dsize/),float,-999)
cl_16 = new((/dim,dsize/),float,-999)
rawdate_16m = new((/dim,dsize/),string,-999)

do i = 0, dim -1
    n = 0
    do j = 0, dsize -1
        if .not. ismissing(rawdate_16mr(i,n)) then
        if (DATE_R3(j) .eq. rawdate_16mr(i,n)) then
			temp_16(i,j) = temp_16r(i,n)
			pre_16(i,j) = pre_16r(i,n)
			ws_16(i,j) = ws_16r(i,n)
			wd_16(i,j) = wd_16r(i,n)
			humid_16(i,j) = humid_16r(i,n)
			cl_16(i,j) = cl_16r(i,n)
			n = n + 1
		end if
		end if
	end do
end do

;print(temp_16r)
;print(temp_16)





lines = asciiread(myFiles2(1),-1,"string")
nlines2 = dimsizes(lines)
delim = ","
fields4 = str_split_csv(lines,delim,0)
delete([/lines/])

y1 = 365
M2 = (/31,28,31,30,31,30,31,31,30,31,30,31/)

dsize = y1 * 24 ; for 00 ~ 23

DATE_R4 = new(dsize,"string",-9999)

D = 0
do i = 0, 11
    do j = 1, M2(i)
        do k = 0, 23  ;change hour (00 ~ 23)
        year = 2018
        s = "-77-88 99:00"
        s = str_sub_str(s,"77",sprinti("%0.2i",i+1))
        s = str_sub_str(s,"88",sprinti("%0.2i",j))
        s = str_sub_str(s,"99",sprinti("%0.2i",k))
        ss = year+s
        DATE_R4(D) = ss
        D = D + 1
        end do
    end do
end do

print(dsize)
stnnum4 = new(dim,string)
same4 = new(dim,integer)
z = 1
n = 0
do i = 0, nlines2 -1
    if i .eq. nlines2 -1 then
        same4(n) = z
        stnnum4(n) = fields4(i,0)
;       print(i)
    else
;       print(fields4(i,0))
;       print(fields4(i+1,0))
        if fields4(i,0) .eq. fields4(i+1,0) then
            z = z + 1
;           print(i)
        else
            same4(n) = z
            stnnum4(n) = fields4(i,0)
            z = 1
            n = n + 1
        end if
    end if
end do

print(same4)

temp_18r = new((/dim,dsize/),float,-999)
pre_18r = new((/dim,dsize/),float,-999)
ws_18r = new((/dim,dsize/),float,-999)
wd_18r = new((/dim,dsize/),float,-999)
humid_18r = new((/dim,dsize/),float,-999)
cl_18r = new((/dim,dsize/),float,-999)
rawdate_18mr = new((/dim,dsize/),string,-999)

n = 0
do i = 0, dim -1
    do j = 0, same4(i) -1
        if n .le. nlines2 -1 then
        temp_18r(i,j) = stringtofloat(fields4(n,2))
        pre_18r(i,j) = stringtofloat(fields4(n,3))
        ws_18r(i,j) = stringtofloat(fields4(n,4))
        wd_18r(i,j) = stringtofloat(fields4(n,5))
        humid_18r(i,j) = stringtofloat(fields4(n,6))
        cl_18r(i,j) = stringtofloat(fields4(n,9))
        rawdate_18mr(i,j) = fields4(n,1)
        n = n + 1
        end if
    end do
end do

temp_18 = new((/dim,dsize/),float,-999)
pre_18 = new((/dim,dsize/),float,-999)
ws_18 = new((/dim,dsize/),float,-999)
wd_18 = new((/dim,dsize/),float,-999)
humid_18 = new((/dim,dsize/),float,-999)
cl_18 = new((/dim,dsize/),float,-999)
rawdate_18m = new((/dim,dsize/),string,-999)

do i = 0, dim -1
    n = 0
    do j = 0, dsize -1
        if .not. ismissing(rawdate_18mr(i,n)) then
        if (DATE_R4(j) .eq. rawdate_18mr(i,n)) then
            temp_18(i,j) = temp_18r(i,n)
            pre_18(i,j) = pre_18r(i,n)
            ws_18(i,j) = ws_18r(i,n)
            wd_18(i,j) = wd_18r(i,n)
            humid_18(i,j) = humid_18r(i,n)
            cl_18(i,j) = cl_18r(i,n)
            n = n + 1
        end if
        end if
    end do
end do

;print(temp_18r)
;print(temp_18)


;;==================== FINISHED!!!!!!! ===========================================(Maybe..)

; SO2, CO, O3, NO2, PM10, PM25 (16, 18)
; temp, pre, ws, wd, humid, cl (16, 18)
;;hourly data for each year


do j = 1, 10
file_I = "year_18_"+j+".txt"
system("/bin/rm -f "+file_I)
write_table(file_I, "w", [/"SO2","CO","O3","NO2","PM10","PM2.5","T2","precip","ws","wd","humid","cl"/], "%s %s %s %s %s %s %s %s %s %s %s %s ")

k = j -1
do i = 0, 365*24-1
	write_table(file_I, "a", [/SO2_18(k,i),CO_18(k,i), O3_18(k,i), NO2_18(k,i), PM10_18(k,i), PM25_18(k,i),temp_18(k,i),pre_18(k,i),ws_18(k,i),wd_18(k,i),humid_18(k,i),cl_18(k,i)/],"%f %f %f %f %f %f %f %f %f %f %f %f ")
end do

end do








end

