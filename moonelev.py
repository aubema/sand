#!/usr/bin/env python
import ephem
import sys
from time import gmtime, strftime
import re
# Longitude Latitude et Altitude les Longitudes W sont negatives
Lond = input()
Lonm = input()
Lons = input()
sign = Lond / abs(Lond)
Lon = Lond + sign * Lonm/60. + sign * Lons/3600.
Latd = input()
Latm = input()
Lats = input()
sign = Latd / abs(Latd)
Lat = Latd + sign * Latm/60. + sign * Lats/3600.
elev = input()
date = raw_input()
#"Date (YYYY/MM/DD hh:mm:ss)="
gatech = ephem.Observer() 
gatech.lon = str(Lon) 
gatech.lat = str(Lat) 
gatech.elevation = elev 
gatech.date = date
m = ephem.Moon(gatech) 
print m.alt , m.az , m.phase
#phase est la pourcentage illumine
