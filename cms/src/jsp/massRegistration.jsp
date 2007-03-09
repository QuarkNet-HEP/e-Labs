<%@ page buffer="1000kb" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.Ostermiller.util.LabeledCSVParser" %>
<%@ page import="com.Ostermiller.util.CSVParser" %>
<%@ page import="com.Ostermiller.util.ExcelCSVParser" %>
<%@ page import="com.Ostermiller.util.ExcelCSVPrinter" %>
<%@ page import="com.Ostermiller.util.RandPass" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="java.sql.*" %>

<HTML>
<HEAD>
<TITLE>Mass Registration</TITLE>
<!-- include css style file -->
<%@ include file="include/style.css" %>
<!-- header/navigation -->
</HEAD>
<%
//be sure to set this before including the navbar
String headerType = "Teacher";
%>
<%@ include file="include/navbar_common_t.jsp" %>
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
	<B>e-Lab Mass Registration</B>
	</TD></TR></table>

</td></tr>

<% 
String login = (String)session.getAttribute("login");
String role = (String)session.getAttribute("role");
String project = (String)session.getAttribute("appName");

if (role == null || !role.equals("teacher")) { //Short circuit operator.  Do not change order.%>
<tr><td>
To register research groups, teachers or students, you need to have a teacher login. If you have a teacher login, log in with it.  If you need help, contact <A HREF="mailto:quarknet@fnal.gov">quarknet@fnal.gov</A>.
</td></tr>
</table>
<%
return;
}
%>
<font face=arial size="-1">
<tr>
<td>
    <UL>
        <LI><font face=arial size="-1">Upload a comma-separated value (CSV) file based on an Excel spreadsheet you already have.
        <br>
        <br>
        <LI>Format your Excel spreadsheet like  <a href="mass_registration.xls">our example</a>. You may omit information in italicized columns. 
        <br>
        <br>
        <LI>In Excel, choose File...Save As.  Save as a CSV (Comma-delimited) file.  Click Yes when Excel <br>warns about features being lost when saving to CSV format.
        <br>
        <br>
        <LI>Upload your CSV file below.  We will create the research groups for you.
        </font>
    </UL>
</font>
</td>
</tr>

<%

String fn = "";             //filename without slashes
String ret = "";
String regFile = "";
boolean valid = true;
String successTable = "<table cellpadding=5><tr><td><strong>Group</strong></td><td><strong>Password</strong></td></tr>";
// Get the file and move it into our database.
if (FileUpload.isMultipartContent(request)) {
    DiskFileUpload fu = new DiskFileUpload();
    fu.setSizeMax(50*1024);   // 50K, it's only text.
    // maximum size that will be stored in memory
    fu.setSizeThreshold(4096);

    java.util.List fileItems = fu.parseRequest(request);

    Iterator it = fileItems.iterator();

    while (it.hasNext()) { 
        FileItem fi = (FileItem)it.next();
        regFile = fi.getName();
        if (regFile == null || regFile.equals("")) {
            continue;
        }
        //fn is the filename without slashes (which regFile has)
        int i = regFile.lastIndexOf('\\');
        int j = regFile.lastIndexOf('/');
        i = (i>j) ? i:j;
        fn = regFile.substring(i+1);
        if (fi.getSize() > 0) {
            fn=fn.replace(' ', '_');       //replace spaces with underscores
            fn=fn.replaceAll("%20", "_");       //replace spaces with underscores
            
            File f = new File("/tmp/" + fn);
            int index = 0;
            while(f.exists()){
                index++;
                f = new File("/tmp/" + fn + "." + index);
            }

            // write the file
            if(f.createNewFile()){
                fi.write(f);
                // Strip the file of Mac or MS-DOS line breaks.
                String[] cmd = new String[]{"bash", "-c", "/usr/bin/perl -pi -e 's/\\r\\n?/\\n/g' /tmp/" + fn};
                Process p = Runtime.getRuntime().exec(cmd);
                if (p.waitFor() != 0) {
                    valid = false;
                    ret =
                        "<CENTER><FONT color= red>" +
                        "Cannot clean line breaks from the  file \"" + f + "\" on the filesystem...contact the administrator about this error." +
                        "</FONT><BR><BR></CENTER>";
                }

                // Parse the registration file.
                LabeledCSVParser lcsvp = null;
                try { 
                    String appType = request.getParameter("application_type");
                    if (appType != null && appType.equals("other"))
                        lcsvp = new LabeledCSVParser(new CSVParser(new FileReader(f)));
                    else
                        lcsvp = new LabeledCSVParser(new ExcelCSVParser(new FileReader(f)));
                } catch (IOException e) {
                    valid = false;
                    ret =
                        "<CENTER><FONT color= red>" +
                        "Error reading file \"" + f + "\" on the filesystem...contact the administrator about this error." +
                        "</FONT><BR><BR></CENTER>";
                } 
                    
                if (lcsvp != null && valid) {
                    try {
                        // Use transactions to recover from failure.
                        conn.setAutoCommit(false);
                        rs = s.executeQuery("select teacher_id, userarea from research_group where name = '" + login + "'");
                        int teacherID = 0;
                        String teacherUA = null;
                        if (rs.next()) {
                            teacherID = rs.getInt("teacher_id"); 
                            teacherUA = rs.getString("userarea");
                        }
                        if (teacherUA == null)
                            throw new Exception("Teacher does not have a user area.  Cannot continue.");
    					// This is only meaningful for the "cosmic" project
 					   ArrayList teacherDetectorIDs = new ArrayList();
                       if (project.equals("cosmic") )  {
                        
							rs = s.executeQuery(
								"select detectorid from research_group_detectorid " + 
								"where research_group_id = (select id from research_group " + 
								"where name = '" + login + "')"); 
							while (rs.next())
							   teacherDetectorIDs.add(rs.getString("detectorid"));
                        }

                        RandPass rp = new RandPass();
                        HashMap researchTracker = new HashMap();
                        String[] csvLine;
                        while ((csvLine = lcsvp.getLine()) != null) {
                            String last = lcsvp.getValueByLabel("Last Name");
                            String first = lcsvp.getValueByLabel("First Name");
                            String resName = lcsvp.getValueByLabel("Research Group Name");
                            String upload = lcsvp.getValueByLabel("Upload");
                            String survey = lcsvp.getValueByLabel("In Survey");
                            String pass;

                            if (last == null || first == null || resName == null ||
                                last.equals("") || first.equals("") || resName.equals("")) { 
                                out.write(
                                    "<CENTER><FONT color= red>" +
                                    "Your file does not conform to the example.  Please make sure you have specified " + 
                                    "a first name, last name and research group name for each student." + 
                                    "  An error has occurred while parsing line " + lcsvp.getLastLineNumber() + 
                                    ".  This line was not processed." + 
                                    "</font><br><br></center>");
                                continue;
                            }
                            
                            // More work to do if we haven't seen this one yet.
                            if (!researchTracker.containsKey(resName)) {
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
                                
								// Generated a default academic year. LQ - 7-24-06
                                Calendar calendar = new GregorianCalendar();
                                int year = calendar.get(Calendar.YEAR);
                                if (calendar.get(Calendar.MONTH) < 7) {
                                     year=year-1;}
                                String ay ="AY" + year;
                                     // old code with hardcoded 2004
                                     //s.executeUpdate(
                                    //"insert into research_group(name, password, teacher_id, role, userarea, ay, survey) " + 
                                    //"values('" + resName + "', '" + pass + "', '" + teacherID + "', '" + 
                                    //(upload != null && upload.equals("yes") ? "upload" : "user") + "', '" + resGroupUA + 
                                   // "','AY2004', '" + (survey != null && survey.equals("yes") ? "t'" : "f'") + ")");

                                s.executeUpdate(
                                    "insert into research_group(name, password, teacher_id, role, userarea, ay, survey) " + 
                                    "values('" + resName + "', '" + pass + "', '" + teacherID + "', '" + 
                                    (upload != null && upload.equals("yes") ? "upload" : "user") + "', '" + resGroupUA + 
                                    "','"+ ay + "', '" + (survey != null && survey.equals("yes") ? "t'" : "f'") + ")");
                               // old code with hardcoded project id of 1 for cosmic
                               // s.executeUpdate(
                                //    "insert into research_group_project(research_group_id, project_id) " +
                               //     "values((select id from research_group where name = '" + resName + "'), 1)"); 
                               s.executeUpdate(
                                    "insert into research_group_project(research_group_id, project_id) " +
                                    "values((select id from research_group where name = '" + resName + "'), (select id from project where name = '" + project + "'))"); 
                                // This code relies a symlink users in the current directory
                                int exitCode = 0;
                                cmd = new String[]{
                                   "bash", 
                                   "-c", 
                                    "/bin/mkdir -p  " + home + "/" + project + "/users/" + resGroupUA + "/"+ project + "/posters; " + 
                                    "/bin/mkdir -p  " + home + "/" + project + "/users/" + resGroupUA + "/" + project + "/plots; " +
                                    "/bin/mkdir -p  " + home + "/" + project + "/users/" + resGroupUA + "/" + project + "/scratch;"};
                               p = Runtime.getRuntime().exec(cmd);
                                if (p.waitFor() != 0)
                                    throw new Exception("Error creating directory for group " + resGroupUA + ".  Cannot continue.");

                                // Only do for cosmic e-Lab  - LQ 7/24/06
                                // Connect the detector id from the teacher with the group if it exists.
                               if (project.equals("cosmic"))
                               {
								   for (Iterator iter = teacherDetectorIDs.iterator(); iter.hasNext();) {
										String statement = 
											"insert into research_group_detectorid(research_group_id, detectorid) " +
											"values((select id from research_group where name = '" + resName + "'), " + 
											(String)iter.next() + ")";
										s.executeUpdate(statement);
									}
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
                                // Changed to make eLab-independent
                                //s.executeUpdate(
                                //    "insert into survey(student_id, project_id) values(" +
                                //    "(select id from student where name = '" + studentName + "'), 1)"); 
                                 s.executeUpdate(
                                    "insert into survey(student_id, project_id) values(" +
                                    "(select id from student where name = '" + studentName + "'), (select id from project where name = '" + project + "'))"); 
                       }
                    } catch (Exception e) {
                        valid = false;  
                        //StringWriter temp = new StringWriter();
                        //e.printStackTrace(new PrintWriter(temp)); 
                        ret =
                            "Error processing your file \"" + f + "\" ...contact the administrator about this error.  " +
                            e + ": <br>"; //+ temp.toString();
                        conn.rollback();
                    } finally {
                        if (lcsvp != null)
                            lcsvp.close();
                        conn.commit();
                    }
                }


            }
            else{
                valid = false;
                ret = "<CENTER><FONT color= red>" +
                    "Cannot write the file \"" + f + "\" on the filesystem...contact the administrator about this error." +
                    "</FONT><BR><BR></CENTER>";
            }
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
    Your mass registration completed succesfully.</font>
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
    A problem occured while mass registering with your file.</font>
    <br>
    Error: <%=ret%>
<%
}
out.write("</td></tr>");
}
else {
%>
    <FORM name="uploadform" method="post" 
        action="https://<%=System.getProperty("host")+System.getProperty("sslport")%>/elab/<%=project%>/massRegistration.jsp" 
        enctype="multipart/form-data">
    <tr>
    <td align="center">
    <br>
    <br>
    <br>
        <font face=arial size="-1"> Registration file (CSV format):</font> <input name="csv_file" type="file" size="15">
        <input name="load" type="submit" value="Upload Registration File">
        <br>
        <br>
        <font face=arial size="-1">File generated by: <input name="application_type" type="radio" value="excel" checked> Excel
        &nbsp;&nbsp;&nbsp;<input name="application_type" type="radio" value="other">Other Application</font>
    </td>
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
