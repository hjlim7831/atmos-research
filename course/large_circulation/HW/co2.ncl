begin

a = addfile("1979-2019.grib","r")
;print(a)

T = a->T_GDS0_ISBL_S123

delete(a)
printVarSummary(T)

;print(T)

;aT = dim_avg_n(T,(/1,2,3/))

aT = dim_avg_n(T,3)

printVarSummary(aT)

delete(T)

T1 = dim_avg_n(aT,(/1,2/))

system("/bin/rm -f simple.nc")
ncdf = addfile("simple.nc","c")
fAtt               = True
fAtt@title         = "NCL Simple Approach to netCDF Creation"
fAtt@source_file   =  "original-file.nc"
fAtt@Conventions   = "None"
fAtt@creation_date = systemfunc ("date")
fileattdef( ncdf, fAtt )            ; copy file attributes-1
filedimdef(ncdf,"time",-1,True)
ncdf->avgT = T1
print("finish")



end
