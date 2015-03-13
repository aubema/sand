#!/bin/bash
# programme pour produire un graphique de spectre
#
#   
#    Copyright (C) 2010  Martin Aube
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#    Contact: martin.aube@cegepsherbrooke.qc.ca
#
if [ ! $1 ]
then echo "Usage: mkGraph.bash title spectrum_file_1 spectrum_file_2 ..."
     exit 1
fi
base=$1
echo "set terminal x11 " > toto.gplot

echo "set title '"$1"'" >>toto.gplot
echo "set grid" >>toto.gplot
echo "set mxtics " >>toto.gplot
echo "set mytics " >>toto.gplot
#echo "set size 2,1" >toto.gplot
echo "set xrange [400:730]" >> toto.gplot
echo "set style data lines" >> toto.gplot
echo "set xlabel 'Wavelenght (nm)'" >> toto.gplot
echo "set ylabel 'Radiance'" >> toto.gplot
if [ $2 ]
then echo "plot '"$2"' " >> toto.gplot
else echo "Usage: mkGraph.bash output_name spectrum_file_1 spectrum_file_2 ..."
     exit 1
fi

echo "plot '"$2"' " >> toto.gplot
if [ $3 ]
then echo "replot '"$3"' " >> toto.gplot
fi
if [ $4 ]
then echo "replot '"$4"' " >> toto.gplot
fi
if [ $5 ]
then echo "replot '"$5"' " >> toto.gplot
fi
if [ $6 ]
then echo "replot '"$6"' " >> toto.gplot
fi
#gnuplot  < toto.gplot > $1".jpeg"
#display $1".jpeg" &
gnuplot -background white -persist < toto.gplot
