<html>
	<head>
		<title>
			LIGO Teacher Information
		</title>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%
//Liz Quigg - updated June 2006 to add links to pre and posttest results
//be sure to set this before including the navbar
String headerType = "Teacher";
String project="ligo";

String action = "https://" + System.getProperty("host") + System.getProperty("port") + 
    "/elab/"+project+"/login.jsp";
%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="include/javascript.jsp" %>
	<table width="800">
		<tr>
			<td>
				<table width="800" cellpadding="4">
					<tr>
						<td>
							&nbsp;
						</td>
					</tr>
					<tr>
						<td bgcolor="black">
							<font face="arial" color="white" size="+1">
								<b>
									Teacher Home - Bookmark It!
								</b>
						</td>
					</tr>
				</table>
				<p>
				<table>
					<tr>
						<td>
							<blockquote>
								<b>
									Abstract:
								</b>
								<blockquote>
									Students experience the environment of scientific collaborations as they build scientific investigations using data from LIGO environmental sensors. Students will access project data related to seismicity, weather and ambient magnetic fields.  All that is needed is an Internet browser and login access to I2U2.  
									<p>
										Students will use the Web-driven grid-driven LIGO I2U2 data analysis tool to select sensors, data channels and time spans for plotting.  Plots can be edited and saved.  As they build their research projects through the analysis of plots, students will share their plots and analyses with each other and with their teacher over the Web in much the same way as professional scientists.
    <p>
        View Student Home as a: <a href="first.jsp">new student</a> - <a href = "home.jsp">returning student</a>.
								</blockquote>
						</td>
						<% if (session.getAttribute("login") == null) {
						  %>
                       <td valign="top">
							<center>
								<table border="0" width="200">
									<tr>
										<td align="center">
											<font face="arial">
												<b>
													Log in</b>
											</font>
											<br>
											<form method="post" action="<%=action%>?prevPage=/<%=project%>/teacher.jsp">
												<table border="0" cellpadding="2" cellspacing="0">
													<tr>
														<td align="right">
															<font color="black" size="-1" face="arial">
																Username: 
															</font>
														</td>
														<td>
															<input size="16" type="text" name="user" tabindex="1">
														</td>
													</tr>
													<tr>
														<td align="right">
															<font color="black" face="arial" size="-1">
																Password: 
															</font>
														</td>
														<td>
															<input size="16" type="password" name="pass" tabindex="2"><INPUT type="hidden" name="project" value="<%=project%>">
														</td>
													</tr>
													<tr>
														<td colspan="2" align="center">
															<input type="submit" name="login" class="button2" value='Login' tabindex="\" "3">
														</td>
													</tr>
													<tr colspan="2">
														<input type="hidden" name="prevPage" value="/teacher.jsp">
													<tr>
                                                    <tr>
                                                        <td align="center" colspan="3">
                                                            <font face="arial" size="-1">
                                                                <br>
                                                                To explore our website,
                                                                <br>
                                                                <a href="login.jsp?prevPage=/<%=project%>/teacher.jsp&amp;login=Login&amp;user=ligoguest&amp;pass=guest&project=<%=project%>">
                                                                    log in as guest</a>
                                                            </font>

                                                        </td>
                                                    </tr>
														<td align="center" colspan="2">
															<table>
																<tr>
																	<td>
																		<font face="arial" size="-1">
																			<b>
                                                                            <br>
																				Need a teacher login?
																			</b>
                                                                            <br>
																			contact 
                                                                            <A HREF="mailto:e-labs@fnal.gov?Subject=Please%20register%20me%20as%20an%20e-Labs%20teacher.&Body=Please%20complete%20each%20of%20the%20fields%20below%20and%20send%20this%20email%20to%20be%20registered%20as%20an%20e-Labs%20teacher.%20You%20will%20receive%20a%20response%20from%20the%20e-Labs%20team%20by%20the%20end%20of%20the%20business%20day.%0D%0DFirst%20Name:%0D%0DLast%20Name:%0D%0DCity:%0D%0DState:%0D%0DSchool:%0D">e-labs@fnal.gov</a>
																		</font>
																	</td>
																</tr>
															</table>
												</table>
											</form>
						</td>
					</tr>
				</table>
				</center><%
				  }
				  else{ %>
                     <td valign="top">
                       <CENTER>
                       <TABLE BORDER=0 WIDTH=200>
                           <TR><TD align="center"><FONT FACE=ARIAL><B>Logout</b></FONT><br>
                           <FONT FACE=ARIAL SIZE="-1">If you are not
                            <B><%= session.getAttribute("login") %></B>,</FONT>
                            <BR>
                            <FORM method="post" action="logout.jsp?prevPage=/<%=project%>/teacher.jsp">
                            <INPUT type="submit" name="logout" class="button2" value="Logout">
                            </FORM></td></tr>
                            </FONT>
                            </table>
                            <%
                            }
                            %>
                            </td>
		</tr>
		<tr>
			<td colspan="2" align="left">
				<blockquote>
					<b>
						Introduction to Research:
					</b>
					<blockquote>
						The LIGO I2U2 grid project facilitates the following experiences for students: 
						<ul>
							<li>
								Students will do authentic research using exploratory virtual data tools to access, process and publish data, report and share their results as online posters, and have online discussions with one another about their work. 
							<li>
								Student researchers will experience the environment of scientific collaborations. 
							<li>
								Student researchers can potentially make real contributions to the study of the physical environments of the two LIGO Observatories.
						</ul>
						<p>Gravitational Waves, ripples in the fabric of space-time, are the target of LIGO's Observatories in Washington State and Louisiana. Located at these two sites are three of the world's most sensitive measuring devices -- long interferometers designed to detect movements of space that are far smaller than the nucleus of a single atom.</p>

<p>Interferometers, not telescopes, are the instruments you will find at LIGO. Using laser light to sense tiny movements of 10-kg mirrors located at the opposite ends of 2.5-mile optical paths, LIGO surveys the sky for gravitational waves from events such as the mergers of black holes or neutron stars, single spinning neutron stars or star explosions, also known as supernovae.</p> 

<p>Vibrations of virtually anything in LIGO's environment have the potential to leave an imprint on the interferometers' data. LIGO's environmental effects and the many sensors that measure these effects form the basis of LIGO's I2U2 e-lab. LIGO accumulates large quantities of data from a full array of the environmental sensors. Students and teachers may perform a service to LIGO through the e-lab investigations that the I2U2 program offers.</p> 

						
					</blockquote>
					<b>
						Prior Knowledge and Skills:
					</b>
					Before doing this project, students should know how to: 
					<blockquote>
						<ul>
							<li>
								Make simple measurements. 
							<li>
								Make simple calculations. 
							<li>
								Interpret simple graphs. 
							<li>
								Write a research question. 
							<li>
								Make a research plan. 
						</ul>
						We provide refresher references for students who need to brush up on these skills. Here is what the students see:
						<br>
						<a href="research_basics.jsp">
							Review of Basic Skills
						</a>
						<p>
					</blockquote>
					<b>
						Learner Outcomes:
					</b>
					Students will know and be able to: 
					<ul>
						<li>Content:
							<ul>
								<li>Distinguish earthquakes from other types of seismic events based on their appearance in seismometer data.</ul>
							
						<li>Process:
							<ul>
								<li>Build an authentic scientific investigation and demonstrate the ability to form and test an explanation for features that appear in a stream of sensor data. 
								<li>Demonstrate skills using Internet, web and virtual data techniques. 
								<li>Work collaboratively with students in other research groups. 
							</ul>
					</ul>
					<b>
						Research Question:
					</b>
					<blockquote>
						How does a plot of 12 hours of sensor data (one point per minute) differ in its appearance from graphs associated with typical in-school science experiments that involve a much smaller volume of data?  When looking at a plot of hundres or thousands of data points through time, how does one recognize trends, patterns or abrupt events in the data? (Alternately stated, how does one distinguish between signal and noise?)   
<P>
Once an investigator hones in on a feature that a plot displays, what possible explanations can he or she develop for the feature, and how could these explanations be tested?  For instance, if one noticed an event in the data and proposed that the event was an earthquake, what additional plots or what additional information could substantiate this explanation? 
					</blockquote>
					<b>
						Assessment:
					</b>
					<blockquote>
<UL>
<LI> <A HREF="rubric.html"><B>Rubric</B></A> aligned to learner outcomes
<LI><A HREF="presurvey.jsp?type=pre&student_id=0"><B>Pre</B></A>- and <A HREF="presurvey.jsp?type=post&student_id=0"><b>post</b></A>- tests of content knowledge and student results for <A HREF="surveyResults.jsp?type=pre"><b>pre</b></A>- and <A HREF="surveyResults.jsp?type=post"><b>post</b></A>- tests.
<LI>e-Logbooks: Track and comment on student work. Review group logbook or all student entries for a particular milestone.
<LI>Poster rubric
 
</UL>
					</blockquote>
				</blockquote>
			</td>
		</tr>
	</table>
	</td>
	</table>
	<hr>
	</center>
</body>
</html>
