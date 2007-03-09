<%@ page buffer="1000kb" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.Ostermiller.util.RandPass" %>
<%@ page import="java.sql.*" %>

<HTML>
<HEAD>
<TITLE>Register Students</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
<%@ include file="include/javascript.jsp" %>
</HEAD>
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common.jsp" %>
<%@ include file="common.jsp" %>

<!-- creates variables ResultSet rs and Statement s to use: -->
<%@ include file="include/jdbc_userdb.jsp" %>

<body bgcolor=FFFFFF  vlink=ff6600>
<center>
<TABLE WIDTH=804>
<TR><TD>
	<TABLE WIDTH=800 CELLPADDING=4>
	<TR><td>&nbsp;</td></tr>
	<TR><TD  bgcolor=black>
	<FONT FACE=ARIAL COLOR=white SIZE=+1>
	<B>Cosmic Ray e-Lab Student Registration</B>
	</TD></TR></table>

</td></tr>

<% 
String login = (String)session.getAttribute("login");
String role = (String)session.getAttribute("role");
if (role == null || !role.equals("teacher")) { //Short circuit operator.  Do not change order.%>
<tr><td>
To register research groups, teachers or students, you need to have a teacher login. If you have a teacher login, log in with it.  If you need help, contact <A HREF="mailto:quarknet@fnal.gov">quarknet@fnal.gov</A>.
</td></tr>
</table>
<%
return;
}
%>

<%
boolean valid = true;

int teacherID = -1;
String teacherUA = null;
ArrayList teacherDetectorIDs = new ArrayList();
ArrayList teacherGroups = new ArrayList();
try {
    // Use transactions to recover from failure.
    rs = s.executeQuery("select teacher_id, userarea from research_group where name = '" + login + "'");
    if (rs.next()) {
        teacherID = rs.getInt("teacher_id"); 
        teacherUA = rs.getString("userarea");
    }
    if (teacherUA == null || teacherID == -1)
        valid = false;

    rs = s.executeQuery(
        "select detectorid from research_group_detectorid " + 
        "where research_group_id = (select id from research_group " + 
        "where name = '" + login + "')"); 
    while (rs.next())
       teacherDetectorIDs.add(rs.getString("detectorid"));

    rs = s.executeQuery(
        "select name from research_group " +
        "where teacher_id = " + teacherID);
    while (rs.next())
        teacherGroups.add(rs.getString("name"));
} catch (Exception e) {
    valid = false;
}
   
String optionList = "<option value=\"discard\">Choose group</option>";
for (Iterator ite = teacherGroups.iterator(); ite.hasNext();) {
    String name = (String)ite.next();
    if (!name.equals(login)) {optionList += "<option value=\"" + name + "\">" + name + "</option>";}
}

String ret = "";
String successTable = "<table cellpadding=10><tr><td><strong>Group</strong></td><td><strong>Password</strong></td></tr>";
String submit = request.getParameter("submit");
if (submit != null && submit.equals("I\'m done")) {

                    
    if (valid) {
        try {
            // Use transactions to recover from errors.
            conn.setAutoCommit(false);
            RandPass rp = new RandPass();
            HashMap researchTracker = new HashMap();
            int studentsAdded = 0;
            for (int formNum = 0; formNum < 10; formNum++) {
                String last = request.getParameter("last" + formNum);
                String first = request.getParameter("first" + formNum);
                String resName = request.getParameter("res_name" + formNum);
                String resNameChoose = request.getParameter("res_name_choose" + formNum);
                String upload = request.getParameter("is_upload" + formNum);
                String isNewGroup = request.getParameter("is_new" + formNum);
                String survey = request.getParameter("is_survey" + formNum);
                String pass;

                boolean isOldGroup = false;
                if (resName == null || resName.equals("Group Name")) {
                    isOldGroup = true;
                    resName = resNameChoose;
                }

                if (last == null || first == null || resName == null ||
                    last.equals("") || first.equals("") || resName.equals("") ||
                    last.equals("Last Name") || first.equals("First Name") || resName.equals("Group Name") || 
                    resName.equals("discard")) { 
                    continue;
                }
                
                // More work to do if we haven't seen this one yet.
                if (!researchTracker.containsKey(resName) && !isOldGroup) {
                    researchTracker.put(resName, new Boolean(true));
                    pass = rp.getPass();
                    rs = s.executeQuery("select * from research_group where name = '" + resName + "'");
                    int nameAddOn = 0;
                    while (rs.next()) {
                        nameAddOn++;
                        rs = s.executeQuery("select * from research_group where name = '" + resName + nameAddOn + "'");
                    }
                    if (nameAddOn > 0)
                        resName += nameAddOn;
                    String resGroupUA = teacherUA.substring(0, teacherUA.lastIndexOf("/") + 1) + resName;
                    s.executeUpdate(
                        "insert into research_group(name, password, teacher_id, role, userarea, ay, survey) " + 
                        "values('" + resName + "', '" + pass + "', '" + teacherID + "', '" + 
                        (upload != null && upload.equals("yes") ? "upload" : "user") + "', '" + resGroupUA + 
                        "','AY2004', '" + (survey != null && survey.equals("yes") ? "t'" : "f'") + ")");
                    s.executeUpdate(
                        "insert into research_group_project(research_group_id, project_id) " +
                        "values((select id from research_group where name = '" + resName + "'), 1)"); 
                    int exitCode = 0;
                    String[] cmd = new String[]{
                        "bash", 
                        "-c", 
                        "/bin/mkdir -p  " + home + "/cosmic/users/" + resGroupUA + "/cosmic/posters; " + 
                        "/bin/mkdir -p  " + home + "/cosmic/users/" + resGroupUA + "/cosmic/plots; " +
                        "/bin/mkdir -p  " + home + "/cosmic/users/" + resGroupUA + "/cosmic/scratch;"};
                    Process p = Runtime.getRuntime().exec(cmd);
                    if (p.waitFor() != 0)
                        throw new Exception("Error creating directory for group " + resGroupUA + ".  Cannot continue.");

                    // Connect the detector id from the teacher with the group if it exists.
                    for (Iterator iter = teacherDetectorIDs.iterator(); iter.hasNext();) {
                        String statement = 
                            "insert into research_group_detectorid(research_group_id, detectorid) " +
                            "values((select id from research_group where name = '" + resName + "'), " + 
                            (String)iter.next() + ")";
                        s.executeUpdate(statement);
                    }
                    successTable += "<tr><td>" + resName + "</td><td>" + pass + "</td></tr>";
                }

                // Just insert the student into the DB.
                first = first.replaceAll(" ", "").toLowerCase();
                last = last.replaceAll(" ", "").toLowerCase();
                String studentName = first.substring(0, 1) + last.substring(0, (last.length() < 7 ? last.length() : 7));
                int studentNameAddOn = 0;
                rs = s.executeQuery("select * from student where name = '" + studentName + "'");
                while (rs.next()) {
                    studentNameAddOn++;
                    rs = s.executeQuery("select * from student where name = '" + studentName + studentNameAddOn + "'");
                }
                if (studentNameAddOn > 0)
                    studentName += studentNameAddOn;

                s.executeUpdate(
                    "insert into student(name) values('" + studentName + "')");
                s.executeUpdate(
                    "insert into research_group_student(research_group_id, student_id) " +
                    "values((select id from research_group where name = '" + resName + "'), " +
                    "(select id from student where name = '" + studentName + "'))");
                if (survey != null && survey.equals("yes"))
                    s.executeUpdate(
                        "insert into survey(student_id, project_id) values(" +
                        "(select id from student where name = '" + studentName + "'), 1)"); 
                studentsAdded++;
            }
        } catch (Exception e) {
            valid = false;  
            //StringWriter temp = new StringWriter();
            //e.printStackTrace(new PrintWriter(temp)); 
            ret =
                "Error processing your students ... please contact the administrator about this error.  " +
                e + ": <br>"; //+ temp.toString();
            conn.rollback();
        } finally {
            conn.commit();
        }
    }
%>
<tr>
<td align="center">
<br>
<font face=arial size="-1">
<%
if (valid) {
%>
    <font color=green>
    Your student registration completed succesfully.</font>
    <br>
    <br>
    <table><tr><td align="left"><font face=arial size="-1">The groups we created for you (and their associated passwords) are listed below.<br>
    If one of the groups you requested already existed in our project, your group name was altered<br>
    slightly to ensure uniqueness.  You may now use the File...Save feature in your browser to save<br>
    the information below.</font></td></tr></table>
    <br>
    <br>
    <%=successTable%></table>
<%
} else {
%>
    <font color=red>
    A problem occured while registering with your students.</font>
    <br>
    Error: <%=ret%>
<%
}
out.write("</td></tr>");
} //end of check for submit
else {
%>
<font face=arial size="-1">
<tr>
<td>
    <UL>
        <LI><font face=arial size="-1">Register new students below.  To register more students, click on the&nbsp; 
        <strong><font face=arial size="+1">+</font></strong> &nbsp;button.
        <br>
        <LI>We will create new groups and their associated passwords for you.
        <br>
        <br>
        <LI>Select &nbsp;<img src="graphics/upload_registration.gif" valign="middle">&nbsp; if you want to grant the new group upload permissions for your detectors.
        <br>
        <LI>Select &nbsp;<img src="graphics/logbook_pencil.gif" valign="middle">&nbsp;&nbsp;&nbsp; if you want the new group to take the pretest.
        <br>
        <br>
        </font>
    </UL>
</font>
</td>
</tr>
    <FORM name="register" method="post" 
    action="https://<%=System.getProperty("host")+System.getProperty("sslport")%>/elab/cosmic/registerStudents.jsp"> 
    <tr>
    <table cellpadding="0" cellspacing="0" border="0" align="center" width="800">
<%
    for (int i = 0; i < 10; i++) {
        String visibility = "";
        String minusButton = "";
        if (i == 0)
            visibility = "visibility:visible; display:;";
        else
            visibility = "visibility:hidden; display:none;";

        if (i > 0)
            minusButton = "<input name=\"less_reg" + i + "\" type=\"submit\" value=\"-\" onClick=\"this.form.first" + i + ".value='First Name'; this.form.last" + i + ".value='Last Name'; this.form.is_new" + i + ".value='Make new group'; aLs('res_name_text" + i + "').visibility = 'hidden'; aLs('res_name_text" + i + "').display = 'none'; aLs('res_name_chooser" + i + "').visibility = 'visible'; aLs('res_name_chooser" + i + "').display = ''; HideShow(\'group_line" + i + "\');HideShow(\'plus_line" + i + "\'); aLs('is_upload_box" + i + "').visibility = 'hidden'; aLs('is_upload_box" + i + "').display = 'none'; aLs('is_survey_box" + i + "').visibility = 'hidden'; aLs('is_survey_box" + i + "').display = 'none'; return false;\">";

        String textChange = "var opts = this.form.res_name_choose" + i + ".options.length; ";
        for (int j = i+1; j < 9; j++) {
            textChange += "this.form.res_name_choose" + j + ".options[opts]=new Option(this.form.res_name" + i + ".value, this.form.res_name" + i + ".value); this.form.res_name_choose" + j + ".options[opts].selected = true;";
        }
%>
    <tr>
    <td align="left">
        <div id="group_line<%=i%>" style="<%=visibility%> border-left:3px solid #AAAAAA; padding-left:5px; padding-bottom:5px; padding-top:5px;">
        <input type="text" name="first<%=i%>" size="14" maxlength="30" value="First Name">&nbsp;&nbsp;
        <input type="text" name="last<%=i%>" size="14" maxlength="30" value="Last Name">&nbsp;&nbsp;
        <input id="res_name_text<%=i%>" type="text" name="res_name<%=i%>" size="14" maxlength="30" value="Group Name" style="visibility:hidden; display:none;" onChange="<%=textChange%>">
        <select id="res_name_chooser<%=i%>" style="visibility:visible; display:;" name="res_name_choose<%=i%>">
            <%=optionList%>
        </select>
        <font face=arial size="-1">
        &nbsp;&nbsp;<input type="submit" name="is_new<%=i%>" value="Make new group" onClick="HideShow('res_name_text<%=i%>'); HideShow('res_name_chooser<%=i%>');HideShow('is_upload_box<%=i%>');HideShow('is_survey_box<%=i%>'); if (this.form.is_new<%=i%>.value=='Make new group') { this.form.is_new<%=i%>.value='Choose group'; } else { this.form.is_new<%=i%>.value='Make new group'; } return false;">
        </div>
    </td>
    <td align="left" valign="middle">
        <div id="is_upload_box<%=i%>" style="visibility:hidden; display:none;">
            <font face=arial size="-1">
            <input type="checkbox" name="is_upload<%=i%>" value="yes"><img src="graphics/upload_registration.gif" valign="middle">
            &nbsp;&nbsp;&nbsp;
            </font>
        </div>
    </td>
    <td align="left" valign="middle">
        <div id="is_survey_box<%=i%>" style="visibility:hidden; display:none;">
            <font face=arial size="-1">
            <input type="checkbox" name="is_survey<%=i%>" value="yes" checked><img src="graphics/logbook_pencil.gif" valign="middle"></font>
            &nbsp;&nbsp;&nbsp;
            </font>
        </div>
    </td>
    <td align="right">
        <div id="plus_line<%=i%>" style="<%=visibility%> padding-right:5px;">
        <%=minusButton%>
<%
        // Don't show the plus button on the last line.
        if (i != 9) {
%>
        <input name="more_reg<%=i%>" type="submit" value="+" onClick="HideShow('group_line<%=i+1%>');HideShow('plus_line<%=i+1%>');return false;">
<%
        }
%>
        </div>
    </td>
    </tr>
<%
    }
%>
    <tr>
    <td>&nbsp;</td>
    <td align="right" colspan="4">
        <br>
        <input type="submit" name="submit" value="I'm done">
    </td>
    </tr>
    </table>
    </tr>
    </form>
<%
}
if (s != null)
    s.close();
if (conn != null)
    conn.close();
%>


</td></tr>
</table>
</center>
</body>
</html>
