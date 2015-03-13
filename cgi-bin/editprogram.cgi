#!/bin/bash
echo "Content-type: text/html"
echo ""

chmod a+r /home/sand/public_html/cgi-bin/*

echo "<html>"
echo "<head><title>SAND control internet interface - edit schedule</title></head>"
echo "<body bgcolor="b2615e" text="FFCC00" link="000000" vlink="222222" background="../back2.jpg" >"
echo ""
echo "<center>Edit observation schedule</center>"
echo "<form method=get>"
echo "<center><textarea name=program cols=65 rows=15>"
echo "</textarea></center>"
echo "<center><input type=submit value=Update></center>"
echo "</form>"
echo "</center>"
echo "Example:<br><pre>"
cat /home/sand/svn/sand/trunk/mount/cgi-bin/observation_list
 echo "</pre></body>"
echo "</html>"
echo $QUERY_STRING | sed "s/program=//g" | sed "s/%0D%0A/\n/g" | sed "s/%09//g"| sed "s/+/ /g" > observation_list
