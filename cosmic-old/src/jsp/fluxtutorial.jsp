<html>
	<head>
		<title>
			Tutorial Flux Study
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
						<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=adler_flux.data','Possible Particle Decays', 700, 510); ">View</a> a poster created using this study&nbsp
						<b>3)</b> <a href="javascript:openPopup('tryit_flux.html','TryIt',510,600); ">Try it</a>: Step-by-Step Instructions
			</center>			
	
			<p>
			<center>        
			<p>
			<p>
			<table width = 650 cellpadding =8>
				<tr>
					<td colspan = 2>
						<center>
							<font color="#0a5ca6" size=+3>
								<b>
	 								Flux Study
	 							</b>
	 						</font>
	 					</center>
	 				</td>
	 			</tr>
				
				
				<tr>
		 			<td width = 321 valign = top>
		 				This is the analysis path for the <a HREF="javascript:glossary('flux',100)">flux</a> study. 
					</td>
					
					<td width = 321 valign = top>
						You may be interested in looking at flux throughout the day or year to see if there are changes in the rain of these particles.<p>
					</td>
				</tr>
				
				<tr>
					<td colspan = 2>
						<img src="graphics/fluxDAG.png" align="middle">
					</td>
				</tr>
	
				<tr>
			
					<td valign=top>
						<img src="graphics/flux.png" width = 294 height = 304>
					</td>
			
					<td valign=top>
						&nbsp<p>
											
						The plot to the left shows <a HREF="javascript:glossary('flux',350)">flux</a> measurements for <a HREF="javascript:glossary('detector',350)">detector # 180 </a> on 8 August 2003. The measurements start around <a HREF="javascript:glossary('GMT',100)">17:19</a> and end 36 minutes later at <a HREF="javascript:glossary('GMT',100)">17:45.</a><p>
						One interesting feature occurs between <a HREF="javascript:glossary('GMT',100)">17:31</a> and <a HREF="javascript:glossary('GMT',100)">17:33</a>-the <a HREF="javascript:glossary('flux',100)">flux</a> drops from 20,000 units to very small values in a short time. What might cause this? Is the effect real or is it some artifact of the way this file was plotted? Is there a way that you can tell?
					</td>
				</tr>
			</table>
		</center>
	</body>
</html>

