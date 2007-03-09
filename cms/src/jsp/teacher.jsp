<html>
	<head>
		<title>
			e-Lab Teacher Information
		</title>
<!-- include css style file -->
<%@ include file="include/style.css" %>

<%@ include file="include/login_url_base.jsp" %>

<!-- include file with name of the current eLab -->
<%@ include file="include/elab_name.jsp" %>


<!-- header/navigation -->
<%
//Liz Quigg - updated June 2006 to add links to pre and posttest results
//be sure to set this before including the navbar
String headerType = "Teacher";
String project="cms";

String action = loginURLBase + "/elab/" + project + "/login.jsp";
%>
<%@ include file="include/navbar_common_t.jsp" %>
<%@ include file="include/javascript.jsp" %>
<div align="center">
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
									Students can join a scientific collaboration in this 
                      series of studies of high-energy collisions from the 
                      Large Hadron Collider(LHC) at CERN. We are collaborating with 
                      the Compact Muon Solenoid(CMS) Collaboration. From start to finish 
                      this is a student-led, teacher-guided project. At the present we 
                      have test beam data for analysis. When the LHC starts producing 
                      data, students will be able to request data with specific 
                      parameters. By using the web and GRID computing technology students will 
                      be able to analyze the data. A virtual data portal enables 
                      students to share this data and associated analysis code with 
                      students and other researchers.
                      <P>Students use a data base and analysis tool on the 
                        website. The Online Graphical ROOT Environment(OGRE) is the analysis tool used to analyze the data they have chosen for their study. Many 
                        tutorials are available to build basic scientific skills, to explain the how the detector works, to increase students understanding of subatomic particles, to direct in using the analysis tools and 
                        to explain how to use plots to analyze data. Students can then perform any 
                        of four studies:  shower depth, lateral size, beam purity 
                        or detector resolution. Students post the results of their 
                        studies as online posters. Then the real scientific 
                        collaboration begins. Students can review the results of other 
                        studies online comparing data and analyses. Using online tools, 
                        they can correspond with other research groups, post comments 
                        and questions, prepare summary reports and in general, 
                        participate in an aspect of scientific research that is often 
                        left out of classroom experiments.
                      <P>View Student Home as a: <A 
                href="first.jsp">new 
                        student</A> - <A 
                href="home.jsp">returning 
                        student</A>.
								</b>
								<blockquote>
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
                                                                                                                           <a href="login.jsp?prevPage=/<%=project%>/teacher.jsp&amp;login=Login&amp;user=<%=elabGuestUser%>&amp;pass=guest&project=<%=project%>">
oject%>">
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
					The CMS Project explores the potential 
                      of using virtual data grid tools and techniques for secondary 
                      science education. Like the cosmic ray e-Lab, this e-Lab 
                      provides an opportunity for:
                      <UL>
                        <LI>Students to do authentic research using exploratory 
                          virtual data tools to access, process and publish data, report 
                          and share their results as online posters, and have online 
                          discussions with one another about their work.
                        <LI>Student researchers to experience membership in a 
                          scientific collaboration.
                        <LI>Student researchers to make real contributions to the 
                          study of  particle physics. </LI>
                      </UL>
                      <P>With the CMS detector we will be studying proton-proton 
                        collisions, in search of the predicted Higgs boson that may be 
                        instrumental in explaining why particles have mass. Pions, 
                        muons, electrons, photons, neutrinos and other particles are 
                        produced in these collisions and subsequent decays. When a proton-proton collision 
                        takes place, these particles interact with the detector in ways 
                        particular to each particle(the particles's signature in the 
                        detector). </P>
                      <P>By observing how particles interact with the detector, a 
                        researcher can determine which types of particles were produced 
                        in the collision. Because CMS will use a much higher energy 
                        beam than was previously available,  higher 
                        mass particles will be able to be detected. Many top quarks are expected to be seen and the predicted Higgs boson may 
                        be discovered . The possibility of finding 
                        particles that were previously "un-seeable" with other detectors 
                        at other facilities is exciting. </P>	
					</blockquote>
					<b>
						Prior Knowledge and Skills:
					</b>
					Before doing this project, students should know how to: 
					<blockquote>
					 <UL>
                        <LI>Make simple measurements.
                        <LI>Make simple calculations.
                        <LI>Interpret simple graphs.
                        <LI>Write a research question.
                        <LI>Make a research plan. </LI>
                      </UL>
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
				<UL>
                      <LI>Content:
                        <UL>
                          <LI>Identify particles observed in the data.
                          <LI>Describe the role sub-detector in data analysis.
                          <LI>Use data to measure the shape of showers produced by 
                            particles. </LI>
                          <LI>Use data to measure the detector's resolution. </LI>
                        </UL>
                      <LI>Process:
                        <UL>
                          <LI>Gather/use scientific data to identify particles.
                          <LI>Demonstrate skills using the internet, web and virtual 
                            data techniques.
                          <LI>Work collaboratively with students in other research 
                            groups. </LI>
                        </UL>
                      </LI>
                    </UL>
                    
					<b>
						Research Question:
					</b>
					<blockquote>
						<p>What kinds of particles are produced in the 
                        proton-proton collisions inside the CMS detector? What are the 
                        smallest known particles? Is there a Higgs boson? What causes 
                        objects to have mass? Students can pose a number of questions 
                        and then analyze the data for answers. Some answers are new to 
                        students but well answered by physicists. These include the 
                        smallest known particles, the kinds of particles that are 
                        produced in proton-proton collisions and how these produced 
                        particles interact with the detector. However, the cause of mass 
                        is an open question that the CMS Collaboration hopes to address. </p>
                      <p>Students may be able to contribute insights to these efforts. 
                        Many experiments have been investigating the smallest particles. 
                        For example, the top quark was discovered at the accelerator at 
                        Fermi National Accelerator Laboratory by the CDF and D0 collaborations. Student will be able 
                        to see the results of other researchers in this field. At this 
                        time student will be looking at test beam data which will help 
                        them understand how particles interact  with the detector. When the LHC 
                        comes on line, students will be a part of this ongoing research 
                        by analyzing data and sharing it with a collaboration of their 
                        peers. </p>
 
					</blockquote>
					<b>
						Assessment:
					</b>
					<blockquote>
<UL>
                        <LI><A 
                  href="rubric.html"><B>Rubric</B></A> aligned to learner outcomes
<LI><A HREF="presurvey.jsp?type=pre&student_id=0"><B>Pre</B></A>- and <A HREF="presurvey.jsp?type=post&student_id=0"><b>post</b></A>- tests of content knowledge and student results for <A HREF="surveyResults.jsp?type=pre"><b>pre</b></A>- and <A HREF="surveyResults.jsp?type=post"><b>post</b></A>- tests.
                       <LI>e-Logbooks: Track and comment on student work. Review 
                          group logbook or all student entries for a particular 
                          milestone, e.g., class description of how particles interact 
                          with the detector.
                        <LI>Poster rubric </LI>
                      </UL>
					</blockquote>
				</blockquote>
			</td>
		</tr>
	</table>
	</td>
	</table>
	<hr>
	</div>
</body>
</html>
