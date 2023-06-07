load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"      ; These two libraries are automatically
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"    ; loaded from NCL V6.4.0 onward.
                                                              ; No need for user to explicitly load.
begin

a = addfile("wrfout_d01_1999-10-22_19:00:00_initial","r")
z = wrf_user_getvar(a,"z",-1)
th = wrf_user_getvar(a,"th",-1)
T300 = a->T+300

;print(z(:,12,0,0))
;print(th(58,1,0,0))
;print(T300(58,1,0,0))

print(th-T300)


end

