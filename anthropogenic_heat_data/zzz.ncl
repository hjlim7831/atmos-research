load "$NCARG_ROOT/lib/ncarg/nclex/gsun/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

dimtimes = 60
start_time = 3

 do i= start_time, dimtimes+start_time-1
  s = "2010-08-88_99:00:00"
  if (i .lt. 24) then
   s = str_sub_str(s, "88", "20")
   s = str_sub_str(s, "99", sprinti("%0.2i",i))
   else if (i .lt. 48) then
    s = str_sub_str(s, "88", "21")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-24))
   else if (i .lt. 72) then
    s = str_sub_str(s, "88", "22")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-48))
   else if (i .lt. 96) then
    s = str_sub_str(s, "88", "23")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-72))
   else if (i .lt. 120) then
    s = str_sub_str(s, "88", "24")
    s = str_sub_str(s, "99", sprinti("%0.2i",i-96))
   end if
   end if
   end if
   end if
  end if
  ch = stringtochar(s)
  if ( i .eq. start_time ) then
     print(ch)
  end if
 end do

new_GAHF1 = (/0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23/)
GAHF_d01 = new((/dimtimes/),float,-9999)

if ( start_time .ne. 0 ) then

rest = mod(dimtimes-(24-start_time),24)
quot = floattoint((dimtimes-(24-start_time)-rest)/24.)

GAHF_d01(0:23-start_time) = new_GAHF1(start_time:23)

if ( quot .gt. 0 ) then
   do i = 0, quot-1
	  GAHF_d01(23-start_time+1+i*0:23-start_time+1+(i+1)*24-1) = new_GAHF1
   end do

   GAHF_d01(23-start_time+1+24*quot:23-start_time+1+24*quot+rest-1) = new_GAHF1(0:rest-1)
end if

if ( quot .eq. 0 ) then
   GAHF_d01(23-start_time+1:23-start_time+1+rest-1) = new_GAHF1(0:rest-1)
end if

end if

if ( start_time .eq. 0 ) then

rest = mod(dimtimes,24)
quot = floattoint((dimtimes-rest)/24.)

do i = 0, quot-1
   GAHF_d01(i*24:(i+1)*24-1) = new_GAHF1
end do

if ( rest .ne. 0 ) then
   GAHF_d01(quot*24:quot*24+rest-1) = new_GAHF1(0:rest-1)
end if

end if

print(GAHF_d01)

end
