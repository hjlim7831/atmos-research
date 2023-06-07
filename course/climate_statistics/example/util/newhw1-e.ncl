begin

name = "hw1-e"

diro = "../results/"

llev = (/"800","825","850","875","900","925","950","975","1000"/)

wdata1 = "csf_sic-u"+llev+"_reg.data"
wdata2 = "csf_sic-v"+llev+"_reg.data"
wdata3 = "csf_sic-z"+llev+"_reg.data"
wdata4 = "csf_sic-t"+llev+"_reg.data"
wdata5 = "csf_sic-sh"+llev+"_reg.data"


wlis1 = diro+wdata1
wlis2 = diro+wdata2
wlis3 = diro+wdata3
wlis4 = diro+wdata4
wlis5 = diro+wdata5

nlis = dimsizes(wlis1)

print(wlis1)

tit = new((/5,2/),string)

tit(0,:) = (/"60 E (u)","80 N (u)"/)
tit(1,:) = (/"60 E (v)","80 N (v)"/)
tit(2,:) = (/"60 E (z)","80 N (z)"/)
tit(3,:) = (/"60 E (t)","80 N (t)"/)
tit(4,:) = (/"60 E (q)","80 N (q)"/)

print(dimsizes(tit))

MaxF = new((/5,2/),float)
MaxF(:,0) = (/24.,20.,8000.,120.,0.02/)
MaxF(:,1) = (/20.,24.,6000.,120.,0.02/)

nlat = 48
nlon = 240
ntim = 24

xlon = fspan(0,358.5,240)
xlat = fspan(19.5,90,48)

e60 = ind(xlon .eq. 60.)
n80 = ind(xlat .eq. 79.5)
print(e60)
print(n80)

xlon@units = "degrees_east"
xlat@units = "degrees_north"

;print(xlon)
;print(xlat)

UNDEF = -999.

var = new((/nlis,5,ntim,nlat,nlon/),float,UNDEF)
do ii = 0, nlis -1
	do nt = 0, ntim -1
		var(ii,0,nt,:,:) = fbindirread(wlis1(ii),nt,(/nlat,nlon/),"float")
		var(ii,1,nt,:,:) = fbindirread(wlis2(ii),nt,(/nlat,nlon/),"float")
		var(ii,2,nt,:,:) = fbindirread(wlis3(ii),nt,(/nlat,nlon/),"float")
		var(ii,3,nt,:,:) = fbindirread(wlis4(ii),nt,(/nlat,nlon/),"float")
		var(ii,4,nt,:,:) = fbindirread(wlis5(ii),nt,(/nlat,nlon/),"float")
	end do
end do


vars = new((/nlis,5,nlat,nlon/),float,UNDEF)
vars(:,:,:,:) = (var(:,:,0,:,:)+var(:,:,1,:,:)+var(:,:,11,:,:))/3.

vare = vars(:,:,:,e60)
varn = vars(:,:,n80,:)

; ============================================ Plotting Section ===============================================

;type = "x11"
;type = "png"
type = "oldps"

wks = gsn_open_wks(type,name)

gsn_define_colormap(wks,"NCV_blu_red")

plot = new((/10/),graphic)

cnres                                   = True
cnres@gsnFrame				= False
cnres@gsnDraw				= False
cnres@gsnLeftStringFontHeightF          = 0.030
cnres@vpWidthF				= 0.8
cnres@vpHeightF				= 0.6

cnres@tmXBLabelFontHeightF		= 0.025
cnres@tmYLLabelFontHeightF		= 0.025




cnres@cnFillOn                          = True
cnres@cnLinesOn                         = False
cnres@cnInfoLabelOn			= False
cnres@cnLineLabelsOn			= False
cnres@cnLevelSelectionMode              = "ManualLevels"
;cnres@lbLabelBarOn                      = False
cnres@lbLabelFontHeightF		= 0.025
cnres@pmLabelBarHeightF			= 0.1
cnres@pmLabelBarOrthogonalPosF		= 0.0
;cnres@gsnAddCyclic			= True
cnres@trYReverse			= True


pres = True
;pres@gsnPanelLabelBar = True
;pres@pmLabelBarWidthF = 0.5
n = 0
do ii = 0, 4
	do jj = 0, 1
		if jj .eq. 0 then
			pvar = -vare(:,ii,:)
			pvar!0 = "XLEV"
			pvar!1 = "XLAT"
			pvar&XLEV = tofloat(llev)
			pvar&XLAT = xlat
		else
			pvar = -varn(:,ii,:)
			pvar!0 = "XLEV"
			pvar!1 = "XLONG"
			pvar&XLEV = tofloat(llev)
			pvar&XLONG = xlon
		end if
		printVarSummary(pvar)
		print(ii)
		cnres@cnMinLevelValF	= -MaxF(ii,jj)
		cnres@cnMaxLevelValF	= MaxF(ii,jj)
		cnres@gsnLeftString = tit(ii,jj)
		print(max(pvar))
		print(min(pvar))
		plot(n) = gsn_csm_contour(wks,pvar,cnres)
		delete([/pvar/])
		n = n + 1
	end do
end do

gsn_panel(wks,plot,(/5,2/),pres)





end
