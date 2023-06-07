load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

diro = "./"
fili1 = "doublegahf_d01_0714-0820.nc"
fili2 = "doublegahf_d02_0714-0820.nc"
fili3 = "doublegahf_d03_0714-0820.nc"
;fili4 = "gahf_d04_0720-0727_4_16028.nc"

;filo1 = "d01_test.nc"
;filo2 = "d02_test.nc"
;filo3 = "d03_test.nc"
;filo4 = "d04_test.nc"


filo1 = fili1
filo2 = fili2
filo3 = fili3
;filo4 = fili4

f1 = addfile(diro+fili1, "r")   ; domain 
f2 = addfile(diro+fili2, "r")   ; domain 
f3 = addfile(diro+fili3, "r")   ; domain 
;f4 = addfile(diro+fili4, "r")   ; domain 

ii1 = addfile("./wrfinput_d01", "r")
ii2 = addfile("./wrfinput_d02", "r")
ii3 = addfile("./wrfinput_d03", "r")
;ii4 = addfile("./wrfinput_d04", "r")

gahf1 = f1->GAHF
gahf2 = f2->GAHF
gahf3 = f3->GAHF
;gahf4 = f4->GAHF
time_former = f1->Times
;print(time_former)

;start time input
;dimtimes = (31+6)*24+3
;dimtimes = 171
dimtimes = 891
;dimtimes = 36
ldm = 31 ; last day of month
start_time = 12
start_day = 14
;end_day = start_day+6
end_day = start_day + 37
;start_day = 17
;end_day = 27


fact = (ldm-start_day)*24 + 24 - start_time


;7/26 15:00:00 -> 8/4 15:00:00  9(26)+24(27)+24(28)+24(29)+24(30)+24(31)
new_times = new((/dimtimes,19/),character)
check_time = new((/dimtimes/),string)

do i = start_time, start_time+dimtimes-1
   s = "2018-77-88_99:00:00"

      tmp_dim1 = i/24             ;each day number(0,1,2,...)
      tmp_dim2 = i-tmp_dim1*24    ;hour
;;;;;;;;;;;;;;;;;
      tmp_dim3 = tmp_dim1+start_day
   if ( i .lt. fact+start_time ) then
      s = str_sub_str(s, "77", "07")
      s = str_sub_str(s, "88", sprinti("%0.2i",tmp_dim3))
      s = str_sub_str(s, "99", sprinti("%0.2i",tmp_dim2))
   end if
   if ( i .ge. fact+start_time ) then
      s = str_sub_str(s, "77", "08")
	  tmp_dim4 = tmp_dim3-ldm
      s = str_sub_str(s, "88", sprinti("%0.2i",tmp_dim4))
      s = str_sub_str(s, "99", sprinti("%0.2i",tmp_dim2))
   end if
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      s = str_sub_str(s, "77", "08")
;      tmp_dim3 = tmp_dim1+2
;   if ( i .lt. 177+start_time ) then
;      s = str_sub_str(s, "88", sprinti("%0.2i",tmp_dim3))
;      s = str_sub_str(s, "99", sprinti("%0.2i",tmp_dim2))
;   end if
;   if ( i .ge. 177+start_time ) then
;      s = str_sub_str(s, "88", sprinti("%0.2i",tmp_dim3))
;      s = str_sub_str(s, "99", sprinti("%0.2i",tmp_dim2))
;   end if
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   print(s)
    check_time(i-start_time) = s
   ch = stringtochar(s)
   new_times(i-start_time,:) = ch(0:18)
end do


print(check_time)
new_times!0 = "Time"
new_times!1 = "DateStrLen"

do i = 0, dimtimes-1
   ttmp = chartostring(new_times(i,:))
;   print(ttmp)
end do

FiAtt1 = True
FiAtt2 = True
FiAtt3 = True
;FiAtt4 = True
copy_VarMeta(ii1, FiAtt1)
copy_VarMeta(ii2, FiAtt2)
copy_VarMeta(ii3, FiAtt3)
;copy_VarMeta(ii4, FiAtt4)

FiAtt1@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt2@TITLE = "Hourly anthropogenic heat flux for Seoul"
FiAtt3@TITLE = "Hourly anthropogenic heat flux for Seoul"
;FiAtt4@TITLE = "Hourly anthropogenic heat flux for Seoul"

setfileoption("nc","Format","LargeFile")
system("/bin/rm -f "+diro+filo1)
system("/bin/rm -f "+diro+filo2)
system("/bin/rm -f "+diro+filo3)
;system("/bin/rm -f "+diro+filo4)

fout1 = addfile(diro+filo1, "c" )
fout2 = addfile(diro+filo2, "c" )
fout3 = addfile(diro+filo3, "c" )
;fout4 = addfile(diro+filo4, "c" )
fileattdef(fout1, FiAtt1)
fileattdef(fout2, FiAtt2)
fileattdef(fout3, FiAtt3)
;fileattdef(fout4, FiAtt4)

fout1->GAHF = f1->GAHF(:,:,:)
fout1->Times = new_times(:,:)
fout2->GAHF = f2->GAHF(:,:,:)
fout2->Times = new_times(:,:)
fout3->GAHF = f3->GAHF(:,:,:)
fout3->Times = new_times(:,:)
;fout4->GAHF = f4->GAHF(:,:,:)
;fout4->Times = new_times(:,:)

end
