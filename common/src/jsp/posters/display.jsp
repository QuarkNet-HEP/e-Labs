<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.apache.regexp.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>

<%
	String dfile = request.getParameter("name");
	if (dfile == null || dfile.equals("")) {
	    throw new ElabJspException("Missing poster name.");
	}
	And q = new And();
	q.add(new Equals("name", dfile));
	q.add(new Equals("type", "poster"));
	q.add(new Equals("project", elab.getName()));
	ResultSet rs = elab.getDataCatalogProvider().runQuery(q);
	if (rs.isEmpty()) {
	    throw new ElabJspException("The poster (" + dfile + ") was not found in the database.");
	}
	CatalogEntry entry = (CatalogEntry) rs.iterator().next();
	request.setAttribute("title", entry.getTupleValue("title"));
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">		
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<link rel="stylesheet" type="text/css" href="../css/posters.css"/>
		<title>Poster: ${title}</title>
	</head>
	
	<body id="display-poster" class="posters">

<%
	String type = request.getParameter("type"); // paper or poster
	if (type == null) {
	    type = "poster";
	}
	
	String posterUserName = (String) entry.getTupleValue("group");
	ElabGroup posterUser;
	try {
		posterUser = elab.getUserManagementProvider().getGroup(posterUserName);
	}
	catch (Exception e) {
		throw new ElabJspException("An error was encountered while accessing user " + posterUserName + ". " + e.getMessage()); 
	}
	String plotURL = posterUser.getDirURL("plots") + '/';
	File pfn = new File(posterUser.getDir("posters"), dfile);

	HashMap tags = new HashMap();

 
	// For all requests, render the page from the current template_paper.htmt .data file
	// for the poster name passed.
	// template.html determines fields to show on form, and the field types
	// poster.data supplies field values. If file not present, fields are empty
	// GRAPH and DATA files in poster directory determine drop-down menu values for figures
	
	// Read poster template

	String tfile = "template_" + type + ".htmt"; //paper version of the template
	String template;
	try {
		FileReader fr = new FileReader(new File(posterUser.getDir("templates"), tfile));
		int count = 0;
		char buf[] = new char[100000];
		count=fr.read(buf, 0, 100000);
		fr.close();
		template = String.valueOf(buf,0,count);
	}
	catch (Exception e) {
		throw new JspException("Error reading template " + e.getMessage());
	}

	// Read and store tags from poster data file if it exists

	String pdata;
	if (!pfn.exists()) {
	    throw new ElabJspException("Poster data file does not exist");
	}
	// Read the poster data file

	try {
		FileReader fr = new FileReader(pfn);
		int count = 0;
		char buf[] = new char[100000];
		count = fr.read(buf, 0, 100000);
		fr.close();
		pdata = String.valueOf(buf, 0 ,count);
	}
	catch (Exception e) {
		throw new JspException("Error reading poster file " + e.getMessage());
	}

	// Store poster data into hash table, keyed by "tagtype:tagname"

	RE re = new RE("%(FIG|PARA|WORDS):([A-Z0-9]+)%\\n(.*?\\n)%END%");
	re.setMatchFlags(RE.MATCH_SINGLELINE);
	int p = 0;
	while (re.match(pdata, p)) {
		String tagtype = re.getParen(1);
		String tagname = re.getParen(2);
		String tagval = re.getParen(3).trim();
		p = re.getParenEnd(0);
		tags.put(tagtype + ":" + tagname, tagval);
	}
  

	// Merge tag values into html template, by iterating over hash
	// of tag values and inserting them into the template string;
	// then write template into (user's) poster_mgb.html file

	Iterator it = tags.keySet().iterator();
	String prevKey = null;
	while (it.hasNext()) {
		String key = (String) it.next();
		StringBuffer sb = new StringBuffer((String) tags.get(key));
		// Have to write a down and dirty replace for the dollar-sign character. It will throw 
		// an out of bounds exception if left to its own devices.
		int i = sb.indexOf("$", 0);
		while (i >= 0 && i < sb.length()) {
			sb = sb.insert(i, '\\');
			i += 2;
			i = sb.indexOf("$", i);
		}
		if ("paper".equals(type) && key.startsWith("WORDS:CAPTION")) { 
			template = template.replaceAll("%" + key + "%", "Figure " + 
				key.substring(key.length() - 1) + ". " + sb.toString()); 
		}
		template = template.replaceAll("%" + key + "%", sb.toString());
	}

	// Replace empty content fields with "not entered" and empty title fields with blank strings 
	template = template.replaceAll("%PARA:ABSTRACT%", "Not entered"); 
	template = template.replaceAll("%PARA:PROCEDURE%", "Not entered"); 
	template = template.replaceAll("%PARA:RESULTS%", "Not entered"); 
	template = template.replaceAll("%PARA:CONCLUSION%", "Not entered");
	template = template.replaceAll("%PARA:BIBLIOGRAPHY%", "Not entered");
	template = template.replaceAll("%PARA:AUTHORS%", "");
	template = template.replaceAll("%WORDS:TITLE%", ""); 
	template = template.replaceAll("%WORDS:SUBTITLE%", ""); 
	
	if ("paper".equals(type)) {
		// replace src=" with src="+ path to plots (in user area).
		template = template.replaceAll("src=\"","src=\"" + plotURL); //really only matters for paper
		template = template.replaceAll("%WORDS:CAPTION1%", ""); 
		template = template.replaceAll("%WORDS:CAPTION2%", ""); 
		template = template.replaceAll("%WORDS:CAPTION3%", ""); 
		template = template.replaceAll("%WORDS:CAPTION4%", ""); 
		template = template.replaceAll("%WORDS:CAPTION5%", ""); 
		template = template.replaceAll(plotURL + "%FIG:FIGURE1%", ""); 
		template = template.replaceAll(plotURL + "%FIG:FIGURE2%", ""); 
		template = template.replaceAll(plotURL + "%FIG:FIGURE3%", ""); 
		template = template.replaceAll(plotURL + "%FIG:FIGURE4%", ""); 
		template = template.replaceAll(plotURL + "%FIG:FIGURE5%", ""); 		
		
	}

	out.println(template);
%>

	</body>
</html>