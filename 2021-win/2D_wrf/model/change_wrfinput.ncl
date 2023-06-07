begin

;========== Option =============
;CGVAR = False
CGVAR = True

;========== file input =========

fil1 = "wrfinput_d01"

a1 = addfile(fil1,"w")

TSLB = a1->TSLB
SMOIS = a1->SMOIS
TMN = a1->TMN
LU_INDEX = a1->LU_INDEX
ISLTYP = a1->ISLTYP
SOILCTOP = a1->SOILCTOP
SOILCBOT = a1->SOILCBOT
VEGFRA = a1->VEGFRA
LANDUSEF = a1->LANDUSEF

printVarSummary(TSLB)

SMOIS = 0.25
TSLB = 20+273.15
TMN = 20+273.15

dx = 1000

ist = 90*1000/dx
iend = 110*1000/dx

; for surrounding areas

ISLTYP = 2
VEGFRA = 0.6
LU_INDEX = 6
SOILCBOT(:,1,:,:) = 1.
SOILCTOP(:,1,:,:) = 1.
LANDUSEF(:,5,:,:ist-1) = 1.
LANDUSEF(:,5,:,iend+1:) = 1.


; for urban areas : 90 km - 110 km (total 20 km)

LU_INDEX(:,:,ist:iend) = 31
LANDUSEF(:,30,:,ist:iend) = 1.


if CGVAR then

a1->TSLB = TSLB
a1->SMOIS = SMOIS
a1->TMN = TMN
a1->LU_INDEX = LU_INDEX
a1->VEGFRA = VEGFRA
a1->ISLTYP = ISLTYP
a1->LANDUSEF = LANDUSEF
a1->SOILCTOP = SOILCTOP
a1->SOILCBOT = SOILCBOT

end if

end
