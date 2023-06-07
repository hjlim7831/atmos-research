import numpy as np
import os
import matplotlib.pyplot as plt

diro = '/home/hjlim/class/micrometeo/'

myFiles = os.listdir(diro+'files/')

filsiz = len(myFiles)
#print(filsiz)

print(myFiles)
a = np.genfromtxt(diro+'files/'+myFiles[0],dtype = 'float')

dim = len(a)

data_r = np.zeros((filsiz,dim))
data_r[0] = a

for i in range(1,filsiz):
	a = np.genfromtxt(diro+'files/'+myFiles[i],dtype = 'float')
	data_r[i] = a

rseq = np.array([2,3,1,0,6,7,5,4]) # data_r[0] -> data[2]

data = np.zeros((filsiz,dim))

for i in range(filsiz):
	data[rseq[i]] = data_r[i]

del(data_r)

n = dim
Ts = 1./20.
Fs = 1./Ts

k = np.arange(n)
T = n/Fs
freq = k/T
print(freq)
freq = freq[range(int(n/2))]
#print(freq)


time = np.array(list(range(0,1200,1)))*0.05

fft_data = np.zeros((filsiz,int(dim/2)))

for i in range(8):
    FFT = abs(np.fft.fft(data[i]))
    fft_data[i] = FFT[range(int(n/2))]

LABEL = ['surface','60m','140m','300m']
LST = ['13LST','05LST']
#y1top = [4.,1.]
#y1end = [-2.,-2.]
#y2end = [500,800]

###2 pictures in one panel


for i in range(8):
    fig, ax = plt.subplots(2,1)
    ax[0].plot(time,data[i])
    ax[0].set_xlabel('Time(s)')
    ax[0].set_ylabel('Amplitude')
    ax[0].set_title(LABEL[i%4]+' '+LST[int(i/4)])
    ax[1].plot(freq,fft_data[i],'r')
    ax[1].set_ylabel('Power Spectral density')
    ax[1].set_xlabel('Period')
    ax[1].set_title(LABEL[i%4]+' '+LST[int(i/4)])
    ax[1].set_xscale('log')
    ax[1].set_xticks([1./60.,1.,10.])
    ax[1].set_xticklabels(['$1min$','$1sec$','$0.1sec$'])
#    ax[1].set_xlim([1.66666667e-02,10])
#    ax[1].set_yscale('log')
    fig.tight_layout()
#    plt.show()
    fig.savefig(diro+'picture/hw2_'+str(LABEL[i%4])+'_'+str(LST[int(i/4)])+'.png')

###Picture is not pretty..
"""
for i in range(4):
	plt.plot(freq,abs(fft_data[i]),label=LABEL[i])

plt.legend(loc=1)
plt.show()
"""


