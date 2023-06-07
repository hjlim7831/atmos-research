begin

plist = systemfunc("ls *.ps")

np = dimsizes(plist)

;print(plist)

do ii = 0, np -1
	system("ps2epsi "+plist(ii))
	pstr = str_sub_str(plist(ii),".ps","")
	system("mv "+pstr+".epsi "+pstr+".eps")
	system("convert -density 700 "+pstr+".eps "+pstr+".png")
end do
	












end
