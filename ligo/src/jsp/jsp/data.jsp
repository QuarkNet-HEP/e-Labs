<HTML>
<HEAD>
<TITLE>Data from DAQ board</TITLE>
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
<B>Introduction to data from the QuarkNet detector.</B>
</TD></TR>
</TABLE>
<P>

  <CENTER>
<TABLE BORDER=1>
<TR><TD>
  <TABLE CELLPADDING=2>
   <FONT SIZE =+1 FACE=ARIAL>
  <TR><TD>
  80EE0049</TD><TD>80</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>38</TD><TD>01</TD><TD>3C</TD><TD>01</TD><TD>7EB7491F</TD><TD>202133.242</TD><TD>080803</TD><TD>A</TD><TD>04</TD><TD>2</TD><TD>-0390<TD><TR>
<TR><TD>
  80EE004A</TD><TD>24</TD><TD>3D</TD><TD>25</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>7EB7491F</TD><TD>202133.242</TD><TD>080803</TD><TD>A</TD><TD>04</TD><TD>2</TD><TD>-0389
</TD></TR>
<TR><TD>
  80EE004B</TD><TD>21</TD><TD>01</TD><TD>00</TD><TD>23</TD><TD>00</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>7EB7491F</TD><TD>202133.424</TD><TD>080803</TD><TD>A</TD><TD>04</TD><TD>2</TD><TD>-0289
  </TD></TR>
<TR><TD>
  80EE004C</TD><TD>01</TD><TD>2A</TD><TD>00</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>7EB7491F</TD><TD>202133.242</TD><TD>080803</TD><TD>A</TD><TD>04</TD><TD>2</TD><TD>-0389
  </TD></TR>
<TR><TD>
  80EE004D</TD><TD>00</TD><TD>01</TD><TD>00</TD><TD>01</TD><TD>00</TD><TD>39</TD><TD>32</TD><TD>2F</TD><TD>81331170</TD><TD>202133.242</TD><TD>080803</TD><TD>A</TD><TD>04</TD><TD>2</TD><TD>+0610  
 </TD></TR>
  </FONT>
  </TABLE>
  
  </TD></TR>
  </TABLE>
  <P>
  <TABLE WIDTH=600 cellpadding=4>
  <TR><TD COLSPAN=2>
  <B>Data Words for a Single Event</B>
  <P>

An explanation of the meaning of each of the data "words" that appear for a single event. <B>It is not imperative to understand these words in order to collect and analyze data</B>, but understanding these words can help as you evaluate the quality of your data. 
<P>
The datastream from the DAQ board is in ASCII format. Each data line contains 16 words.  Words 1-9 are in hex format. The data shown is for a single event; a single event can span several lines of data!

  </TD></TR>
<TR><TD WIDTH=292 VALIGN=TOP>
<B>Word 1:</B> A 32-bit trigger count of the 41.66 MHz CPLD clock mounted on the DAQ board with a range from 00000000...FFFFFFFF. Its resolution (1 LSB increment) is 24 ns.<SUP>1</SUP> A trigger count of 00000000 means that the DAQ card is still in the initialization phase, i.e., the GPS receiver has not started to generate 1PPS pulses yet. Do not use the initial data until the trigger count becomes non-zero!
<P>
<B>Word 2:</B> TMC count of the Rising Edge at input 0 (RE0). It is also the trigger tag. The format used is shown below:
<P STYLE="margin-left: 10px">
bits 0-4 = TMC count of rising edge, resolution = 0.75 ns (=24 ns/32)<BR>
bit 5 = channel edge tag (1 = valid rising edge, 0 = no rising edge)<BR>
bit 6 = not used, always 0<BR>
bit 7 = trigger tag (1 = new trigger, start of a new event; 0 = follow-up data of a trigger event
<P>
<B>Word 3:</B> TMC count of Falling Edge at input 0 (FE0). The format used is shown below:
<P STYLE="margin-left: 10px">
bits 0-4 = TMC count of falling edge<BR>
bit 5 = channel edge tag (1 = valid falling edge, 0 = no falling edge)<BR>
bits 6-7 = not used, always 0.
<P>
<B>Word 4:</B> TMC count of rising edge at input 1 (RE1); same format as RE0, except bit 7 is always 0.
<P>
<B>Word 5:</B> TMC count of falling edge at input 1 (FE1); same format as FE0.
<P>
<B>Word 6:</B> TMC count of rising edge at input 2 (RE2); same format as RE1.
<P>
<B>Word 7:</B> TMC count of falling edge at input 2 (FE2); same format as FE1.
<P>
<B>Word 8:</B> TMC count of rising edge at input 3 (RE3); same format as RE1.
<P>
<B>Word 9:</B> TMC count of falling edge at input 3 (FE3); same format as FE1.
<P>

<SUP>1</SUP> <FONT SIZE=-1> 24.00 ns if the CPLD clock is exactly 41666666.67 Hz. The actual CPLD frequency of each card is usually tuned within ±30 Hz of the target frequency of 41666667 Hz. Generally, an Hz drift from the target CPLD frequency result in accuracy errors of up to n*24 ns. For example, a 30 Hz drift means that the accuracy time error has a range of ±720 ns if exactly 24.00 ns are assumed for a CPLD clock tick time. It is reasonable to assume that an error within ±1000 ns is acceptable for a school network if the schools are more than 1 mile apart from each other.
<P>
The CPLD clock frequency fluctuates slightly over time, de-pending on temperature changes and oscillator ageing drifts. Therefore, in order to achieve high accuracy (±50 ns) in computing the absolute trigger times, you need to poll the current CPLD frequency at a regular basis (say once every 5 minutes) with command DG (Display GPS data). If the event rate is high enough (at least 1 event per 100 seconds), the CPLD frequency can be computed from the 1PPS counter numbers of consecutive events.</FONT>

</TD><TD VALIGN=TOP WIDTH=292>

<B>Word 10:</B> A 32-bit CPLD count of the most recent 1PPS (1 pulse per second) time mark from the <a href="javascript:glossary('GPS')">GPS</a> receiver. This hex word ranges from 00000000...FFFFFFFF and has a resolution of 24 ns just like word 1
<P>
<B>Word 11:</B> <a href='javascript:glossary("UTC")'>UTC</a> time of most recent GPS re-ceiver data update. Although one update is sent each second, it is asynchronous with the 1PPS pulse. The format used is shown below:
<P STYLE="margin-left: 10px">
	HHMMSS.mmm<BR>
where: HH = hour [00...23]<BR>
MM = minute [00...59]<BR>
SS = second [00...59]<BR>
mmm = millisecond [000...999]
<P>


<B>Word 12:</B> UTC date of most recent GPS re-ceiver data update. The format used is shown below:
<P STYLE="margin-left: 10px">
	ddmmyy<BR>
where: dd = day of month [01...31]<BR>
mm = month [01...12]<BR>
yy = year [00...99]<BR>
e.g. 03=2003]<BR>
<P>
<B>Word 13:</B> A GPS valid/invalid flag.<BR> 
A = valid (GPS data OK),<BR>
V = invalid (insufficient satellite lock for 3-D positioning, or GPS receiver is in initializing phase); time data might be OK if number of GPS satellites is 3 or more and previous GPS status was "A" (valid) within the last minute.
<P>
<B>Word 14:</B> The number of GPS satellites visible for time and position information. This is a decimal number between 00...12.
<P>
<B>Word 15: </B>This hex word is a DAQ status flag. The format used is shown below:
<P STYLE="margin-left: 10px">
bit 0: 0 = OK<BR>
1 = 1PPS interrupt pending (Warning flag: If DAQ card is busy, then 1PPS count might lag be-hind or get mismatched.)<BR>
 bit 1: 0  = OK<BR>
 1 = trigger interrupt pending (pos-sibly high trigger rate; if con-tinues, then data might be cor-rupted.)<BR>
bit 2: 0 = OK<BR>
1 = GPS data possibly corrupted while DAQ uC was/is busy.<BR>
bit 3: 0 = OK<BR>
1 = Current or last 1PPS rate is not within 41666666 ±50 CPLD clock tick.s (This is a result of a GPS glitch, the DAQ uC being busy, or the CPLD oscillator not tuned correctly.)
<P>
<B>Word 16:</B> The time delay in milliseconds between the 1PPS pulse and the GPS data interrupt. A positive number means 1PPS pulse is ahead of GPS data, and negative number means GPS data is ahead of 1PPS. To get the actual GPS time to the nearest second, round (word 11 + word 16/1000) to nearest full second. This gives the actual GPS time at the last 1PPS pulse. (The same uncertainty comments apply here as in word 1.) 


</TD></TD>

</TABLE>
<HR></CENTER>


</BODY>
</HTML>

