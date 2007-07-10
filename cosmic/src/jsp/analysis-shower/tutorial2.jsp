<html>
	<head>
		<title>
			Tutorial Shower Study
		</title>
		<%@ include file="include/javascript.jsp" %>

        <!-- include css style file -->
        <%@ include file="include/style.css" %>
        <!-- header/navigation -->
        <%
        //be sure to set this before including the navbar
        String headerType = "Library";
        %>
        <%@ include file="include/navbar_common.jsp" %>
    </head>
    
    <body>
		<p>
		<p>
			<!--
<center>
				You can:&nbsp
						 <b>1) </b> Find some help on this page &nbsp
						<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=adler_flux.data','Possible Particle Decays', 700, 510);">View</a> a poster created using this study&nbsp
						<b>3)</b> <a href="javascript:openPopup('tryit_flux.html','TryIt',510,600);">Try it</a>: Step-by-Step Instructions
			</center>		
-->	
		<center>	
			<p>
				<table width = 650 cellpadding =8>
				<tr>
					<td colspan = 2>
						<center>
							<font color="#0a5ca6" size=+3>
								<b>
	 								Shower Study
	 							</b>
	 						</font>
	 					</center>
	 				</td>
	 			</tr>
				
				
				<tr>
		 			<td width = 321 valign = top>
		 				<img src="graphics/shower.png" height= 350 width = 350 alt="">
					</td>
					
					<td width = 321 valign = top>
						The plot shows only three of the 12 <a HREF="javascript:glossary('pulse',350)">pulses</a>. How did we know that there were 12? Take a look at the data table (you'll see a data table for each shower candidate that meets your input parameters): <p>


							<table cellspacing="0" cellpadding="2" border="0">
                <tr>
                    <td align="center">
                        East/West
                    </td>
                    <td align="center">
                        North/South
                    </td>
                    <td align="center">
                        Time
                    </td>
                    <td align="center">
                        Detector
                    </td>
                    <td align="center">
                        Channel
                    </td>
                </tr>
<tr>

                    <td align="center">
                        3.0
                    </td>
                    <td align="center">
                        3.0
                    </td>
                    <td align="center">
                        0.0
                    </td>
                    <td align="center">
                        141
                    </td>
                    <td align="center">
                        1
                    </td>
                </tr>
<tr bgcolor="#CCFFBB">

                    <td align="center">
                        7837.1
                    </td>
                    <td align="center">
                        41968.2
                    </td>
                    <td align="center">
                        7287679.4
                    </td>
                    <td align="center">
                        119
                    </td>
                    <td align="center">
                        4
                    </td>
                </tr>
<tr>

                    <td align="center">
                        7831.1
                    </td>
                    <td align="center">
                        41974.2
                    </td>
                    <td align="center">
                        7287681.7
                    </td>
                    <td align="center">
                        119
                    </td>
                    <td align="center">
                        2
                    </td>
                </tr>
<tr bgcolor="#CCFFBB">

                    <td align="center">
                        7831.1
                    </td>
                    <td align="center">
                        41968.2
                    </td>
                    <td align="center">
                        7287681.7
                    </td>
                    <td align="center">
                        119
                    </td>
                    <td align="center">
                        3
                    </td>
                </tr>
<tr>

                    <td align="center">
                        7837.1
                    </td>
                    <td align="center">
                        41974.2
                    </td>
                    <td align="center">
                        7287686.9
                    </td>
                    <td align="center">
                        119
                    </td>
                    <td align="center">
                        1
                    </td>
                </tr>
<tr bgcolor="#CCFFBB">

                    <td align="center">
                        7837.1
                    </td>
                    <td align="center">
                        41968.2
                    </td>
                    <td align="center">
                        7287704.2
                    </td>
                    <td align="center">
                        119
                    </td>
                    <td align="center">
                        4
                    </td>
                </tr>
<tr>

                    <td align="center">
                        7831.1
                    </td>
                    <td align="center">
                        41974.2
                    </td>
                    <td align="center">
                        7287734.2
                    </td>
                    <td align="center">
                        119
                    </td>
                    <td align="center">
                        2
                    </td>
                </tr>
<tr bgcolor="#CCFFBB">

                    <td align="center">
                        1192.2
                    </td>
                    <td align="center">
                        34366.3
                    </td>
                    <td align="center">
                        8820242.2
                    </td>
                    <td align="center">
                        150
                    </td>
                    <td align="center">
                        3
                    </td>
                </tr>
<tr>

                    <td align="center">
                        1192.2
                    </td>
                    <td align="center">
                        34372.3
                    </td>
                    <td align="center">
                        8820243.7
                    </td>
                    <td align="center">
                        150
                    </td>
                    <td align="center">
                        2
                    </td>
                </tr>
<tr bgcolor="#CCFFBB">

                    <td align="center">
                        1192.2
                    </td>
                    <td align="center">
                        34366.3
                    </td>
                    <td align="center">
                        8820313.4
                    </td>
                    <td align="center">
                        150
                    </td>
                    <td align="center">
                        3
                    </td>
                </tr>
<tr>

                    <td align="center">
                        1192.2
                    </td>
                    <td align="center">
                        34366.3
                    </td>
                    <td align="center">
                        8820390.7
                    </td>
                    <td align="center">
                        150
                    </td>
                    <td align="center">
                        3
                    </td>
                </tr>
<tr bgcolor="#CCFFBB">

                    <td align="center">
                        1192.2
                    </td>
                    <td align="center">
                        34366.3
                    </td>
                    <td align="center">
                        8820503.2
                    </td>
                    <td align="center">
                        150
                    </td>
                    <td align="center">
                        3
                    </td>
                </tr>
                </table>
                			<p>
                			You can see that the event fired PMTs in three <a HREF="javascript:glossary('detector',350)">detectors</a>: 141, 119 and 150. <p>

Look at the amount of time between the <a HREF="javascript:glossary('pulse',350)">pulses</a> in detector 119. How much time elapsed between the first and last pulses in that detector?

                
                
					</td>
				</tr>
				
				<tr>
					<td valign=top colspan =2 >
					The plot can tell us that detector 141 fired first then 119 and 150 fired last. The table can give us much more information. Does this event candidate look like a shower to you?

<p align = right>
							Want to <a href="eshtutorial3.jsp">know more?</a>
					</td>
				</tr>
				
				<tr>
					
					<td valign=top>

					</td>
					
					<td  valign = top >
						
					</td>
				
				</tr>
				
				
			</table>
			
		</center>
	</body>
</html>

