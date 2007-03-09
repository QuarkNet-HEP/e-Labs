 <html>
	<head>
		<title>
			Tutorial Counter Performance Study
		</title>
		<%@ include file="include/javascript.jsp" %>
		<script language="JavaScript">
			<!--
			function openHist() {
			window.open("graphics/car_hist.gif");
			}
			-->
		</script>

        <!-- include css style file -->
        <%@ include file="include/style.css" %>
        <!-- header/navigation -->
<%
        //be sure to set this before including the navbar
        String headerType = "Library";
%>
        <%@ include file="include/navbar_common.jsp" %>
		</center>
	</head>
		
	<body>
		<p>
		<p>
		<center>
			You can:&nbsp
			<b>1)</b> Find some help on this page &nbsp
		 	<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=adlerperformance.data','PossibleParticleDecays', 700, 510); ">View</a> a poster created using this study&nbsp
			<b>3)</b> <a href="javascript:openPopup('tryit_performance.html','TryIt',510,600); ">Try it</a>: Step-by-Step Instructions
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
									Detector Performance Study
								</b>
							</font>
						</center>
	 				</td>
	 			</tr>
	 			
	 			<tr>
	 				<td width = 321 valign = top>
	 					This is the analysis path for the performance study. The plot shows how often the <A HREF="javascript:glossary('pulse_width',350)">pulse widths</A> were a particular value. 
					</td>
				
					<td width = 321 valign = top>
						Many, many short pulses with few longer pulses may indicate a noisy <A HREF="javascript:glossary('counter',350)">counter</a>.
					</td>
				</tr>
		
				<tr>
					<td colspan=2>
						<img src="graphics/performanceDAG.png" alt="">
					</td>
				</tr>
		
				<tr>
					<td colspan = 2 align =right>
						Want to <a href="dpstutorial2.jsp">know more?</a>
					</td>
				</tr>
		
				<tr>
					<td colspan =2>
						Inspect the plots below. Which one shows a counter with an enormous number of short pulses? Which two counters have similar performance? What would you do if you owned these four counters?
					</td>
				</tr>
		
				<tr>
					<td>
						<img src="graphics/Ballard1.gif" alt=""></td><td><img src="graphics/Ballard2.gif" alt=""> 
					</td>
				</tr>
				
				<tr>
					<td>
						&nbsp;
					</td>
					
					<td>
						&nbsp;
					</td>
				</tr>
				
				<tr>
					<td>
						<img src="graphics/Ballard3.gif" alt=""></td><td><img src="graphics/Ballard4.gif" alt="">
					</td>
				</tr>
			</table>
		</center>
	</body>
</html>

