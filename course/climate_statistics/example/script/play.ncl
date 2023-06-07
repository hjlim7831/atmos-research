
begin

lis = systemfunc("ls eigen_*")
lis2 = systemfunc("ls cseof_*")

nl = dimsizes(lis)
nl2 = dimsizes(lis2)
print(lis)
print(nl2)

do ii = 0, nl -1
system("./"+lis(ii))
system("./"+lis2(ii))

print(ii)
end do












end
