<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page errorPage="../include/errorpage.jsp" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="org.apache.regexp.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Make-Edit Posters</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column-wide.css"/>
		<script type="text/javascript" src="../include/elab.js"/>
	</head>
	
	<body id="new-poster" class="posters">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-posters.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>Make or edit your poster</h1>

<%
	String title = "Make/Edit Poster";
	Date now = new Date();
	DateFormat df = new SimpleDateFormat("MM/dd/yyyy");
	String dateString = df.format(now);
	String singleQuote = "&#39;";
	String doubleQuote = "&#34;";


	boolean posterTitleEntered = false; //true if the title field is filled in by the user.
	boolean posterNameEntered = false; //true if the field is filled in by the user.
	
	
	String dfile = ""; //data file (e.g., poster.data)
   
	String selectDefault = "Select graphic for figure.";
	HashMap tags = new HashMap();
	String pdata = ""; // data written to the poster.data file.

	String posterName = request.getParameter("posterName");
	if (posterName != null) {
    	posterName = posterName.trim();
	    if (posterName.length() > 0) {
    	    posterNameEntered = true;
        	posterName = posterName.replace(' ', '_');
	        posterName = posterName.replace('/', '_');
    	    posterName = posterName.toLowerCase();
        	dfile = posterName + ".data";
	    }
	}

	String posterTitle = request.getParameter("WORDS:TITLE");
	if ((posterTitle != null) && (posterTitle.length() == 0)) {
	    throw new ElabJspException("Missing poster title. Please go back and enter the title for the poster.");
	}

	String reqType = request.getParameter("button");
	String posterDir = user.getDir("posters");
	String posterDirURL = user.getDirURL("posters");
	String plotDir = user.getDir("plots");
	String plotDirURL = user.getDirURL("plots");
	String templateDir = user.getDir("templates");

if (reqType != null && (reqType.equals("Make Poster")||reqType.equals("View Poster"))) {
    Enumeration fields = request.getParameterNames();
    while (fields.hasMoreElements()) {
        String name = (String) fields.nextElement();
        String val = request.getParameter(name);
        val=val.replaceAll("\"", doubleQuote); //Avoid double quotes
        RE re = new RE("(PARA|WORDS|FIG):([A-Z0-9]+)");
        if (val.length() > 0 && re.match(name) && !val.equals(selectDefault)) {
            pdata += "%" + name + "%\n" + val + "\n" + "%END%\n";
        }
    }
    try {
		if (!posterNameEntered) {
		    throw new ElabJspException("Missing poster name. Please go back and enter the filename for the poster.");
        }
            
		// TODO: this all needs to go into the new replica API rather than
		//       using the rc.data api
		// ensure the posterDir exists
		new File(posterDir).mkdirs();
		
		File f = new File(posterDir, dfile);
		boolean fileExists = f.exists();  // we want to check before writing into rc.data so we don't fail.
		PrintWriter pw = new PrintWriter(new FileWriter(f));
		pw.println(pdata);
		pw.close();
		    
		//get metadata 
		String author = request.getParameter("PARA:AUTHORS");
		author = author.replace('\n',' ');
		
		ArrayList meta = new ArrayList();
		meta.add("year string " + user.getGroup().getYear());
		meta.add("state string " + user.getGroup().getState());
		meta.add("city string " + user.getGroup().getCity());
		meta.add("school string " + user.getGroup().getSchool());
		meta.add("teacher string " + user.getGroup().getTeacher());
		meta.add("project string " + elab.getName());
		meta.add("group string " + user.getGroup().getName());
		meta.add("type string " + "poster");
		meta.add("title string "+ request.getParameter("WORDS:TITLE"));
		meta.add("author string "+ author);
		meta.add("date date " + dateString);
		meta.add("name string " + dfile);
		meta.add("plotURL string " + plotDirURL);
		
		DataCatalogProvider dcp = elab.getDataCatalogProvider();
		if(meta != null && dfile != null) {
		    dcp.insert(DataTools.buildCatalogEntry(dfile, meta));
		}
    }
    catch (ElabJspException e) {
        throw e;
    }
    catch (Exception e) { 
        throw new JspException(e.getMessage(), e);
    }
}

// For all requests, render the page from the current template.html and poster.data file
// template.html determines fields to show on form, and the fiel types
// poster.data supplies field values. If file not present, fields are empty
// GRAPH and DATA files in poster directory determine drop-down menu values for figures

// Read poster template

String tfile = "template_poster.htmt";
String template = "";
try {
    FileReader fr = new FileReader(new File(templateDir, tfile));
    int count = 0;
    char buf[] = new char[100000];
    count = fr.read(buf, 0, 100000);
    fr.close();
    template = String.valueOf(buf, 0, count);
}
catch (Exception e) {
    throw new JspException("Error reading template " + tfile + ": " + e.getMessage(), e);
}

// Read and store tags from poster data file if it exists - this can't work if you have no posterName in entry
if (posterNameEntered && posterTitleEntered) { // if not entered, then we will use pdata that we built from input parameters.
    File physicalF = new File(posterDir, dfile);
    pdata = "";
    if(physicalF.exists()) {

        // Read the poster data file

        try {
            FileReader fr = new FileReader(new File(posterDir, dfile));
            int count = 0;
            char buf[] = new char[100000];
            count=fr.read(buf, 0, 100000);
            fr.close();
            pdata = String.valueOf(buf, 0, count);
        }
        catch (Exception e) {
            throw new JspException("Error reading template " + tfile + ": " + e.getMessage(), e);
        }
    }

    // Store poster data into hash table, keyed by "tagtype:tagname"

    RE re = new RE("%(FIG|PARA|WORDS):([A-Z0-9]+)%\\n(.*?\\n)%END%");
    re.setMatchFlags(RE.MATCH_SINGLELINE);
    int p=0;
    while (re.match(pdata,p)) {
        String tagtype = re.getParen(1);
        String tagname = re.getParen(2);
        String tagval = re.getParen(3).trim();
        p = re.getParenEnd(0);
        //          if (tagtype.equals("FIG")) tagval = tagval.trim();
        tags.put(tagtype+":"+tagname, tagval);
    }
}

// Find files posted to plot directory

Map images = new TreeMap();
And q = new And();
Or or = new Or();
or.add(new Equals("type", "plot"));
or.add(new Equals("type", "uploadedimage"));
q.add(or);
q.add(new Equals("project", elab.getName()));
q.add(new Equals("group", user.getGroup().getName()));

ResultSet rs = elab.getDataCatalogProvider().runQuery(q);

if (rs != null) {
	Iterator i = rs.iterator();
	while (i.hasNext()) {
	    CatalogEntry e = (CatalogEntry) i.next();
	    String lfn = e.getLFN();
	    String name = (String) e.getTupleValue("name");
	    if (lfn.endsWith(".gif") || lfn.endsWith(".jpg") || lfn.endsWith(".png") || lfn.endsWith(".jpeg")) {	        
	        images.put(name != null ? name : lfn, lfn);
	    }
	}
}

pageContext.setAttribute("images", images);
%>
	<!-- Show instructions -->
	<ul>
		<li>
			Fill in all the fields including Poster File Name if it is missing.  
			This is the name the poster file will get on the server. If you are 
			making a new poster, do not use a name you have already used. To
     	            see the posters you have made, click <b>Edit Posters</b> above.
     	        </li>
		<li>
			To view the plots that you might want to include for the figures 
			in your poster, click <b>View Plots</b> in the navigation bar. 
			You can fill in fields for up to five figures. You don't have to 
			fill them all in.
		</li>
		<li>
			Click <b>Make Poster</b> to save the data for the poster.
		</li>
	</ul>


	<!-- Emit input form for replacement tags found in poster template -->

	<form method="get">
           <table width="650">
                <tr>
                	<td valign="top" align="right">Poster Filename:<br>(e.g.,poster_lifetime)</td>
                	<td valign="top"><e:trinput type="text" name="posterName"/></td>
                </tr>
      
<%
                RE re = new RE("%(PARA|FIG|WORDS):([A-Z0-9]+)%");
                int p = 0; // search pointer
                String ht = "";
                while (re.match(template, p)) {
                    String type = re.getParen(1);
                    String name = re.getParen(2);
                    String lowerPart = (name.substring(1, name.length())).toLowerCase();
                    String fixedName = name.substring(0, 1) + lowerPart;
                    String val = (String) tags.get(type + ":" + name);
                    if ( (val == null) || (val.length() == 0)) {
                        if (name.equals("DATE")) {
                            val = dateString;
                        }
                        else {
                            val = "";
                        }
                    }
                    pageContext.setAttribute("type", type);
                    pageContext.setAttribute("value", val);
                    pageContext.setAttribute("name", name);
                    pageContext.setAttribute("plotsurl", user.getDirURL("plots"));
                    int previewIndex = 0;
                    %>
                    	<tr>
                    		<td align="right" valign="top"><%= fixedName %></td>
                    		<c:choose>
                    			<c:when test="${type == 'PARA'}">
                    				<td>
                    					<textarea name="${type}:${name}" rows="6" cols="80">${value}</textarea>
                    				</td>
                    			</c:when>
                    			<c:when test="${type == 'WORDS'}">
                    				<td>
                    					<input size="50" maxlength="1000" name="${type}:${name}"
                    						value="<%= val.replaceAll("\"", doubleQuote) %>"/>
                    				</td>
                    			</c:when>
                    			<c:when test="${type == 'FIG'}">
                    				<td>
                    					<select size="1" name="${type}:${name}">
                    						<option><%= selectDefault %></option>
                    						<c:forEach items="${images}" var="image">
                    							<c:choose>
                    								<c:when test="${value == image.key}">
                    									<option selected="true">${image.key}</option>
													</c:when>
													<c:otherwise>
														<option>${image.key}</option>
													</c:otherwise>
												</c:choose>
                    						</c:forEach>
                    					</select>
                    				</td>
                    			</c:when>
                    		</c:choose>
	                    </tr>
	                <%
	                p = re.getParenEnd(0);
                }
	   %>
		<tr>
			<td colspan="2" align="center">
	            <input type="submit" name="button" value="Make Poster"/>
    	        <font size="-1">To see poster, don't block popups!</font>
			</td>
		</tr>
            
	</form>
</table>
</span></center>


<%
//this functionality is not working as of 8-19-04. Must go through search.jsp to view it...

if ("Make Poster".equals(reqType)) {
    if (posterNameEntered && posterTitleEntered) {
        // If "Make Poster" request, merge tag values into html template, by iterating over hash
        // of tag values and inserting them into the template string;
        // then write template into (user's) poster_mgb.html file XXXX

        Iterator it = tags.keySet().iterator();
        while (it.hasNext()) {
            String key = (String) it.next();
            template = template.replaceAll("%" + key + "%", (String) tags.get(key));
        }

        // Write out the new poster

        try {
            String htmlName = posterName + ".html";
            File f = new File(posterDir, htmlName);
            PrintWriter pw = new PrintWriter(new FileWriter(f));
            pw.println(template);
            pw.close();
            // Add metadata to LFN for data file

            String posterURL = "../posters/view.jsp?name=" + dfile;

			%> <e:popup href="<%= posterURL %>" target="poster" width="700" height="900"/> <%
        }
        catch (Exception e) { 
            out.println(e.getMessage()); 
        }
    }
}


%>

			</div>
			<!-- end content -->	
		
			<div id="footer">
			</div>
		</div>
		<!-- end container -->
	</body>
</html>

