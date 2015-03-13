#!/bin/bash
echo "Content-type: text/html"
echo ""

chmod a+r /home/sand/public_html/cgi-bin/*

echo "<html>"
echo "<head><title>SAND control internet interface - links</title></head>"
echo "<body bgcolor="b2615e" text="FFCC00" link="000000" vlink="222222" background="../back2.jpg" >"
echo ""
echo "<center>Last observation schedule</center>"
echo "<center><textarea name=program cols=65 rows=7>"
cat /home/sand/public_html/cgi-bin/observation_list
echo "</textarea></center>"
echo "<center>Usefull links</center>"
echo "<ol><li><a href="editprogram.cgi" target=newtab>Create an observation schedule</a>"
echo "<li><a href="../data" target=newtab>Browse data</a>"
echo "<li><a href="last-ccd-img.cgi" target=newtab>View last manually acquired CCD image</a>"
echo "<li><a href="../data/output.log" target=new>View output.log</a>"
echo "<li><a href="deletelog.cgi" target=new>Clear output.log</a>"
echo "</ol></body>"
echo "</html>"

