<HTML>
<HEAD>
<TITLE>QuarkNet Detector</TITLE>
</HEAD>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="include/javascript.jsp" %>

<TABLE WIDTH=800>
<TR><TD>
<TABLE WIDTH=800 CELLPADDING=4>
<TR><td>&nbsp;</td></tr><TR><TD  bgcolor=black>
<FONT FACE=ARIAL COLOR=white SIZE=+1>
<B>Introduction to the QuarkNet cosmic ray detector.</B>
</TD></TR>
</TABLE>
<P>

  <CENTER>
 


<TABLE WIDTH=576>
<TR><TD COLSPAN=2 align="center">

  <IMG SRC="../graphics/detector.jpg" BORDER=1><BR>
  200 Series - Pre 2005 Model<BR><BR>
  <IMG SRC="../graphics/detector5000.jpg" BORDER=1><BR>
  5000 Series - 2006 Model<BR><BR> 
  <IMG SRC="../graphics/detector6000.jpg" BORDER=1><BR>
  6000 Series - 2007 Model 
  <P>
  <B>Typical QuarkNet Detector Setup</B>
  </TD></TR>
<TR><TD WIDTH=50% VALIGN=TOP>

1. Counters-scintillators, light guides, photomultiplier tubes and bases (two shown)<BR>
2. QuarkNet DAQ board<BR>
3. 5 VDC adapter<BR>
4. GPS receiver
</TD><TD VALIGN=TOP>
5. GPS extension cable<BR>
6. RS-232 cable (to link to computer serial port)<BR>
7. Optional RS-232 to USB adapter (to link to computer USB port instead of serial port)<BR>
8. Lemo signal cables<BR>
9. Daisy-chained power cables
</TD></TD>
<TR><TD COLSPAN=2>
For this setup, the DAQ board takes the signals from the counters and provides signal processing 
and logic basic to most nuclear and particle physics experiments. The DAQ board can anlyze signals 
from up to four PMTs. (We show two in the photo.) The board produces a record of output data 
whenever the PMT signal meets a pre-defined trigger criterion (for example, when two or more 
PMTs have signals above some predetermined threshold voltage, within a certain time window). 
The output data record, which can be sent via a standard RS-232 serial interface to any PC, 
contains temporal information about the PMT signals. This information includes: how many channels 
had above-threshold signals, their relative arrival times (precise to 0.75 ns), and the starting 
and stopping times for each detected pulse. In addition, an external GPS receiver module provides 
the absolute <a name="glossary_ref" href="#glossary_ref" title="Glossary: " onclick="javascript:window.open('../references/display.jsp?type=glossary&name=UTC', 'glossary', 'width=300, height=250, scrollbars=false, toolbar=false, menubar=fale, status=false, resizable=true, title=true');">UTC</a> time of each trigger, accurate to about 50 ns. 
This allows counter arrays using separate DAQ boards such as different schools in a wide-area 
array or two sets of counters at the same site to correlate their timing data. Keyboard commands 
allow you to define trigger criteria and retrieve additional data, such as counting rates, 
auxiliary GPS data, and environmental sensor data (temperature and pressure). 
<P>
 <B>Want more information? Users Manual <A HREF="http://quarknet.fnal.gov/toolkits/ati/det-user.pdf">pdf</A> - <A HREF="data.jsp">Explanation of the Data</A>
</TD></TR>
</TABLE>
<HR></CENTER>


</BODY>
</HTML>

