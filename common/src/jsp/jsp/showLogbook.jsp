<%@ page import="java.io.*"%>
<%@ page import="java.util.*"%>
<%@ page import="gov.fnal.elab.util.HTMLEscapingWriter"%>
<%@ include file="common.jsp"%>
<%@ include file="../login/login-required.jsp"%>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl"%>

<html>
<head>
<title>Enter Logbook</title>
<link rel="stylesheet" href="include/styletut.css" type="text/css">
</head>
<body onload='self.focus();'>
<center>
<table width="800" cellpadding="0" border="0" align="left">
	<tr>
		<td valign="top" align="150"><!-- creates variables ResultSet rs and Statement s to use: -->
			<%@ include file="include/jdbc_userdb_ps.jsp"%>
			<%
			String role = (String)session.getAttribute("role");
			
			if (role.equals("teacher")) { 
				out.write("This page is only available to student research groups.");
				return;
			}
			String keyColor = "";
			String keyword_description = "";
			String keyword_text = "";
			String linksToEach = "";
			String keyword_loop = "";
			Integer keyword_id = null;
			String typeConstraint = " AND keyword.type IN ('SW','S') ";
			
			if (groupName.startsWith("pd_") || groupName.startsWith("PD_")) {
				typeConstraint = " AND keyword.type IN ('SW','W') ";
			}
			
			String keyword = request.getParameter("keyword");
			if (keyword == null) {
				keyword = "";
			} // note - display all entries
	
			// get project ID
			//eLab defined in common.jsp
			Integer project_id = null;  
	     
			s = conn.prepareStatement("SELECT id FROM project WHERE name ILIKE ?;");
			s.setString(1, eLab);
			rs = s.executeQuery(); 
			
			if (rs.next()) {
				project_id = (Integer) rs.getObject("id");
			}
			else {
				%> Problem with id for project <%=eLab%><br><% 
				return;
			}
			
			String yesNo = "no";
			
			s = conn.prepareStatement(
					"SELECT DISTINCT keyword_id FROM log, research_group, keyword " +
					"WHERE keyword.keyword = 'general' AND keyword.id = log.keyword_id and research_group.name ILIKE ? AND research_group.id = log.research_group_id AND log.project_id = ?;");
			s.setString(1, groupName); 
			s.setInt(2, project_id);
			rs = s.executeQuery();
			if (rs.next()) {
	      		yesNo = "yes";
			}
			%>
			<table width="140">
				<tr>
					<td valign="center" align="left">
						<a href="showLogbook.jsp"><font face="Comic Sans MS"><img src="graphics/logbook_view.gif" border="0" " align="middle" alt=""> All Entries</font></a>
					</td>
				</tr>
				<tr>
					<td>
						<img src="graphics/log_entry_<%=yesNo%>.gif" border="0" align="center" alt=""><a href="showLogbook.jsp?keyword=general"><font face="Comic Sans MS">general</font></a>
					</td>
				</tr>
				<tr>
					<td>
						<b><br><font face="Comic Sans MS">Milestones from<br>Research Basics<br>and Study Guide</font></b>
					</td>
				</tr>
				<tr>
					<td align="center">
						<img src="graphics/log_entry_yes.gif" border="0" alt=""><font face="Comic Sans MS"> if entry exists</font>
					</td>
				</tr>
				<%
				HashMap keywordTracker = new HashMap();
				s = conn.prepareStatement(
						"SELECT DISTINCT keyword_id FROM log,research_group " + 
						"WHERE research_group.name ILIKE ? and research_group.id = log.research_group_id and project_id in (0, ?);");
				s.setString(1, groupName);
				s.setInt(2, project_id); 
				rs = s.executeQuery();
				while (rs.next()){
					keyword_id= (Integer) rs.getObject("keyword_id");
					keywordTracker.put(keyword_id.intValue(), true);
				}
				
				//provide access to all possible items to make logs on. 
				s = conn.prepareStatement(
						"SELECT id, keyword, description, section, section_id " + 
						"FROM keyword where keyword.project_id in (0,?) " + typeConstraint + 
						"ORDER by section, section_id;");
				s.setInt(1, project_id);
				String current_section = "";
				rs = s.executeQuery();
	     
				while (rs.next()) {
					keyword_id = (Integer) rs.getObject("id");
					keyword_loop = rs.getString("keyword");
					keyword_text = keyword_loop.replaceAll("_"," ");
					keyword_description = rs.getString("description");
					String this_section = (String)(rs.getString("section"));
					yesNo = "no";
	
					if (!keyword_loop.equals("general")) {
						if (!this_section.equals(current_section)) {
							String section_text = "";
							char this_section_char = this_section.charAt(0);
							switch( this_section_char ) {
							case 'A': section_text="Research Basics";break;
							case 'B': section_text="A: Get Started";break;
							case 'C': section_text="B: Figure it Out";break;      
							case 'D': section_text="C: Tell Others";break;    
							}
							linksToEach=linksToEach + "<tr><td>&nbsp;</td></tr><tr><td><font face='Comic Sans MS'>"+section_text+"</font></td></tr>";
							current_section = this_section;
						}
						if (keywordTracker.containsKey(keyword_id.intValue())) {
							yesNo="yes";
						}
						keyColor="";
						if (keyword.equals(keyword_loop)) { 
							keyColor="color=\"#AA3366\"";
						}
						linksToEach=linksToEach + "<tr><td><img src=\"graphics/log_entry_" + yesNo + ".gif\" border=0 align=center><a href='showLogbook.jsp?keyword="+keyword_loop+"'><font face='Comic Sans MS'"+keyColor+">"+keyword_text+"</face></a></td></tr>";}
				}
				%>
				<%=linksToEach%>
			</table>
		</td>

		<td align="left" width="20" valign="top">
			<img src="graphics/blue_square.gif" border="0" width="2" height="500" alt="">
		</td>

		<td valign="top" align="center">
		<%
		// get group ID
		//groupName defined in common.jsp
		Integer research_group_id = null;
		s = conn.prepareStatement("SELECT id FROM research_group WHERE name ILIKE ?");
		s.setString(1, groupName);
		rs = s.executeQuery();
		if (rs.next()) {
			research_group_id=(Integer) rs.getObject("id");
		}
		else {
			%> Problem with ID for research group <%=groupName%><br> <%
			return;
		}
		
		// Always pass keyword, not id so we can pick off the description
		
		keyword_id = null;
		if (!keyword.equals("")) {
			// first make sure a keyword was passed in the call
			s = conn.prepareStatement(
					"SELECT id, keyword, description FROM keyword " +
					"WHERE keyword.project_id in (0, ?) and keyword= ?;");
			s.setInt(1, project_id);
			s.setString(2, keyword);
			rs = s.executeQuery();
			if (rs.next()) {
				keyword_id = (Integer) rs.getObject("id");
				keyword_description = rs.getString("description");
			}
			else {
				%> Problem with id for log. <%=keyword%><br> <% 
				return;
			}
		}
		
		PreparedStatement queryWhere; 
		String querySort="ORDER BY keyword.section, keyword.section_id, log_id DESC;";
		String queryItems="SELECT log.id AS log_id, to_char(log.date_entered,'MM/DD/YYYY HH12:MI') AS date_entered, log_text, keyword.description AS description, keyword.id AS data_keyword_id, keyword.keyword AS keyword_name, keyword.section AS section, keyword.section_id AS section_id FROM log, keyword ";
  
		if (keyword_id == null) {
			%>
			<table width="600">
				<tr>
					<td align="right">
						<img src="graphics/logbook_large.gif" align="middle" border="0" alt="">
					</td>
					<td>
						<h2><font face="Comic Sans MS">Logbook Entries for Group "<%=groupName%>"</font></h2>
					</td>
				</tr>
			</table>
			<%
			queryWhere = conn.prepareStatement(queryItems +
					"WHERE log.project_id = ? AND keyword.project_id in (0, ?) AND log.keyword_id = keyword.id and research_group_id = ? and role='user' "  + querySort);
			queryWhere.setInt(1, project_id);
			queryWhere.setInt(2, project_id);
			queryWhere.setInt(3, research_group_id);
			
		}
		else {
			%>
			<table width="600">
				<tr>
					<td align="right">
						<img src="graphics/logbook_large.gif" align="middle" border="0" alt="">
					</td>
					<td>
						<h2><font face="Comic Sans MS">Logbook Entry for Group "<%=groupName%>"</font></h2>
					</td>
				</tr>
			</table>
			<%
			queryWhere = conn.prepareStatement(queryItems +
					"WHERE log.project_id = ? and keyword.project_id  in (0, ?) and research_group_id = ? and log.keyword_id = keyword.id and keyword_id = ? and role='user' " + querySort);
			queryWhere.setInt(1, project_id);
			queryWhere.setInt(2, project_id);
			queryWhere.setInt(3, research_group_id);
			queryWhere.setInt(4, keyword_id);
		}
    	%>
		<table>
			<tr>
				<td align="center" height="20">&nbsp;</td>
			</tr>
		</table>
		<div style="border-style: dotted; border-width: 1px;">
			<table width="600">
				<tr>
					<td align="left" colspan="4">
						<font size="+1" face="Comic Sans MS">Instructions</font>
					</td>
				</tr>
				<tr align="center">
					<td align="right">
						<img src="graphics/logbook_pencil.gif" align="middle" border="0" alt="">
					</td>
					<td align="left">
						<font face="Comic Sans MS">Button to add a logbook entry.</font>
					</td>
					<td align="right">
						<img src="graphics/logbook_view_comments_small.gif" border="0" align="middle" alt="">
					</td>
					<td align="left">
						<font face="Comic Sans MS">Button to view your teacher's comments.</font>
					</td>
				</tr>
				<tr>
					<td align="center" colspan="4">
						<font size="-2" face="Comic Sans MS">Comments: Number of teacher comments (<font color="#AA3366"> number unread </font>). New comments by your teacher are marked as <img src="graphics/new_flag.gif" border="0" align="center" alt=""></font>.
					</td>
				</tr>
			</table>
		</div>
		<p></p>
			<table width="600" cellspacing="5">
				<%
				PreparedStatement sInner = null;
				ResultSet innerRs = null;
				// look for any previous log entries for this keyword
				
				int itemCount=0;
				int current_keyword_id = -1;
				String sectionText="";
				current_section="";
				rs = queryWhere.executeQuery();
				while (rs.next()) {
					int data_keyword_id=rs.getInt("data_keyword_id");
					int log_id=rs.getInt("log_id");
					int section_id=rs.getInt("section_id");
					String dateText=rs.getString("date_entered");
					keyword_description=rs.getString("description");
					String log_text=rs.getString("log_text");
					log_text = log_text.replaceAll("''", "'");
					String keyword_name=rs.getString("keyword_name");
					String keyword_display=keyword_name.replaceAll("_"," ");
					String section=rs.getString("section");
					itemCount++;
					if (!(current_keyword_id == data_keyword_id)) {
						current_keyword_id = data_keyword_id;
						if (itemCount>1) {
	                  		%>
							</table>
							<p></p>
							<% 
						}
						if (keyword_name.equals("general") || (current_section.equals(section))) { 
							sectionText = "";
						}
						else {
							sectionText = "";
							char this_section_char = section.charAt(0);
							switch( this_section_char ) {
							case 'A': sectionText="Research Basics";break;
							case 'B': sectionText="A: Get Started";break;
							case 'C': sectionText="B: Figure it Out";break;      
							case 'D': sectionText="C: Tell Others";break;    
							}
							current_section=section;
						}
						%>
						<table cellpadding="5" width="600">
							<% 
							if (!sectionText.equals("")) {
	          					%>
								<tr align="left">
									<td colspan="2"><font face="Comic Sans MS" size="+2"><%=sectionText%></font></td>
								</tr>
								<%
							}
							%>
							<tr align="left">
								<td colspan="2">
									<font face="Comic Sans MS" size="+1" color="#AA3366"><%=keyword_display%></font> - 
									<font face="Comic Sans MS"><%=keyword_description%></font> 
									<a href="logEntry.jsp?keyword=<%=keyword_name%>">
										<img src="graphics/logbook_pencil.gif" border="0" align="middle" alt="">
									</a>
									&nbsp;&nbsp;
									<a href="showCommentsForKW.jsp?keyword=<%=keyword_name%>">
										<img src="graphics/logbook_view_comments_small.gif" border="0" align="middle" alt="">
									</a>
								</td>
							</tr>
							<%
					}
					// get comment information
					Long comment_count = null;
					Long comment_new = null;
					String comment_info="";
					sInner = conn.prepareStatement("SELECT COUNT(id) AS comment_count FROM comment WHERE log_id = ?;");
					sInner.setInt(1, log_id);
					innerRs = sInner.executeQuery();
					
					if (innerRs.next()) {
						comment_count = (Long) innerRs.getObject("comment_count");
					}
					sInner = conn.prepareStatement("SELECT COUNT(comment.id) AS comment_new FROM comment WHERE comment.new_comment = 't' AND log_id = ?;");
					sInner.setInt(1, log_id);
					innerRs = sInner.executeQuery();
					if (innerRs.next()) {
						comment_new = (Long) innerRs.getObject("comment_new");
					}
					if (!(comment_count == null) && !(comment_count == 0L)) {
						if (comment_new == 0L) {
							comment_info=comment_info+"<BR><FONT size=-2>comments: "+comment_count+"</font>";
						}
						else {
							if (comment_count == null) {
								comment_count = 0L;
							}
							comment_info=comment_info+"<BR><IMG SRC=\'graphics/new_flag.gif\' border=0 align=\'middle\'> <FONT size=-2 >comments: " + comment_count + " (<FONT color=\"#AA3366\">"+comment_new+"</FONT>) " +"</font>";
						}
					}
					%>
					<tr>
						<td valign="top" width="150" align="right"><font
							face="Comic Sans MS"><%=dateText%><%=comment_info%><font>
						</font></font></td>
						<td width="450" valign="top"><font face="Comic Sans MS"><e:whitespaceAdjust
							text="<%= log_text %>" /></font></td>
					</tr>
					<%
          
				}

				if (itemCount == 0) {
					String keyword_name=keyword.replaceAll("_"," ");
					%>
					<tr align="center">
						<td colspan="2">
							<font face="Comic Sans MS" size="+1">No entries for<br> "<%=keyword_name%>: <%=keyword_description%>"</font> <a href="logEntry.jsp?keyword=<%=keyword%>"><img src="graphics/logbook_pencil.gif" border="0" align="middle" alt=""></a>
						</td>
					</tr>
					<%
				}
         	%>
			</table>
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
