<%@ page import="java.util.*"%>
<%@ include file="../login/teacher-login-required.jsp"%>
<%@ include file="common.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>

<link rel="stylesheet" href="include/styletutT.css" type="text/css">
<html>
<head>
<title>Show Research Group Logbook for Teacher</title>
</head>
<body>

<table width="800">
	<tr>
		<td width="150">&nbsp;</td>
		<td width="100" align="right"><img
			src="graphics/logbook_view_large.gif" align="middle" border="0"
			alt=""></td>
		<td width="550"><font size="+2">Teachers: View Your <b>Private</b>
		Logbook<br>
		on Student Research Groups.</font></td>
	</tr>
</table>
<center><!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb_ps.jsp"%> <%
 	// invoked with optional research_group_name
 	// if no research_group_name is passed, 
 	String role = (String) session.getAttribute("role");
 	if (!role.equals("teacher")) {
 		out.write("This page is only available to teachers");
 		return;
 	}
 	// it will display all or one keyword for a particular research group.
 	// If the ref_rg_name is not passed, then it will show a list of research groups that teacher has for this e-Lab and return.
 	// Each of these will link to this page with research_group_name passed without a keyword.
 	String keyword_description = "";
 	String keyword_text = "";
 	String linksToEach = "";
 	String linksToEachGroup = "";
 	String keyword_loop = "";
 	java.util.List<String> rgNames = new java.util.ArrayList<String>();
 	java.util.List<Integer> rgIds = new java.util.ArrayList<Integer>(); 
 	String teacher_name = "";
 	int countRgs = 0;
 	String ref_rg_name = request.getParameter("ref_rg_name"); // this is the name we are referring to in the logbook
 	String research_group_name = groupName; // group name of the teacher whose logbook this is.
 	// get project ID
 	//eLab defined in common.jsp
 	Integer project_id = null;
 	s = conn.prepareStatement("SELECT id FROM project WHERE name = ?;");
 	s.setString(1, eLab);
 	rs = s.executeQuery();
 	if (rs.next()) {
 		project_id = (Integer) rs.getObject("id");
 	}
 	if (project_id == null) {
 		%> Problem with id for project <%=eLab%><br> <%
		return;
	}

	// get group ID
	//groupName defined in common.jsp
	Integer research_group_id = null;	
	s = conn.prepareStatement(
			"SELECT research_group.id AS rg_id, teacher.name AS teacher_name FROM research_group, teacher " +
			"WHERE research_group.name = ? AND research_group.teacher_id = teacher.id;");
	s.setString(1, research_group_name); 
	rs = s.executeQuery();
	if (rs.next()) {
		research_group_id = (Integer) rs.getObject("rg_id");
		teacher_name = rs.getString("teacher_name");
	}

	if (research_group_id == null) {
		%> Problem with ID for research group of teacher.<%=research_group_id%><br><%
		return;
	}

	s = conn.prepareStatement(
			"SELECT id, name FROM research_group, research_group_project " +
			"WHERE role IN ('user', 'upload') AND research_group_project.project_id = ? AND research_group_project.research_group_id=research_group.id AND research_group.teacher_id IN " + 
				"(SELECT teacher_id FROM research_group WHERE research_group.name = ?) " + 
			"ORDER BY name;");
	s.setInt(1, project_id);
	s.setString(2, groupName); 

	rs = s.executeQuery();
	while (rs.next()) {
		int this_ref_rg_id = rs.getInt("id");
		String this_ref_rg_name = rs.getString("name");
		linksToEachGroup = linksToEachGroup
				+ "<tr><td><A HREF='showLogbookT.jsp?ref_rg_name="
				+ this_ref_rg_name + "'>" + this_ref_rg_name
				+ "</A></td></tr>";
		rgIds.add(this_ref_rg_id);
		rgNames.add(this_ref_rg_name);
	} 
	// tack on the self-referential research group of the teacher used for general comments

	rgIds.add(research_group_id);
	rgNames.add("general");
	countRgs = rgIds.size();
%>

<table width="800" cellpadding="0" border="0" align="left">
	<tr>
		<td valign="top" align="150">
		<table width="140">
			<tr>
				<td valign="center" align="left"><b>Student Logbooks</b></td>
			</tr>
			<tr>
				<td valign="center" align="left"><a
					href="showLogbookKWforT.jsp"><img
					src="graphics/logbook_view_small.gif" border="0" " align="middle"
					alt=""><font color="#1A8BC8">By Milestone</font></a></td>
			</tr>
			<tr>
				<td valign="center" align="left"><a
					href="showLogbookRGforT.jsp"><img
					src="graphics/logbook_view_small.gif" border="0" " align="middle"
					alt=""><font color="#1A8BC8">By Group</font></a></td>
			</tr>
			<tr>
				<td><b>Your Logbook:<br>
				<a href="showLogbookT.jsp?ref_rg_name=general">general</a><br>
				<br>
				Select a Research Group</b></td>
			</tr><%=linksToEachGroup%>
			<tr>
				<td valign="center" align="left"><a href="showLogbookT.jsp">All
				Groups</a></td>
			</tr>

		</table>


		</td>

		<td align="left" width="20" valign="top"><img
			src="graphics/red_square.gif" border="0" width="2" height="475"
			alt=""></td>

		<td valign="top" align="center">

		<div style="border-style: dotted; border-width: 1px;">
		<table width="600">
			<tr>
				<td align="left" colspan="4"><font size="+1"
					face="Comic Sans MS">Instructions</font></td>
			</tr>
			<tr>
				<td align="right"><img src="graphics/logbook_pencil.gif"
					align="middle" border="0" alt=""></td>
				<td align="left">Button to add logbook entry.</td>
			</tr>
		</table>
		</div>

		<%
			// old position of code to get research_group_id    

			Integer ref_rg_id = null;

			if (!(ref_rg_name == null) && (!ref_rg_name.equals("general"))) {
				// get group ID
				//groupName defined in common.jsp
				s = conn.prepareStatement(
						"SELECT id FROM research_group WHERE name = ?;");
				s.setString(1, ref_rg_name);
				rs = s.executeQuery();
				if (rs.next()) {
					ref_rg_id = (Integer) rs.getObject("id");
				}

				if (ref_rg_id == null) {
					%> Problem with ID for student research group <%=research_group_id%><br><%
					return;
				}
			} 
			else {
				if (!(ref_rg_name == null) && ref_rg_name.equals("general")) {
					ref_rg_id = research_group_id; // general references for teachers will be self referential.
				} 
				else {
					ref_rg_name = "";// note - display all entries
				}
			}
			
			String queryItems = "SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text, log.ref_rg_id AS ref_rg_id FROM log, research_group ";
			PreparedStatement queryWhere; 

			if (ref_rg_name.equals("")) {
				%> <h2>For all groups for teacher "<%=teacher_name%>"</h2> <%
				queryWhere = conn.prepareStatement(queryItems + 
						"WHERE log.project_id = ? AND log.research_group_id = ? AND log.research_group_id = research_group.id and log.role = 'teacher' " +
						"ORDER BY log.ref_rg_id, log_id DESC;");
				queryWhere.setInt(1, project_id);
				queryWhere.setInt(2, research_group_id);
			} 
			else {
				if (ref_rg_name.equals("general")) {
					%> <h2>General notes for teacher "<%=teacher_name%>"</h2> <%
				} 
				else {
					%> <h2>For group "<%=ref_rg_name%>" for teacher "<%=teacher_name%>"</h2> <%
				}				
				queryWhere = conn.prepareStatement(queryItems +
						"WHERE log.project_id = ? AND log.research_group_id = ? AND log.research_group_id = research_group.id AND log.ref_rg_id = ? AND log.role='teacher' " +
						"ORDER BY log_id DESC;");
				queryWhere.setInt(1, project_id);
				queryWhere.setInt(2, research_group_id);
				queryWhere.setInt(3, ref_rg_id);
			}
		%>

		<p>
		<table width="600" cellspacing="5">
			<%
				// look for any previous log entries for this keyword
				
				int itemCount = 0;
				int current_ref_rg_id = -1;
				rs = queryWhere.executeQuery();
				while (rs.next()) {
					String dateText = rs.getString("date_entered");
					String log_text = rs.getString("log_text");
					String log_id = rs.getString("log_id");
					ref_rg_id = rs.getInt("ref_rg_id");
					itemCount++;
					if (!(current_ref_rg_id == ref_rg_id)) {
						current_ref_rg_id = ref_rg_id;
						if (itemCount > 1) {
							%>
							</table>
							<p>
							<%
						}
						ref_rg_name = "";
						boolean search = true;
						int j = 0;
						while ((search) && (j < countRgs)) {
							if (current_ref_rg_id == rgIds.get(j)) {
								ref_rg_name = rgNames.get(j);
								search = false;
							}
							j++;
						}
						%>
						<table cellpadding="5">
							<tr align="center">
								<td colspan="2"><font size="+1"><%=ref_rg_name%></font><a
									href="logEntryT.jsp?research_group_id=<%=research_group_id%>&amp;ref_rg_id=<%=ref_rg_id%>"><img
									src="graphics/logbook_pencil.gif" border="0" align="top" alt=""></a>
								</td>
							</tr>
						<%
					}
					%>
					<tr>
						<td valign="top" width="175" align="right"><%=dateText%></td>
						<!-- <td width="400" valign="top"><e:whitespaceAdjust
							text='<%=log_text%>' /></td> -->
						<td width="400" valign="top"><%=log_text%></td> 
					</tr>
					<%
				}
				if (itemCount == 0) {
					%> <tr align="center"> <td colspan="2"><font size="+1">No entries.</font> <%
 					if (!(ref_rg_id == null)) {
 						%> <a href="logEntryT.jsp?research_group_id=<%=research_group_id%>&amp;ref_rg_id=<%=ref_rg_id%>"><img src="graphics/logbook_pencil.gif" border="0" align="top" alt=""></a> <%
					} 
 					else {
 						%> <br> <font size="+1">Select a research group on the left.</font> <%
 					}
 					%>
				</td>
			</tr>
			<%
				}
			%>
		</table>
		</p>
		</p>
		</td>
	</tr>
</table>





</center>
</body>
<%
	if (s != null)
		s.close();
	if (conn != null)
		conn.close();
%>
</html>
