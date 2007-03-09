  <html> 
     
<head><title>View Data</title>
<link rel="stylesheet"  href="include/styletut.css" type="text/css">
<%@ include file="include/javascript.jsp" %>
</head>

<body>
    
<P>
We show five rows of raw data here:
<P>

<!-- <IMG SRC=graphics/raw_data_example2.gif>
<IMG SRC="graphics/raw_data_example.gif"> -->


<CENTER>
 
 
<TABLE CELLPADDING=4 frame = "box">
   <FONT SIZE =-1 FACE=ARIAL>
<TR>
	<TD colspan = 16>
		<center>
			<font SIZE =-1 color = "FF7500">
				COLUMNS
			</font>
		</center>
	</TD>
</TR>
 


 
<TR>

	<TH>
		<font font SIZE=-1 color = "FF7500">
			1
		</font>
	</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	2</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	3</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	4</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	5</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	6</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	7</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	8</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	9</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	10</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	11</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	12</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	13</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	14</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	15</font> </th>
	<TH>
		<font font SIZE=-1 color = "FF7500">
	16</font> </th>


	
</TR>
 
 
 
<TR>
	<TD>80EE0049</TD>
	<TD>80</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>38</TD>
	<TD>01</TD>
	<TD>3C</TD>
	<TD>01</TD>
	<TD>7EB7491F</TD>
	<TD>202133.242</TD>
	<TD>080803</TD>
	<TD>A</TD>
	<TD>04</TD>
	<TD>2</TD>
	<TD>-0390</TD>
</TR>

<TR>
	<TD>80EE004A</TD>
	<TD>24</TD>
	<TD>3D</TD>
	<TD>25</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>01</TD><TD>00</TD>
	<TD>01</TD>
	<TD>7EB7491F</TD>
	<TD>202133.242</TD>
	<TD>080803</TD>
	<TD>A</TD>
	<TD>04</TD>
	<TD>2</TD>
	<TD>-0389</TD>
</TR>

<TR>
	<TD>80EE004B</TD>
	<TD>21</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>23</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>7EB7491F</TD>
	<TD>202133.424</TD>
	<TD>080803</TD>
	<TD>A</TD>
	<TD>04</TD>
	<TD>2</TD>
	<TD>-0289</TD>
</TR>

<TR>
	<TD>80EE004C</TD>
	<TD>01</TD>
	<TD>2A</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>7EB7491F</TD>
	<TD>202133.242</TD>
	<TD>080803</TD>
	<TD>A</TD>
	<TD>04</TD>
	<TD>2</TD>
	<TD>-0389</TD>
</TR>

<TR>
	<TD>80EE004D</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>01</TD>
	<TD>00</TD>
	<TD>39</TD>
	<TD>32</TD>
	<TD>2F</TD>
	<TD>81331170</TD>
	<TD>202133.242</TD>
	<TD>080803</TD>
	<TD>A</TD>
	<TD>04</TD>
	<TD>2</TD>
	<TD>+0610</TD>
</TR>

  </FONT>
  </TABLE>


<p>


<table width = 600 cellpadding = 8>
	<tr>
		<td valign = top>
			<img src="graphics/pulse2.gif" alt="" align="middle">
		</td>
		
		<td valign = top>
			The hardware measures times very, very well. It detects when the <a href="javascript:glossary('photomultiplier_tube',350)">PMT</a> pulse starts and ends. We can use that to caclulate <a href="javascript:glossary('pulse_width',350)"> pulse width</a>.<p>

			The first 10 columns represent "clock ticks". Ticks in columns 1 & 10 are 24 nanoseconds, ticks in 2-9 are 3/4 nanoseconds.<p>
			
			The last 6 columns provide other information. Many columns are <a href="javascript:glossary('hexadecimal_number',350)">hexadecimal numbers</a>.<p>

 		</td>
 	</tr>
 	
 	<tr>
 		<td colspan=2>
 			Column 1 indicates the tick during which everything in columns 2-9 happened.<p>
			Columns 2-9 indicate pulse start (even columns) and end (odd columns) times for channels 1-4.<p>
 			
 			Column 10 is the tick that corresponds to the GPS time in column 11.<p>
 			
 			Column 11 is the <a href="javascript:glossary('GMT',350)">GMT</a> of the last GPS update. <p>
 			
 			Column 12 is the date of the last GPS update.<p>
 			
 			Column 13 shows the validity of the last GPS update.<p>
 			
 			Column 14 shows the number of GPS satellites in view.<p>
 			
 			Columns 15 and 16 show data status (15) and time offset information (16).
 			
 			
 			
 </table>

</body>
</html>
