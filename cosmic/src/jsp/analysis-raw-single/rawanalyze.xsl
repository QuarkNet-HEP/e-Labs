<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
<style type="text/css">
   table {  border: 1px solid black; cell-padding: 5px; }
   td { border: 1px solid black; cell-padding: 10px; }
</style>
 <table>
  <tr>
   <td colspan="3" align="center">
   	<strong>
    	 <xsl:value-of select="/file/filename"/>
   	</strong>
   </td>
  </tr>
  <tr>
   <td align="center">
    <a href="#total_events">
     total events
    </a>
   </td>
   <td align="center">
    <a href="#total_lines">
     total lines
    </a>
   </td>
   <td align="center">
    <a href="#gatewidth">
     gatewidth
    </a>
   </td>
  </tr>
  <tr>
   <td align="center">
    <xsl:value-of select="/file/events"/>
   </td>
   <td align="center">
    <xsl:value-of select="/file/lines"/>
   </td>
   <td align="center">
    <xsl:value-of select="/file/gatewidth"/> ns
   </td>
  </tr>
 </table>
 <br/>
 <table>
 	<tr><td>
		Average hits per Event: <xsl:value-of select="/file/average"/>
	</td></tr>
 </table>
 <br/>
 <br/>
 <table border="1">
  <tr>
   <td>
   </td>
   <td colspan="5" align="center">
    Channel
   </td>
  </tr>
  <tr>
   <td> 
   </td>
   <xsl:for-each select="/file/channel">
    <td align="center">
     <xsl:value-of select="num"/>
    </td>
   </xsl:for-each>
  </tr>
  <tr>
   <td>
    Total Hits
   </td>
   <xsl:for-each select="/file/channel">
    <td align="center">
     <xsl:value-of select="hits/count"/>
    </td>
   </xsl:for-each>
  </tr>
  <tr>
   <td>
    <a href="#REorphan">
     Rising Orphans
    </a>
   </td>
   <xsl:for-each select="/file/channel">
    <td align="center">
     <a>
      <xsl:attribute name="href">
       ../data/view.jsp?filename=<xsl:value-of select="/file/filename"/>&#38;type&#61;data&#38;menu&#61;yes&#38;get&#61;data&#38;highlight&#61;yes&#38;line&#61;<xsl:value-of select="orphan/rising/line"/>
      </xsl:attribute>
      <xsl:value-of select="orphan/rising/count"/></a> - <xsl:value-of select="orphan/rising/percent"/>%
    </td>
   </xsl:for-each>
  </tr>
  <tr>
   <td>
    <a href="#FEorphan">
     Falling Orphans
    </a>
   </td>
   <xsl:for-each select="/file/channel">
    <td align="center">
     <a>
      <xsl:attribute name="href">
       ../data/view.jsp?filename=<xsl:value-of select="/file/filename"/>&#38;type&#61;data&#38;menu&#61;yes&#38;get&#61;data&#38;highlight&#61;yes&#38;line&#61;<xsl:value-of select="orphan/falling/line"/>
      </xsl:attribute>
      <xsl:value-of select="orphan/falling/count"/></a> - <xsl:value-of select="orphan/falling/percent"/>%    </td>
   </xsl:for-each>
  </tr>
  <tr>
   <td>
    <a href="#FEbeforeRE">
     Falling before Rising edge
    </a>
   </td>
   <xsl:for-each select="/file/channel">
    <td align="center">
     <a>
      <xsl:attribute name="href">
       ../data/view.jsp?filename=<xsl:value-of select="/file/filename"/>&#38;type&#61;data&#38;menu&#61;yes&#38;get&#61;data&#38;highlight&#61;yes&#38;line&#61;<xsl:value-of select="FBR/line"/>
      </xsl:attribute>
      <xsl:value-of select="FBR/count"/></a> - <xsl:value-of select="FBR/percent"/>%
    </td>
   </xsl:for-each>
  </tr>
  <tr>
   <td>
    <a href="#chan_coincidences">
     Coincidences within a single channel
    </a>
   </td>
   <xsl:for-each select="/file/channel">
    <td align="center">
     <xsl:for-each select="fold">
      <xsl:value-of select="num"/>: <xsl:value-of select="count"/><br/>
     </xsl:for-each>
    </td>
   </xsl:for-each>
  </tr>
 </table>
 <br/>
 <table border="1">
  <tr>
   <td colspan="3">
    <a href="#event_chan_coincidences">
     Strings of coincidences
    </a>
   </td>
  </tr>
  <tr>
   <td>
    String
   </td>
   <td>
    Total Number
   </td>
  </tr>
  <xsl:for-each select="/file/coincidence/multichan/sequence">
   <tr>
    <td>
     <xsl:value-of select="string"/>
    </td>
    <td>
     <xsl:variable name="id" select="count/@id"/>
     <font>
      <xsl:if test="$id = 'max'">
       <xsl:attribute name="color">
        #009900
       </xsl:attribute>
      </xsl:if>
     <xsl:value-of select="count"/>
     </font>
    </td>
   </tr>
  </xsl:for-each>
 </table>
 <br/>
 <table border="1">
  <tr>
   <td colspan="2">
    <a href="#event_coincidences">
     Total Coincidences
    </a>
   </td>
  </tr>
  <tr>
   <td>
    Coincidence
   </td>
   <td>
    Total Number
   </td>
  </tr>
  <xsl:for-each select="/file/coincidence/fold">
   <tr>
    <td>
     <xsl:value-of select="num"/>
    </td>
    <td>
     <a>
      <xsl:attribute name="href">
       ../data/view.jsp?filename=<xsl:value-of select="/file/filename"/>&#38;type&#61;data&#38;menu&#61;yes&#38;get&#61;data&#38;highlight&#61;yes&#38;line&#61;<xsl:value-of select="line"/>
      </xsl:attribute>
      <xsl:value-of select="count"/>
     </a>
    </td>
   </tr>
  </xsl:for-each>
 </table>
 <br/>
 <table border="1">
  <tr>
   <td colspan="3" align="center">
    <a href="#gps">
     GPS information
    </a>
   </td>
  </tr>
  <tr>
   <td>
   </td>
   <td>
    Valid GPS
   </td>
   <td>
    Invalid GPS
   </td>
  </tr>
  <tr>
   <td>
    Datalines
   </td>
   <td>
    <xsl:value-of select="/file/gps/good/byline/count"/> - 
    <xsl:value-of select="/file/gps/good/byline/percent"/>%
   </td>
   <td>
    <xsl:value-of select="/file/gps/bad/byline/count"/> - 
    <xsl:value-of select="/file/gps/bad/byline/percent"/>%
   </td>
  </tr>
  <tr>
   <td>
    Events
   </td>
   <td>
    <xsl:value-of select="/file/gps/good/byevent/count"/> - 
    <xsl:value-of select="/file/gps/good/byevent/percent"/>%
   </td>
   <td>
    <xsl:value-of select="/file/gps/bad/byevent/count"/> - 
    <xsl:value-of select="/file/gps/bad/byevent/percent"/>%
   </td>
  </tr>
  <tr>
   <td>
    <a href="#no_CPLD_update">
     No CPLD update
    </a>
   </td>
   <td colspan="2" align="center">
     <a>
      <xsl:attribute name="href">
       ../data/view.jsp?filename=<xsl:value-of select="/file/filename"/>&#38;type&#61;data&#38;menu&#61;yes&#38;get&#61;data&#38;highlight&#61;yes&#38;line&#61;<xsl:value-of select="file/gps/noupdate/line"/>
      </xsl:attribute>
    <xsl:value-of select="/file/gps/noupdate/count"/></a> - 
    <xsl:value-of select="/file/gps/noupdate/percent"/>%
   </td>
  </tr>
 </table>


 <br/>
 <br/>
 <hr/>
 <b><u>
  Descriptions
 </u></b>
 <p>
 <a name="total_events"></a>
 <u><i>total events:</i></u>
 The total number of times we opened and closed the "gatewidth" to look for hits (rising-falling edge pairs). So an event is defined as starting at time <i>t</i> and ending at time <i>t+gatewidth</i>.
 </p>
 <p>
 <a name="total_lines"></a>
 <u><i>total lines:</i></u>
 The total number of lines in the actual file.
 </p>
 <p>
 <a name="gatewidth"></a>
 <u><i>gatewidth:</i></u>
 The number of nanoseconds in an "event". A gatewidth defines a timeframe for which we log events as being part of the same "coincidence". 
 </p>
 <p>
 <a name="avg_hits"></a>
 <u><i>Average hits per event:</i></u>
 The average number of hits for an event (number of rising-falling edge pairs for all channels within one "event").
 </p>
 <p>
 <a name="REorphan"></a>
 <u><i>Rising Orphans:</i></u><br/>
 7957DD6B 00 01 00 01 <b>32</b> 01 00 01 79647272 230736.331 210703 A 04 0 +0522<br/>
 7DDF35FD <b>80</b> 01 00 01 25 36 00 01 7BE03ACE 230738.331 210703 A 04 0 -0485<br/>
 Occurs when a rising edge never finds a matching falling edge. This usualy happens when the on-board gatewidth closes and no more hits are registered before a falling edge is detected.<br/>
 Note: the specified line is the *last* line in the file to have this property. Also, this is the line where we KNOW the edge is an orphan based on the 2nd word.
 </p>
 <p>
 <a name="FEorphan"></a>
 <u><i>Falling Orphans:</i></u><br/>
 EDC898BA BC 01 00 01 00 01 2F 33 ED29618A 172621.813 190803 A 05 2 +0021<br/>
 EDC898BB 01 22 21 31 00 01 01 <b>20</b> ED29618A 172621.813 190803 A 05 0 +0021<br/>
 Occurs when a falling edge happens without a matching rising edge happening before it.<br/>
 Note: the specified line is the *last* line in the file to have this property.
 </p>
 <p>
 <a name="FEbeforeRE"></a>
 <u><i>Falling before Rising edge:</i></u><br/>
 FF9B9D22 A1 33 20 37 00 01 00 01 FE6CD57C 170551.872 190803 A 06 0 -0057<br/>
 00BF5EA7 <b>25 22</b> 01 33 00 01 01 32 00E89DD2 170551.872 190803 A 06 2 +0942<br/>
 The CPLD time for the falling edge is less than the rising edge.<br/>
 Note: the specified line is the *last* line in the file to have this property. Also, this is the line where we KNOW the falling edge comes before the rising edge.
 </p>
 <p>
 <a name="chan_coincidences"></a>
 <u><i>Coincidences within a single channel:</i></u>
 Number of times a single channel fired n-times within a "event".
 </p>
 <p>
 <a name="event_chan_coincidences"></a>
 <u><i>Strings of coincidences:</i></u>
 Number of times a specific string of channels fired. For example, the string 423 represents channel 4 followed by 2 followed by 3 firing all within a single "event".<br/>
 Note: it's possible to "guess" what order the counters were setup in based on these totals.
 </p>
 <p>
 <a name="event_coincidences"></a>
 <u><i>Total Coincidences:</i></u>
 Sum total of all coincidence strings of length n (so if n=5, we had all 5 hits in this event).<br/>
 Note: that the indicated line number is the END of the event.
 </p>
 <p>
 <a name="gps"></a>
 <u><i>Valid/Invalid GPS:</i></u>
 A GPS line is valid if the 13th word is "A" (and invalid if it is "V"). A GPS event is valid if the first line in the event has "A" in the 13th word.
 </p>
 <p>
 <a name="datalines"></a>
 <u><i>Datalines:</i></u>
 A single line from the file. 73 characters, 16 words.
 </p>
 <p>
 <a name="events"></a>
 <u><i>Events:</i></u>
 Starts at time <i>t</i> ends at time <i>t+gatewidth</i>
 </p>
 <p>
 <a name="no_CPLD_update"></a>
 <u><i>No CPLD update:</i></u><br/>
 026B9F5F AB 3C 2B 3D 00 01 00 01 <b>02039F9F 171753.837</b> 190803 A 07 0 +0941<br/>
 029F38AD BA 3F 3A 01 00 01 00 01 <b>02039F9F 171754.837</b> 190803 A 07 2 -0057<br/>
 The gps CPLD doesn't update when we see a new second.
 </p>
</xsl:template>
</xsl:stylesheet>

