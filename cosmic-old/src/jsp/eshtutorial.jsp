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
<center>
				You can:&nbsp
						 <b>1) </b> Find some help on this page &nbsp
			<!--
						<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=adler_flux.data','Possible Particle Decays', 700, 510); ">View</a> a poster created using this study&nbsp
-->	
						<b>2)</b> <a href="javascript:openPopup('tryit_shower.html','TryIt',520,600);">Try it</a>: Step-by-Step Instructions
			</center>		
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
		 				This is the analysis path for the <a href="javascript:glossary('shower',350)">shower</a> study. Showers can pepper an large area of Earth's surface in a very tiny window of time. They can be rare, especially if the area you are looking in is large.
					</td>
					
					<td width = 321 valign = top>
						The many particles a shower light up the detector's <a HREF="javascript:glossary('photomultiplier_tube',350)">PMTs</a> with many <a HREF="javascript:glossary('pulse',350)">pulses</a> one after another. The more particles in the shower, the larger area it covers, the more interesting it is.
					</td>
				</tr>
				
				<tr>
					<td valign=top colspan =2 >
						<img src="graphics/showerDAG.png" alt="">
					</td>
				</tr>
				
				<tr>
					
					<td valign=top>
						In the event shown on the right, the electronics captured 12 <a HREF="javascript:glossary('photomultiplier_tube',350)">photomultiplier</a> signals. These signals came from three different locations. Each location contributed four pulses to the event.<p>
					
						<a HREF="javascript:glossary('pulse',350)">Pulses</a> are  marked by the red polygons. The polygon's height above the x-y plane (the green spike) tells us the amount of time between the beginning of the shower and the start of the PMT pulse at that x-y location. A polygon with no tail represents the beginning of the event. <p>
	
						We said there are 12 pulses in the event. The plot only shows three. Where are the other nine?<p>

						<p align = right>
							Want to <a href="eshtutorial2.jsp">know more?</a>
					
					</td>
					
					<td  valign = top >
						<img src="graphics/shower.png" height= 350 width = 350 alt="">
					</td>
				
				</tr>
				
				
			</table>
		</center>
	</body>
</html>

