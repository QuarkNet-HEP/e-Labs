<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<html>
	<head>
		<title>
			Tutorial Lifetime Study
		</title>
	</head>
		
	<body>
			<p>
			<div id="instructionSteps">
				You can:
				<ol>
					<li>Find some help on this page</li>
					<li>
						<e:popup href="../posters/display.jsp?type=poster&amp;name=poster_decays.data" 
							target="PossibleParticleDecays" width="700" height="510">View</e:popup> a poster 
							created using this study
					</li>
					<li>
						<e:popup href="tryit.html" target="TryIt" width="510" height="600">Try it</e:popup>: 
						Step-by-Step Instructions
					</li>
					</ol>
			</div>			
	
	<p>
			<center>
			<table width = "650" cellpadding ="8">
				<tr>
					<td colspan = "2">
						<center>
							<font color="#0a5ca6" size="+3">
								<b>
									Lifetime Study
 								</b>
							</font>
						</center>
					</td>
				</tr>
			
				<tr>
					<td width="321" valign="top">
		 				This is the analysis path for the lifetime study. One node asks "Any Decays?" What are those?
					</td>
					
					<td width="321" valign="top">
						Some cosmic rays reach earth's surface in the form of <a href="javascript:glossary('muon',100)">muons</a>. 
						These short-lived particles may stop in the <a href="javascript:glossary('counter',350)">counter</a>, 
						wait around a while and then decay into an electron and two neutrinos.
					</td>
				</tr>
				
				<tr>
					<td colspan="2" valign="top">
						<img src="../graphics/lifetimeDAG.png" alt="">
					</td>
				</tr>
								
				<tr>
					<td colspan="2" align="right">
						Want to <a href="tutorial2.jsp">know more?</a>
					</td>
				</tr>
				
				<tr>
					<td valign="top">
						<center>
							<img src="../graphics/lifetime_example.gif">
						</center>
					</td>
					
					<td valign = "top">
						<a href="javascript:glossary('muon',100)">Muon </a>
						<a href="javascript:glossary('decay',350)">decay </a> follows an exponential 
						law-just like radioactive particles and many other natural phenomenon. 
						Plots of exponents have a characteristic shape.<p>
						
						Finding the value of the exponent leads to the <a href="javascript:glossary('lifetime',100)">
						lifetime</a> of the particle-one of many characteristics that allow us to describe 
						particles. Others include mass and electric charge.<p>
						
					</td>
				</tr>
			</table>
			<p>
		</center>
	</body>
</html>

