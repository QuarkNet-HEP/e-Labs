<html>
	<head>
		<title>
			e-Lab Teacher Information
		</title>
<!-- include css style file -->
<%@ include file="include/style.css" %>


<%@ include file="rolloutLoad.jsp" %>

<%@ include file="include/login_url_base.jsp" %>

<!-- include file with name of the current eLab -->
<%@ include file="include/elab_name.jsp" %>


<!-- header/navigation -->
<%
//Liz Quigg - updated June 2006 to add links to pre and posttest results
//be sure to set this before including the navbar
String headerType = "Teacher";
String project="cosmic";



String action = loginURLBase + "/elab/" + project + "/login.jsp";
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
									Students experience the environment of scientific collaborations in this series of investigations into high-energy cosmic rays. From start to finish this is a student-led, teacher-guided project. Schools with cosmic ray detectors can upload data to the web. A virtual data portal enables students to share this data and associated analysis code with students at other schools whether or not those schools have their own cosmic ray detectors. 
									<p>
										To begin, students check the performance of the detectors they have chosen for their study. They can then perform one of three investigations: muon lifetime, muon flux or extended air showers. Students post the results of their studies as online posters. Then the real scientific collaboration begins. Students can review the results of other studies online comparing data and analyses. Using online tools, they can correspond with other research groups, post comments and questions, prepare summary reports, and in general participate in the part of scientific research that is often left out of classroom experiments. 
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
                                                                <a href="login.jsp?prevPage=/<%=project%>/teacher.jsp&amp;login=Login&amp;user=<%=elabGuestUser%>&amp;pass=guest&project=<%=project%>">
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
						The QuarkNet/Grid Project explores the potential of using virtual data grid tools and techniques for secondary science education. The project begins with a pilot cosmic ray study that provides an opportunity for: 
						<ul>
							<li>
								Students to do authentic research using exploratory virtual data tools to access, process and publish data, report and share their results as online posters, and have online discussions with one another about their work. 
							<li>
								Student researchers to experience the environment of scientific collaborations. 
							<li>
								Student researchers to make real contributions to the study of high-energy cosmic rays. 
						</ul>
						Cosmic rays are typically protons, neutrons, gamma rays or other particles that originate in any number of astronomical objects. When these "primary" cosmic rays encounter earth's atmosphere, they can interact with nuclei of atoms and produce new, often unstable particles (e.g., pions and kaons.) In turn, these secondary cosmic rays further decay and create muons, electrons, photons and neutrinos. If these cosmic rays are sufficiently energetic, they can reach the earth's surface and be detected. (Neutrinos are capable of passing through the earth and are generally undetected.) 
						<p>
							Occasionally the primary possesses tremendous energy. These create many, many decay products. An array of detectors on the earth's surface can indirectly measure the energy of the primary by counting the number of particles in the detector array simultaneously. These observations can lead to a calculation of the part of the sky that the primary came from.
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
								<li>Identify components of primary, secondary and later generation cosmic rays. 
								<li>List properties of cosmic rays revealed in the observations. 
								<li>Describe the roles of the cosmic ray detector and the Internet. 
							</ul>
							
						<li>Process:
							<ul>
								<li>Gather/use scientific data to identify properties of cosmic rays. 
								<li>Demonstrate skills using Internet, web and virtual data techniques. 
								<li>Work collaboratively with students in other research groups. 
							</ul>
					</ul>
					<b>
						Research Question:
					</b>
					<blockquote>
						How much area can a cosmic ray shower cover? Where do cosmic rays come from? Students can pose a number of questions and then analyze the data for answers. Some answers are new to students but well answered by physicists. These include the muon lifetime, rate of cosmic ray arrival as well as the source of low-energy air showers. However, the origin of the highest-energy cosmic rays is an open question-several experiments are actually exploring it now. Students may be able to contribute data to these efforts.




Many experiments have measured cosmic array showers, including CASA (Chicago Area Scintillator Array), project G.R.A.N.D. (Gamma Ray Astrophysics at Notre Dame) and the Pierre Auger Project (an array being set up in Argentina). 
<P>
Students will be able to look into the size of cosmic ray showers by comparing their cosmic ray detector data with that from others across a wide area to see where particles struck earth's surface in closely correlated time windows. Also, students will be a part of this ongoing research by providing data to a collaboration of their peers. These data contain stamps for time and geographic location information.
 
					</blockquote>
					<b>
						Assessment:
					</b>
					<blockquote>
<UL>
<LI> <A HREF="rubric.html"><B>Rubric</B></A> aligned to learner outcomes
<LI><A HREF="presurvey.jsp?type=pre&student_id=0"><B>Pre</B></A>- and <A HREF="presurvey.jsp?type=post&student_id=0"><b>post</b></A>- tests of content knowledge and student results for <A HREF="surveyResults.jsp?type=pre"><b>pre</b></A>- and <A HREF="surveyResults.jsp?type=post"><b>post</b></A>- tests.
<LI>e-Logbooks: Track and comment on student work. Review group logbook or all student entries for a particular milestone, e.g., class cosmic ray descriptions.
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
