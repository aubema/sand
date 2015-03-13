#!/usr/bin/env python
import ephem
from time import gmtime, strftime
import re

#pour la longitude

for line in open("/home/sand/localconfig"):
 if "Longitude"in line:
   wordlist = re.sub("[^\w]", " ",  line).split()
   i = 0
   for word in wordlist:
     i = i + 1
     if i == 3:
       deg = float(word)
     if i == 4:
       minute = float(word)
     if i == 5:
       sec = float(word)


# la definition de localconfig est positive vers l'ouest alors que pyephem est positif vers l'est
# c'est pourquoi tout est en negatif

Lon =  -deg - minute / 60 - sec / 3600


# pour la latitude

for line in open("/home/sand/localconfig"):
 if "Latitude"in line:
   wordlist = re.sub("[^\w]", " ",  line).split()
   i = 0
   for word in wordlist:
     i = i + 1
     if i == 3:
       deg = float(word)
     if i == 4:
       minute = float(word)  
     if i == 5:
       sec = float(word)


Lat = deg + minute / 60 + sec / 3600

# pour l'elevation 

for line in open("/home/sand/localconfig"):
 if "elev_sealevel"in line:
   wordlist = re.sub("[^\w]", " ",  line).split()
   i = 0
   for word in wordlist:
     i = i + 1
     if i == 2:
       elev = float(word)


# trouver azimuth et altitude

gatech = ephem.Observer() 
gatech.lon = str(Lon) 
gatech.lat = str(Lat) 
gatech.elevation = elev 
date = strftime("%Y/%m/%d %H:%M:%S") 
gatech.date = date 
m = ephem.Moon(gatech) 
print m.alt, m.az