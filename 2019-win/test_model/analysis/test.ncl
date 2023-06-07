begin

a1 = addfile("./t2boxs.nc","r")
t2boxs = a1->t2boxs

print(min(t2boxs(2,12,:,:56)))
print(max(t2boxs(1,14,:,:)))
print(max(t2boxs(1,14,:,:))-max(t2boxs(0,14,:,:)))
print(max(t2boxs(2,16,:,:)))












end
