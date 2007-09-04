<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/upload-login-required.jsp" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="be.telio.mediastore.ui.upload.MonitoredDiskFileItemFactory" %>
<%@ page import="be.telio.mediastore.ui.upload.UploadListener" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>



<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Upload Raw Data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<script type="text/javascript" src="../include/upload.js"></script>
        <script type="text/javascript" src="../../dwr/interface/UploadMonitor.js"></script>
        <script type="text/javascript" src="../../dwr/engine.js"></script>
        <script type="text/javascript" src="../../dwr/util.js"></script>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<div id="nav">
						<%@ include file="../include/nav.jsp" %>
						<div id="subnav">
							<%@ include file="../include/nav-upload.jsp" %>
						</div>
					</div>
				</div>
			</div>
			
			<div id="content">

<h1>Upload Raw Data Collected by Cosmic Ray Detector.</h1>


<%--
Re: the upload progress stuff

/* Licence:
*   Use this however/wherever you like, just don't blame me if it breaks anything.
*
* Credit:
*   If you're nice, you'll leave this bit:
*
*   Class by Pierre-Alexandre Losson -- http://www.telio.be/blog
*   email : plosson@users.sourceforge.net
*/
--%>

<%    
	Collection ids = (Collection) user.getAttribute("cosmic:detectorIds");
    if(ids == null || ids.size() == 0) {
        throw new ElabJspException("Your group does not have any detector IDs associated with it. "
                + "This is done when your group is first created.");
    }
    request.setAttribute("detectorIDs", ids);


	String lfn="";              //lfn on the USERS home computer
	String fn = "";             //filename without slashes
	String ds = "";
	String id = "";             //detector id
	String comments = "";       //optional comments on raw data file
	String dataDir = elab.getProperties().getDataDir();
	int channels[] = new int[4];

	List splits = new ArrayList();  //for both the split name and the channel validity information

	if (FileUpload.isMultipartContent(request)) {
	    //BEGIN upload_progress_stuff
	    UploadListener listener = new UploadListener(request, 0);

	    // Create a factory for disk-based file items
	    FileItemFactory factory = new MonitoredDiskFileItemFactory(listener);

    	// Create a new file upload handler
	    ServletFileUpload upload = new ServletFileUpload(factory);
    	//END upload_progress_stuff
    	
		List fileItems = upload.parseRequest(request);

		Iterator it = fileItems.iterator();

		while (it.hasNext()) { 
        	FileItem fi = (FileItem) it.next();
			if (fi.isFormField()) {
            	String name = fi.getFieldName();
            	if (name.equals("detector")) {
                	id = fi.getString();
                	if(id.equals("")) {
                    	throw new ElabJspException("You must enter a detector number for this data.");
					}
				}
				if(name.equals("comments")) {
                	comments = fi.getString();
				}
        	}
			else {
				lfn = fi.getName();
				if (lfn.equals("")) {
                	throw new ElabJspException("Missing file.");
    	        }
	            //fn is the filename without slashes (which lfn has)
    	        int i = lfn.lastIndexOf('\\');
        	    int j = lfn.lastIndexOf('/');
            	i = (i > j) ? i : j;
	            if (i != -1) {
    	            fn = lfn.substring(i + 1);
        	    } 
				if (fi.getSize() == 0) {
				    throw new ElabJspException("Your file is zero-length. You must upload a file which has some data.");
				}
                //new algorithm for filenaming:
   	            //name the raw file id.yyyy.mmdd.index.raw and save the original name in metadata
       	        //index starts at 0 and increments when there are collisions with other filenames
                Date now = new Date();
                DateFormat df = new SimpleDateFormat("yyyy.MMdd");
                String fnow = df.format(now);
				//even newer algorithm: use File.createTempFile!
				File f = File.createTempFile(id + "." + fnow + ".", ".raw", 
				        new File(dataDir));
               	String rawName = f.getName();

               	// write the file
               	fi.write(f);
       	        out.println("<!-- " + rawName + " added to Catalog -->");

		        boolean c = true;
    		    String splitPFNs = "";
	    	    String threshPFNs = "";
	    	    String threshLFNs = "";
    	    	String cpldFrequency = "";
    	    	CatalogEntry entry;
		        //Split is in the portal.appdir along with the rest of our "Applications"
		        String appDir = elab.getProperties().getProperty("app.dir");
		        // This command is here to clean the Mac/DOS style line breaks
		        // Probably could be done better, but this works for now.
		        String cmdNLClean = "/usr/bin/perl -pi -e 's/\\r\\n?/\\n/g' " + f.getAbsolutePath();
		        String cmdSplit = appDir + File.separator +  "Split.pl " + "\"" + f.getAbsolutePath() + "\"" + " " 
		        	+ dataDir + File.separator + id + " " + id;
        		String cmdCompress = "gzip " + f.getAbsolutePath() + " &";
		        ElabUtil.runCommand(cmdNLClean);
		        ElabUtil.runCommand(cmdSplit, out);
        		ElabUtil.runCommand(cmdCompress, out);
           

				//get metadata which contains the lfns of the raw filename AND the split files
				ArrayList meta = null;
				boolean metaSuccess = false;
				boolean totalSuccess = true;        //false if there are any rc.data or meta errors
				File fmeta = new File(f.getAbsolutePath() + ".meta");     //depends on Split.pl writing the meta to rawName.meta
            	if (fmeta.canRead()) {
                	BufferedReader br = new BufferedReader(new FileReader(fmeta));
	                String line = null;
    	            String currLFN = null;
        	        String currPFN = null;
	                while ((line = br.readLine()) != null) {
	                    String[] temp = line.split("\\s", 3);

    	                //if this is a new lfn to add...
        	            if(temp[0].equals("[SPLIT]") || temp[0].equals("[RAW]")){
            	            //add metadata if we have all the information for a previous LFN
                	        if(meta != null && currLFN != null) {
                    	        try {
                    	            entry = DataTools.buildCatalogEntry(currLFN, meta);
                    	            elab.getDataCatalogProvider().insert(entry);
                            	} 
                    	        catch (ElabException e) {
                            	    throw new ElabJspException("Error setting metadata: " + e.getMessage(), e);
	                            }
	                        }

	                        //start a new metadata array
    	                    meta = new ArrayList();
        	                currPFN = temp[1];
            	            currLFN = temp[1].substring(temp[1].lastIndexOf('/') + 1);
                	        if(temp[0].equals("[RAW]")) {
                    	        //don't write the raw datafile to rc.data - already written above
                    	        rawName = currLFN;
	                        }
    	                    else if(temp[0].equals("[SPLIT]")) {
        	                    // Add split physical file name to array list used by ThresholdTimes.
            	                // we actually don't use that any more
            	                splits.add(currLFN);
                            }

	                        //metadata for both RAW and SPLIT files
    	                    meta.add("origname string " + lfn); //add in the original name from the users computer to metadata
        	                meta.add("blessed boolean false");
            	            meta.add("group string " + user.getName());
                	        meta.add("teacher string " + elab.getUserManagementProvider().getTeacher(user).getName());
                    	    meta.add("school string " + user.getSchool());
                        	meta.add("city string " + user.getCity());
	                        meta.add("state string " + user.getState());
    	                    meta.add("year string " + user.getYear());
        	                meta.add("project string " + elab.getName());
            	            comments = comments.replaceAll("\r\n?", "\\\\n");   //replace new lines from text box with "\n"
	                        meta.add("comments string " + comments);
	                    }
    	                else {
	                        meta.add(line);
    	                    String[] tmp = line.split("\\s", 3);
        	                if (tmp[0].equals("cpldfrequency")) {
            	                cpldFrequency += tmp[2] + " ";
        	                }
        	                else if (tmp[0].equals("julianstartdate")) {
        	                	Geometry geometry = new Geometry(elab.getProperties().getDataDir(), id);
								if (geometry == null || geometry.isEmpty()) {
									throw new ElabJspException("Error: no geometry information for detector " + detectorId);
								}
								SortedMap geos = geometry.getGeoEntriesBefore(tmp[2]);
								if (geos.isEmpty()) {
									throw new ElabJspException("Error: no geometry information for detector " + 
										id + " for when this data was taken.");
								}
								GeoEntryBean g = (GeoEntryBean) geos.get(geos.lastKey());
								meta.add("stacked boolean " + (g.getStackedState() ? "true" : "false"));
        	                }
	                    }
    	            }   //done reading file

	                //do one last add at the end of reading the temp metadata file
    	            if (meta != null && currLFN != null) {
    	                try {
    	                    entry = DataTools.buildCatalogEntry(currLFN, meta);
							elab.getDataCatalogProvider().insert(entry);
						}
						catch (ElabException e) {
							throw new ElabJspException("Error setting metadata: " + e.getMessage(), e);
	                    }
    	            }
            	}
	            else {
    	            throw new ElabJspException("Error reading metadata file: " + f.getAbsolutePath() + ".meta");
	            }

				Iterator l = splits.iterator();
				List entries = new ArrayList();
				while (l.hasNext()) {
				    CatalogEntry s = elab.getDataCatalogProvider().getEntry((String) l.next());
				    entries.add(s);
				    for (int k = 0; k < 4; k++) {
				        channels[k] += ((Long) s.getTupleValue("chan" + (k + 1))).intValue();
				    }
				}
				request.setAttribute("channels", channels);
				request.setAttribute("splitEntries", entries);
				CatalogEntry e = elab.getDataCatalogProvider().getEntry(rawName);
				request.setAttribute("entry", e);
				request.setAttribute("id", id);
				request.setAttribute("lfnssz", new Integer(entries.size()));
				File geoFile = new File(new File(dataDir, id), id + ".geo");
				if (geoFile.exists() && geoFile.isFile() && geoFile.canRead()) {
				    request.setAttribute("geoFileExists", Boolean.TRUE);
				}
				else {
				    request.setAttribute("geoFileExists", Boolean.FALSE);
				}
				%>
                	<h2>Upload Successfull!</h2>
                	
                	<c:choose>
                		<c:when test="${geoFileExists}">
                			If you have <strong>changed</strong> the configuration of your detector 
                			since your last upload, please check to make sure that your <br/>
                			<a href="geo.jsp?fromupload=1&id=${id}&jd=${entry.tupleMap.julianstartdate}&latitude=${entry.tupleMap.avglatitude}&longitude=${entry.tupleMap.avglongitude}&altitude=${entry.tupleMap.avgaltitude}">
								Geometry Information</a> was updated correctly.<br/><br/>
                		</c:when>
                		<c:otherwise>
                			This looks like the first file you've uploaded for detector ${id} <br/>
                			Please check to make sure that your 
                			<a href="geo.jsp?fromupload=1&id=${id}&jd=${entry.tupleMap.julianstartdate}&latitude=${entry.tupleMap.avglatitude}&longitude=${entry.tupleMap.avglongitude}&altitude=${entry.tupleMap.avgaltitude}">
								Geometry Information</a> was updated correctly.<br/><br/>
                		</c:otherwise>
                	</c:choose>
                	<hr/>
                	<h2>File Summary:</h2>
                
                	Your data was split into ${lfnssz} ${lfnssz == 1 ? 'day' : 'days'} spanning from:<br/>
                	${entry.tupleMap.startdate} to ${entry.tupleMap.enddate}
                	
                	<table id="channels-table">
                		<tr>
                			<th></th>
                			<th>Chan 1</th>
                			<th>Chan 2</th>
                			<th>Chan 3</th>
                			<th>Chan 4</th>
                		</tr>
                		<tr>
                			<td>Total Events</td>
                			<td>${channels[0]}</td>
                			<td>${channels[1]}</td>
                			<td>${channels[2]}</td>
                			<td>${channels[3]}</td>
                		</tr>
					</table>

					<c:choose>
						<c:when test="${entry.tupleMap.avglatitude == '0'}">
							<%--if it were truly 0, it would be 0.0.0 in the metadata --%>
							No valid GPS information found in your data.<br/>
							Either the "DG" command was not run or the GPS did not see enough satellites.<br/><br/>
						</c:when>
						<c:otherwise>
							Average latitude: ${entry.tupleMap.avglatitude}<br/>
							Average longitude: ${entry.tupleMap.avglongitude}<br/>
							Average altitude: ${entry.tupleMap.avgaltitude}<br/>
						</c:otherwise>
					</c:choose>
				<%
           		// Run ThresholdTimes on each split file.
				// Not any more
			} //'twas a file
		} //while through the file
	} //end "if form has a file to upload"
	else {
		%>

<ul>
	<li>Select the <strong>detector</strong> associated with the data you are uploading.
	<li>Click <strong>Choose File/Browse</strong> to locate the data file on your computer.
	<li>Click <strong>Upload</strong> to upload the file.
</ul>

<form name="uploadform" id="upload-form" method="post" enctype="multipart/form-data" onSubmit="startProgress()">
    <!-- file, detector, and upload table -->	
	<p>
		Choose <label for="detector">detector:</label>
		<e:trselect id="uf1" name="detector" labelList="${detectorIDs}" valueList="${detectorIDs}"/>
    </p>
	<p>
		<label for="ds">Raw Data File:</label>
		<input id="uf2" name="ds" type="file" size="15"/>
	</p>
    <p>
		<label for="comments">Optional comments on raw data:</label>
	</p>
	<p>
        <textarea id="uf3" name="comments" rows="8" cols="50"></textarea>
    </p>
    <div id="button-line">
    	<!-- grr. somebody fix css -->
    	<table border="0">
    		<tr>
    			<td>
					<input name="load" type="submit" value="Upload" id="uploadbutton"/>
				</td>
				<td>
					<div id="progressBar" style="display: none;">
						<div id="theMeter">

							<div id="progressBarBox">
								<div id="progressBarBoxContent"></div>
								<div id="progressBarText"></div>
							</div>
						</div>
					</div>
				</td>
			</tr>
		</table>
	</div>
</form>

	<%
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
