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

obs = ephem.Observer()# la definition de localconfig est positive vers l'ouest alors que pyephem est positif vers l'est
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

obs.lon = str(Lon)
obs.lat = str(Lat)
obs.elevation = elev
obs.date = strftime("%Y/%m/%d %H:%M:%S") 
# ajout des raws input
star =  raw_input()

if star == "Sirius":
  star = ephem.star('Sirius')
  star.compute(obs)
  print star.alt, star.az
elif star == "Arcturus":  
  star = ephem.star('Arcturus')
  star.compute(obs)
  print star.alt, star.az
elif star == "Altair":  
  star = ephem.star('Altair')
  star.compute(obs)
  print star.alt, star.az
elif star == "Polaris":  
  star = ephem.star('Polaris')
  star.compute(obs)
  print star.alt, star.az
elif star == "Mimosa":  
  star = ephem.star('Mimosa')
  star.compute(obs)
  print star.alt, star.az
elif star == "Rigel":  
  star = ephem.star('Rigel')
  star.compute(obs)
  print star.alt, star.az
elif star == "Achernar":
  star = ephem.star('Achernar')
  star.compute(obs)
  print star.alt, star.az
elif star == "Pollux":  
  star = ephem.star('Pollux')
  star.compute(obs)
  print star.alt, star.az
elif star == "Canopus":  
  star = ephem.star('Canopus')
  star.compute(obs)
  print star.alt, star.az
elif star == "Fomalhaut":  
  star = ephem.star('Fomalhaut')
  star.compute(obs)
  print star.alt, star.az
elif star == "Betelgeuse":  
  star = ephem.star('Betelgeuse')
  star.compute(obs)
  print star.alt, star.az
elif star == "Antares":  
  star = ephem.star('Antares')
  star.compute(obs)
  print star.alt, star.az
elif star == "Vega":  
  star = ephem.star('Vega')
  star.compute(obs)
  print star.alt, star.az
else:
  print "not in the list"
  

  