import numpy as np
from math import * 
from jdcal import gcal2jd

########################################## COSSZA ############################################
# MODULE COSSZA COMPUTES THE COSINE OF THE SOLAR ZENITH ANGLE, GIVEN
# THE DAY OF YEAR(JULIAN), CURRENT TIME(GMT), LONGITUDE AND LATITUDE.

def cossza(start,time,lon,lat):

 # Calculate day of year
 yyyy = start.split(',')[0]
 mm = start.split(',')[1]
 dd = start.split(',')[2]
 strt_DOY = gcal2jd(yyyy,mm,dd) 
 frst_DOY = gcal2jd(yyyy,01,01)
 DOY = (int(strt_DOY[0]+strt_DOY[1])+1) - (int(frst_DOY[0]+frst_DOY[1])+1)

 # Coeffecients for solar declination angle
 a0 = 0.006918
 a1 = 0.399912
 a2 = 0.006758
 a3 = 0.002697 
 b1 = 0.070257
 b2 = 0.000907
 b3 = 0.000148

 # Path length of earth's orbit traversed since Jan, 1 [radians]
 R = 2.*pi*np.double(DOY-1)/365. 

 # Solar declination angle [radians]
 d = a0 - a1*cos(R) + b1*sin(R) - a2*cos(2.*R) + b2*sin(2.*R) - a3*cos(3.*R) + b3*sin(3.*R)
 sin_d = sin(d)
 cos_d = cos(d)

 # Local time [hours]
 loc_t = time/3600. + 9. 
 if loc_t > 24:
     loc_t = loc_t - 24.

 # Hour angle [radians]
 hra = fabs(loc_t - 12.) * 15 * (pi/180)

 # Cosine of solar zenith angle
 cos_sza = sin(lat*pi/180.)*sin_d + cos(lat*pi/180.)*cos_d*cos(hra)


# print 'local time :', loc_t
# print 'cos =', cos_sza
 return cos_sza


##############################################################################################
##################################### END OF COSSZA ##########################################
##############################################################################################
