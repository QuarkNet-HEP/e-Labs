<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Manage References</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/library.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<script type="text/javascript" src="../include/elab.js"></script>
	</head>
	<body id="control-references" class="library">
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-library.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">
<%
	//perform the metadata search
	DiskFileUpload fu = new DiskFileUpload();
	String type = null;
	
	if (fu.isMultipartContent(request)) {
    	fu.setSizeMax(10*1024*1024);    //10MB max
    	//if a file is to be uploaded 
    	FileItem fileItem;  //to be set in the loop
    	try {
    		List fileItems = fu.parseRequest(request);
    		Iterator i = fileItems.iterator();
    		String origName = type + ".t";
            String fpath = elab.getAbsolutePath(elab.getName() + "/" + origName);
            File tosave=new File(fpath);
            
    		while (i.hasNext()) {
        		FileItem fi = (FileItem) i.next();
        		if (fi.isFormField()) {//it's the uploaded file
        			if ("type".equals(fi.getFieldName())) {
        				type = fi.getString();
        			}
        		}
        		else {
					if (fi.getSize() <= 0) {
						throw new ElabJspException("Empty file");
					}
					else {
						fi.write(tosave);
					}
				}
			}
            if (type == null || !type.equals("reference") && !type.equals("FAQ") && !type.equals("glossary") && !type.equals("news")) {
				throw new ElabJspException("Unable to determine type. Please select glossary or reference.");
			}
    
            %> <font color = "green">Written Successfully to <%=origName%>!</font><br /> <%
            
            And and = new And();
		    and.add(new Equals("project", elab.getName()));
		    and.add(new Equals("type", type));
            ResultSet rs = elab.getDataCatalogProvider().runQuery(and);

			//Clears database
            if (rs != null) {
            	i = rs.iterator();
            	while (i.hasNext()) {
                    CatalogEntry e = (CatalogEntry) i.next();
					elab.getDataCatalogProvider().delete(e);
                    out.println(e.getLFN() + " deleted.<br>");
                }
			}
			%> Deletion successful!!<br /> <%
			
			//reads the newly created file into the Database
			FileReader fin = new FileReader(fpath);
			BufferedReader br = new BufferedReader(fin);
          
			String line;
			while ((line = br.readLine()) != null) {
				String name = line;
				// setup
				List meta = new ArrayList();
				meta.add("type string " + type);
				meta.add("project string " + elab.getName());
				meta.add("name string " + name);
				StringBuffer info = new StringBuffer();
				boolean isFirst = true;
				line = br.readLine();
				while (!"-END-".equals(line)) {
					if (isFirst) {
						isFirst = false; 
					}
					else {
						info.append('\n');
						info.append(line);
						line = br.readLine();
					}
					meta.add("description string " + info); 
					CatalogEntry e = DataTools.buildCatalogEntry(name, meta);
					elab.getDataCatalogProvider().insert(e);                        
				}
                %> <font color="green">Written Successfully to <%=type%> Database!</font><br /> <%
			}
		}
		catch (IOException e) {
			throw new ElabJspException("Cannot write to " + type + " Database!");
		}
	}

	if (type == null) {
    	type = request.getParameter("type");
    }
	if (type == null) {
    	type = "NA";
    }
	String format = request.getParameter("format");
	request.setAttribute("type", type);
%>


	<h1>Enter/Update References/Glossary/FAQ/News items.</h1>

	<table>
		<tr>
			<th>
				Select an action and item type from the pull-downs and click <B>Go!</b>.
			</th>
		</tr>
		<tr>
			<td>
				<ul>
					<li>
						Download - means to copy data from the server to your local computer.
						You can download all the references you have defined.
					</li>
					<li>
						Upload - means copy data in a local file on your computer to the 
						database on the server. You can upload multiple item definitions 
						at once instead of using <B>Add</B> to work with one at at time. 
						Choose the item type with the radio buttons and use the last form 
						on this page to browse your computer for the file and click 
						<b>Upload</b>. It is important to have the references in your 
						file in standard format.  Use with caution because it will delete 
						any current references you have.
					</li> 
				</ul>
			</td>
		</tr>
	</table>
	<form action="../jsp/searchReference.jsp" name="action_form" method="get">
		<e:trselect name="f" 
			valueList="view, delete, upload, download, add"
			labelList="View, Delete, Upload, Download, Add"/>
		<e:trselect name="t"
			valueList="reference, glossary, FAQ, news"
			labelList="Reference, Glossary, FAQ, News"/>

		Item(s).<br />
		<input type='submit' name='submit' value='Go!' />
	</form>

	<c:choose>
		<c:when test="${type == 'NA'}">
     		<hr />
    		<form name ="file_form" method ="get">
				<label><input type="radio" name="type" value="reference" checked="true" />References</label>
				<label><input type="radio" name="type" value="FAQ" />FAQ</label>
				<label><input type="radio" name="type" value="news" />News</label>
				<label><input type="radio" name="type" value="glossary" />Glossary</label>
				<br />
				<hr />
				Download data from Server  
    			<input type="submit" value="Download" />
    			<br />
    			<hr />
    		</form>
    		<form name ="upform" method ="post" enctype="multipart/form-data">
    			Upload data onto Server (make sure your file has the correct format.)<br /><br />
    			<label>Choose a local file <input type="file" name="filename_user" /></label><br /><br />
				<label><input type="radio" name="type" value="reference" checked="true" /> References</label>
				<label><input type="radio" name="type" value="FAQ" /> FAQ</label>
				<label><input type="radio" name="type" value="news" /> News</label>
				<label><input type="radio" name="type" value="glossary" /> Glossary</label>
				<br />
				<hr />
				<input type="submit" value="Upload" />
				<br />
    		</form>
    	</c:when>
    	<c:otherwise>
    		<%
				try {
					if (type == null || !type.equals("reference") && !type.equals("FAQ") && !type.equals("glossary") && !type.equals("news")) {
						throw new ElabJspException("Unable to determine type. Please select glossary or reference.");
					}
               
        			String filename = type+".t";
        			String fpath = elab.getAbsolutePath(elab.getName() + "/" + filename);
					FileWriter fw = new FileWriter(fpath, false);

					And and = new And();
					and.add(new Equals("type", type));
					and.add(new Equals("project", elab.getName()));
        			
        			ResultSet rs = elab.getDataCatalogProvider().runQuery(and);
        			if (rs.isEmpty()) {
        				throw new ElabJspException("There are no items to save to file!");
        			}
        			else {
        				Iterator i = rs.iterator();
        				while (i.hasNext()) {
        					CatalogEntry e = (CatalogEntry) i.next();
        					String lfn = e.getLFN();
            				String refHeight = "250";
            				String info = (String) e.getTupleValue("description");
							
							fw.write(lfn);
							fw.write("\n");
							fw.write(info);
							fw.write("\n-END-\n");
						}
            			fw.close();
        				%> <font color="green">Written Successfully to <%=filename%>!</font><br> <%
                		%> <h2><a href = "<%= "../" + filename %>"> Open/Download</a></h2><br> <%
        			}
    			} 
				catch (IOException e) {
   					throw new ElabJspException(e);
       			}
			%>
		</c:otherwise>
	</c:choose>
	
			</div>
		</div>
	</body>
</html>        
