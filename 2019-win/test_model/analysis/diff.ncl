begin

a1 = addfile("z1_a2wrf","r")
a2 = addfile("test","r")


t1 = a1->T2
t2 = a2->T2

print(t1(1,:,:) - t2(1,:,:))











end
