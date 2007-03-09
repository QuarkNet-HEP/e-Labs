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
	</head>
		
	<body>
			<p>
			<p>
			<center>
				You can:&nbsp
						 <b>1) </b> Find some help on this page &nbsp
						<b>2)</b> <a href="javascript:openPopup('displayPoster.jsp?type=poster&amp;posterName=poster_decays.data','PossibleParticleDecays', 700, 510); ">View</a> a poster created using this study&nbsp
						<b>3)</b> <a href="javascript:openPopup('tryit_lifetime.html','TryIt',510,600); ">Try it</a>: Step-by-Step Instructions
			</center>			
	
	<p>
			<center>
			<table width = 650 cellpadding =8>
				<tr>
					<td colspan = 2>
						<center>
							<font color="#0a5ca6" size=+3>
								<b>
									Lifetime Study
 								</b>
							</font>
						</center>
					</td>
				</tr>
			
				<tr>
					<td width = 321 valign=top>
		 				This is the analysis path for the lifetime study. One node asks "Any Decays?" What are those?
					</td>
					
					<td width = 321 valign=top>
						Some cosmic rays reach earth's surface in the form of <a href="javascript:glossary('muon',100)">muons</a>. These short-lived particles may stop in the <a href="javascript:glossary('counter',350)">counter</a>, wait around a while and then decay into an electron and two neutrinos.
					</td>
				</tr>
				
				<tr>
					<td colspan=2 valign=top>
						<img src="graphics/lifetimeDAG.png" alt="">
					</td>
				</tr>
								
				<tr>
					<td colspan=2 align="right">
						Want to <a href="ltimetutorial2.jsp">know more?</a>
					</td>
				</tr>
				
				<tr>
					<td valign=top>
						<center>
							<img src="graphics/lifetime_example.gif">
						</center>
					</td>
					
					<td valign = top>
						<br>
						<br>
						<a HREF="javascript:glossary('muon',100)">Muon </a><a HREF="javascript:glossary('decay',350)">decay </a> follows an exponential law-just like radioactive particles and many other natural phenomenon. Plots of exponents have a characteristic shape.<p>
						
						Finding the value of the exponent leads to the <a HREF="javascript:glossary('lifetime',100)">lifetime</a> of the particle-one of many characteristics that allow us to describe particles. Others include mass and electric charge.<p>
						
					</td>
				</tr>
			</table>
			<p>
		</center>
	</body>
</html>

