<html>
	<head>
		<title>
			Tutorial Lifetime Study
		</title>
		<%@ include file="include/javascript.jsp" %>

        <!-- include css style file -->
        <%@ include file="include/styletut.css" %>
        <!-- header/navigation -->
        <%
        //be sure to set this before including the navbar
        String headerType = "Library";
        %>
        <%@ include file="include/navbar_common.jsp" %>
		<p>

		<font color="#0a5ca6" size=+3>
			<b>
				Lifetime Study
			</b>
		</font>
<p>
			<center>
			
			<table width = 650 cellpadding =8>
				<tr>
					<td width = 321 valign=top>
		 				We can't tell if the second light <a HREF="javascript:glossary('pulse',350)">pulse</a> is from an electron (indicating a decay) or from the next <a HREF="javascript:glossary('muon',100)">muon</a> coming through the dectector. They both look similar to the <a HREF="javascript:glossary('photomultiplier_tube',100)">PMT</a>.
					</td>
					
					<td width = 321 valign=top>
						The only way out is to collect many, many of these "candidates" and then plot a histogram of the length between flashes. Real <a HREF="javascript:glossary('decay',350)">decays</a> will be much longer between flashes <i>and</i> have an exponential distribution with a "longish" time constant.	
					</td>
				</tr>
				
				<tr>
					<td colspan=2 valign=top align = center>
												
						<object classid="clsid:d27cdb6e-ae6d-11cf-96b8-444553540000" codebase="http://fpdownload.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0" width="504" height="216" id="muondecay2" align="middle">
<param name="allowScriptAccess" value="sameDomain" />
<param name="movie" value="flash/muondecay2.swf" />
<param name="quality" value="high" />
<param name="bgcolor" value="#ffffff" />
<embed src="flash/muondecay2.swf" quality="high" bgcolor="#ffffff" width="504" height="216" name="muondecay2" align="middle" allowScriptAccess="sameDomain" type="application/x-shockwave-flash" pluginspage="http://www.macromedia.com/go/getflashplayer" />
</object>
						
					</td>
				</tr>
				
				<tr>
					<td colspan = 2 align=right>
						Go back to the <a href="search.jsp?t=split&amp;f=analyze&amp;s=lifetime">analysis</a>
					</td>
					
					<td>
						&nbsp
					</td>
				</tr>
				
			</table>
			<p>
		</center>
	</body>
</html>

