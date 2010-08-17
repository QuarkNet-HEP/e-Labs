<html>
	<head>
		<title>
			Data displays with multiple events
		</title>
		<%@ include file="../jsp/include/javascript.jsp" %>
	</head>
	
	<link rel="stylesheet"  href="../include/styletut.css" type="text/css">

	<body onLoad="focus()" background="../graphics/Quadrille.gif">
    			 		<h2>
    	 					Data displays with multiple events
		    	 		</h2>
		<table WIDTH=600>
	    	<tr>
	    		<td>
   		    		    <p>
		    	 		LHC experiments record data in runs, which may range from a few minutes to weeks depending on the condition of a detector. (Check times- I made them up.)</p>

						<p>When operating at peak capacity, the LHC will produce 1.8 gigabytes of data or 600 million collisions per second at the four main experiments, far more data than the experiments can capture. Experiments use a system of hardware and software triggers, a sort of spam filter that selects only the most interesting collisions, roughly 100 per second, to save for analysis. (Can we get overall numbers for CMS - the 100 per second is from CMS.)</p>
						<p>
						
						<table><tr><td> <a href="javascript:showRefLink('../graphics/fig02-23.gif',641,641)"><img src="../graphics/fig02-23-s.gif"></a></td><td><p>Physicists identify and classify the events into different event types. By combining lots of events of the same type, physicists can determine the properties of particles. For example, this histogram shows the mass of the Z particle by histogramming the masses of the two electrons that can result from the decay of a Z particle. </td></tr></table>
						</p>

						<p>How do particle physicists analyze data lots of events at once? They build <a href="http://en.wikipedia.org/wiki/Histogram">histograms</a> with the measured values of particles in
						events of the same type. Examples of measured values are the mass, the energy, and the momentum.</p>

    			 	</p>
    			 	
    			 	<table>
    			 	<tr><td width="400">
					<p>Included in the interesting data are both signal and background events. Signal events show up as a "bump" in the background plot because more events are produced than expected. In a mass plot, bumps will show up around the masses of particles, say J/Psi, 3.1 GeV, or Upsilon, 9.5 GeV, in data between 0 and 10 GeV.</p> 

					<p>See the plot from the Upsilon discovery paper. The peak at about 9.5 GeV is due to the contribution of the Upsilon.</p>
					
					<p>Why is the mass contribution a bump rather than a line at the "correct" value? A measurement in the subatomic world differs from a measurement in our everyday world. It is not a precise value, but a range of values, reflecting the probability of each value occurring. This probability is the bump in the curve resulting from measurement error and particle lifetime.</p></td><td><img src="../graphics/upsilon.gif"></td></tr></table><p>
					<p>Be sure to go back to the  <a href="javascript:reference('interpret data',650,400)">interpret data reference</a> and fill in your logbook.</p>
					
				</td>
			</tr>
   		
   			<tr>
   				<td align="right">
   					<HR><A HREF="javascript:window.close();">Close Window</font></A>
   				</td>
   			</tr>
   		</table>
	</body>
</html>

    
