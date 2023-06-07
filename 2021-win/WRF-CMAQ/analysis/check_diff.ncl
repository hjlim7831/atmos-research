begin

dir1 = "~/WRF-4.1.3/WRF/"
dir2 = "~/WRF-4.1.3-4/WRF/"

folder = (/"arch/","chem/","doc/","dyn_em/","dyn_nmm/","external/","frame/","hydro/","inc/","main/","phys/","Registry/","run/","share/","tools/","var/","wrftladj/"/)
print(folder)

nf = dimsizes(folder)

do ii = 0, nf -1
	codefiles1 = systemfunc("ls "+dir1+folder(ii)+"*")
	nc = dimsizes(codefiles1)
	codefiles2 = str_sub_str(codefiles1,"WRF-4.1.3","WRF-4.1.3-4")
	do jj = 0, nc -1
		output = systemfunc("diff "+codefiles1(jj)+" "+codefiles2(jj))
		if .not. all(ismissing(output)) then
			print(output)
			print("diff "+codefiles1(jj)+" "+codefiles2(jj))
		end if
		delete([/output/])
	end do

	delete([/codefiles1,codefiles2/])
end do











end
