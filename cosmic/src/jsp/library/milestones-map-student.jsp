<% 
	String pre, post; 
	if (user.getNewSurveyId() != null) {
		pre  = "../survey/show-students.jsp?type=pre" ;
		post = "../survey/show-students.jsp?type=post";
	}
	else {
		pre  = "../test/show-students.jsp?type=presurvey" ;
		post = "../test/show-students.jsp?type=postsurvey";
	}
	request.setAttribute("pre", pre);
	request.setAttribute("post", post);
%>
<img src="../graphics/workflow_map6B.gif" width="796" height="257" border="0" alt="" usemap="#workflow_map6B_Map">
<map name="workflow_map6B_Map">
<area shape="rect" alt="" coords="1,144,83,183" href="javascript:glossary('milestone')">
<area shape="rect" alt="" coords="2,103,84,142" href="javascript:glossary('milestone seminar')">
<area shape="rect" alt="" coords="704,93,778,133" href="javascript:reference('discuss results',420)">
<area shape="rect" alt="" coords="703,175,773,217" href="javascript:reference('publish results',280)">
<area shape="rect" alt="" coords="626,169,686,216" href="javascript:reference('assemble evidence',250)">
<area shape="rect" alt="" coords="570,112,636,149" href="javascript:reference('data errors',400)">
<area shape="rect" alt="" coords="547,181,622,229" href="javascript:reference('analysis tools',450)">
<area shape="rect" alt="" coords="474,182,541,230" href="javascript:reference('collect upload data',450)">
<area shape="poly" alt="" coords="402,91, 466,92, 446,114, 431,117, 424,133, 411,138, 401,131, 402,91" href="javascript:reference('research proposal',220)">
<area shape="rect" alt="" coords="386,181,451,225" href="javascript:reference('detector',400)">
<area shape="rect" alt="" coords="288,183,355,223" href="javascript:reference('cosmic ray study',550)">
<area shape="rect" alt="" coords="288,116,364,144" href="javascript:reference('cosmic rays',420)">
<area shape="rect" alt="" coords="715,19,773,63" href="${post}">
<area shape="rect" alt="" coords="0,19,58,63" href="${pre}">
<area shape="poly" alt="" coords="66,44, 98,40, 108,13, 134,13, 138,40, 156,43, 160,55, 140,60, 68,60, 66,46, 66,44" href="big-picture.jsp">
<area shape="rect" alt="" coords="204,105,286,132" href="javascript:reference('research plan')">
<area shape="rect" alt="" coords="200,176,283,215" href="javascript:reference('research question',300)">
<area shape="poly" alt="" coords="156,203, 176,202, 184,225, 200,228, 201,251, 132,251, 136,235, 150,227, 156,203" href="javascript:reference('simple graphs',600)">
<area shape="rect" alt="" coords="82,177,140,227" href="javascript:reference('simple calculations')">
<area shape="rect" alt="" coords="82,91,152,135" href="javascript:reference('simple measurement')">
</map>
