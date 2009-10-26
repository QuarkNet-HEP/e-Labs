<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<img src="../graphics/workflow_map6B.gif" width="796" height="257" border="0" alt="" usemap="#workflow_map6B_Map" />
<map name="workflow_map6B_Map">
	<area shape="rect" alt="" coords="1,144,83,183" href="javascript:glossary('milestone')" title="Learn about milestones.">
	<area shape="rect" alt="" coords="2,103,84,142" href="javascript:glossary('milestone seminar')" title="Learn about milestone seminars.">
	<area shape="rect" alt="" coords="704,93,778,133" href="javascript:reference('discuss results',420)" title="Use the e-Lab to discuss your results. Exchange comments with other researchers - participate in scientific discourse.">
	<area shape="rect" alt="" coords="703,175,773,217" href="javascript:reference('publish results',280)" title="Use the e-Lab to publish your results. Create a poster.">
	<area shape="rect" alt="" coords="626,169,686,216" href="javascript:reference('assemble evidence',250)" title="Assemble evidence for your results. Select the best plots for your poster.">
	<area shape="rect" alt="" coords="570,112,636,149" href="javascript:reference('data errors',400)" title="Know how to correct for background and errors when appropriate. Do it!">
	<area shape="rect" alt="" coords="547,181,622,229" href="javascript:reference('analysis tools',450)" title="Know how to use your analysis tools and how to search for data of interest. Do it!">
	<area shape="rect" alt="" coords="474,182,541,230" href="javascript:reference('collect upload data',450)" title="If you have a detector, know how to collect data and upload files to our server.">
	<area shape="poly" alt="" coords="402,91, 466,92, 446,114, 431,117, 424,133, 411,138, 401,131, 402,91" href="javascript:reference('research proposal',220)" title="Write a research question and proposal. What will you study?">
	<area shape="rect" alt="" coords="386,181,451,225" href="javascript:reference('detector',400)" title="Describe what the detector can do. What measurements can you make?">
	<area shape="rect" alt="" coords="288,183,355,223" href="javascript:reference('cosmic ray study',550)" title="Determine what you can study about cosmic rays. What do you know? What would you like to find out?">
	<area shape="rect" alt="" coords="288,116,364,144" href="javascript:reference('cosmic rays',420)" title="Describe cosmic rays in simple terms. Some background reading will tell you what scientists know.">
	<c:choose>
		<c:when test="${user.newSurveyId != null}"> <%-- User is in the new survey code --%>
			<area shape="rect" alt="" coords="715,19,773,63" href="../survey/show-students.jsp?type=pre" title="Take the post-test. See what you learned.">
			<area shape="rect" alt="" coords="0,19,58,63" href="../survey/show-students.jsp?type=post" title="Take the pre-test. See what you already know.">
		</c:when>
		<c:when test="${user.study}"> <%-- User is in the old survey code --%>
			<area shape="rect" alt="" coords="715,19,773,63" href="../test/show-students.jsp?type=presurvey" title="Take the post-test. See what you learned.">
			<area shape="rect" alt="" coords="0,19,58,63" href="../test/show-students.jsp?type=postsurvey" title="Take the pre-test. See what you already know.">
		</c:when>
	</c:choose>
	<area shape="poly" alt="" coords="66,44, 98,40, 108,13, 134,13, 138,40, 156,43, 160,55, 140,60, 68,60, 66,46, 66,44" href="../library/big-picture.jsp" title="Read about the cool science.">
	<area shape="rect" alt="" coords="204,105,286,132" href="javascript:reference('research plan')" title="Background on research proposals">
	<area shape="rect" alt="" coords="200,176,283,215" href="javascript:reference('research question',300)" title="Background on research questions.">
	<area shape="poly" alt="" coords="156,203, 176,202, 184,225, 200,228, 201,251, 132,251, 136,235, 150,227, 156,203" href="javascript:reference('simple graphs',600)" title="Background on simple plots">
	<area shape="rect" alt="" coords="82,177,140,227" href="javascript:reference('simple calculations')" title="Background on simple calculations">
	<area shape="rect" alt="" coords="82,91,152,135" href="javascript:reference('simple measurement')" title="Background on simple measurements">
	<area shape="rect" alt="" coords="615,0,701,71" href="#" title="Goal: Make a poster and discuss results.">
	<area shape="rect" alt="" coords="480,6,554,69" href="#" title="Goal: Create data analysis plots.">
	<area shape="rect" alt="" coords="346,10,413,69" href="#" title="Goal: Write a proposal.">
	<area shape="poly" alt="" coords="176,32, 263,33, 282,89, 145,85, 176,32" href="#" title="Goal: Review necessary skills for a study.">
</map>
