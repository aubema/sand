#!/bin/bash
echo "Content-type: text/html"
echo ""

echo "<html>"
echo "<head><title>SAND control internet interface</title></head>"
echo "<body bgcolor="550000" text="FFCC00">"
echo "<center><h3>Execution output</h3></center>"
echo "<br>"
echo "<center><img src="../lastwebcam.jpg"></center>"
echo "<br><center>Mean ambient luminosity:"
cat /home/sand/public_html/cgi-bin/webcam-mean
echo "/255</center>"


echo "</form>"
echo "</body>"
echo "</html>"

