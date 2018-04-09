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
<%@ page import="gov.fnal.elab.datacatalog.impl.vds.*" %>
<%@ page import="gov.fnal.elab.usermanagement.*" %>
<%@ page import="gov.fnal.elab.usermanagement.impl.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="org.apache.commons.fileupload.*" %>
<%@ page import="org.apache.commons.fileupload.disk.*" %>
<%@ page import="org.apache.commons.fileupload.util.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="org.apache.commons.io.*" %>
<%@ page import="be.telio.mediastore.ui.upload.*" %>
<%@ page import="gov.fnal.elab.upload.*" %>
<%@ page import="gov.fnal.elab.cosmic.beans.Geometries" %>
<%@ page import="gov.fnal.elab.cosmic.beans.GeoEntryBean" %>
<%@ page import="gov.fnal.elab.cosmic.Geometry" %>
<%@ page import="org.owasp.validator.html.*" %>
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
	ElabUserManagementProvider p = elab.getUserManagementProvider();
	CosmicElabUserManagementProvider cp = null;
	if (p instanceof CosmicElabUserManagementProvider) {
		cp = (CosmicElabUserManagementProvider) p;
	}
	else {
		throw new ElabJspException("The user management provider does not support management of DAQ IDs. " + 
			"Either this e-Lab does not use DAQs or it was improperly configured.");
	}    
	Collection ids = cp.getDetectorIds(user);
    if(ids == null || ids.size() == 0) {
        throw new ElabJspException("Your group does not have any detector IDs associated with it. "
                + "This is done when your group is first created.");
    }
    request.setAttribute("detectorIDs", ids);
 
	String lfn="";              //lfn on the USERS home computer
	String fn = "";             //filename without slashes
	String ds = "";
	String detectorId = "";             //detector id
	String comments = "";       //optional comments on raw data file
	String dataDir = elab.getProperties().getDataDir();
	request.setAttribute("datadir", dataDir);
	String benchmark = "";
	String usebenchmark = "";
	int channels[] = new int[4];
	
	File tempRepo = new File(dataDir + "/temp"); 
	int sizeThreshold = 0; 
	String exceptionMessage = "";
	List splits = new ArrayList();  //for both the split name and the channel validity information
	Policy policy = Policy.getInstance(Elab.class.getClassLoader().getResource("antisamy-i2u2.xml").openStream());
	AntiSamy as = new AntiSamy();

	if (ServletFileUpload.isMultipartContent(request)) {
		long lStartTime = new Date().getTime();
		try {
		    //BEGIN upload_progress_stuff
		    UploadListener listener = new UploadListener(request, 0);
	
	    	// Create a new file upload handler
		    ServletFileUpload upload = new ServletFileUpload();		
	    	FileItemIterator iter = upload.getItemIterator(request);
	    	
	    	FileItemStream item = null;
	    	String name = "";
	    	InputStream stream = null;
	    	while (iter.hasNext()) {
				item = iter.next();
	    		if (item.isFormField()) {
	    			name = item.getFieldName();
	    			stream = item.openStream();
	    			String content = Streams.asString(stream);
	    			if ("detector".equals(name)) {
	    				if (StringUtils.isBlank(content)) {
	    					throw new ElabJspException("You must enter a detector number for this data.");
	    				}
	    				else {
	    					detectorId = content;
	    				}
	    			}
	    			else if (("benchmark_"+detectorId).equals(name)) {
	    				benchmark = content;
	    			}
	    			else if ("comments".equals(name)) {
	    				if (StringUtils.isNotBlank(content)) {
	    					comments = content; 
	    				}
	    			}
	    		} else {
					lfn = item.getName();
					if (StringUtils.isBlank(lfn)) {
	                	throw new ElabJspException("Missing file.");
	    	        }
		            fn = FilenameUtils.getName(lfn);
	                Date now = new Date();
	                DateFormat df = new SimpleDateFormat("yyyy.MMdd");
	                String fnow = df.format(now);
					File f = File.createTempFile(detectorId + "." + fnow + ".", ".raw", 
					        new File(dataDir));
	                FileOutputStream fos = new FileOutputStream(f);
	    			stream = item.openStream();
	                long fileSize = Streams.copy(stream,fos,true);
	                if (fileSize == 0) {
					    throw new ElabJspException("Your file is zero-length. You must upload a file which has some data.");
	                }
	               	String rawName = f.getName();
	               		               	
		          	//EPeronja-04/28/2014: do some sanitization before sending the comments
		          	ArrayList checkDirtyInput = as.scan(comments,policy).getErrorMessages();
		          	if (!checkDirtyInput.isEmpty()) {
		    			String userInput = comments;
		    			int errors = as.scan(userInput, policy).getNumberOfErrors();
		    			ArrayList actualErrors = as.scan(userInput, policy).getErrorMessages();
		    			Iterator iterator = actualErrors.iterator();
		    			String errorMessages = "";
		    			while (iterator.hasNext()) {
		    				errorMessages = (String) iterator.next() + ",";
		    			}
		    			comments = as.scan(comments, policy).getCleanHTML();
				    	//send email with warning
				    	String to = elab.getProperty("notifyDirtyInput");
			    		String emailmessage = "", subject = "Cosmic Upload: user sent dirty input";
			    		String emailBody =  "User input: "+userInput+"\n" +
	    						   			"Number of errors: "+String.valueOf(errors)+"\n" +
	    				   					"Error messages: "+ errorMessages + "\n" +
	    				   					"Validated input: "+comments + "\n";
					    try {
					    	String result = elab.getUserManagementProvider().sendEmail(to, subject, emailBody);
					    } catch (Exception ex) {
			                System.err.println("Failed to send email");
			                ex.printStackTrace();
					    }		    		
				  	}//end of sanitization

	               	out.println("<!-- " + rawName + " added to Catalog -->");
	       	        request.setAttribute("in", f.getPath());
	       	        request.setAttribute("detectorid", detectorId);
	       	        request.setAttribute("comments", comments);
	      	        request.setAttribute("benchmark", benchmark);
	      			long lEndTime = new Date().getTime();
	      			String uploadtime = "upload-new.jsp: " +String.valueOf(lEndTime - lStartTime)+ " ms";
	      	        request.setAttribute("uploadtime", uploadtime);
	      	        %>
						<e:analysis name="processUpload" type="I2U2.Cosmic::ProcessUpload" impl="generic">
							<e:trdefault name="in" value="${in}"/>
							<e:trdefault name="datadir" value="${datadir}"/>
							<e:trdefault name="detectorid" value="${detectorid}"/>
							<e:trdefault name="comments" value="${comments}"/>
							<e:trdefault name="benchmark" value="${benchmark}"/>	
							<e:trdefault name="uploadtime" value="${uploadtime}"/>	
												
							<jsp:include page="../analysis/start.jsp?continuation=../data/upload-results.jsp&notifier=upload&detectorid=${detectorid}">
								<jsp:param name="provider" value="shell"/>
							</jsp:include>
						</e:analysis>
					<%
	
	    			
	    		}
	    	}
		} catch (Exception e) {
			exceptionMessage = "A problem occurred while uploading your file.<br />" + 
							   "Please send an e-mail to <a href=\'mailto:e-labs@fnal.gov\'>e-labs@fnal.gov</a> with the following error: <br />" +
								e.toString();
		}
	} //end "if form has a file to upload"
		else {
			
			//EPeronja-05/22/2013: get benchmark files
			Iterator iterator = ids.iterator();
			TreeMap<String, Integer> detectorBenchmark = new TreeMap<String, Integer>();
			TreeMap<String, VDSCatalogEntry> benchmarkTuples = new TreeMap<String, VDSCatalogEntry>();
			ResultSet searchResults = null;
			
			//loop through detectors
			while (iterator.hasNext()) {
				Integer key = Integer.parseInt((String) iterator.next());
			  	//retrieve benchmark files from database
					searchResults = Benchmark.getBenchmarkFileName(elab, key);
			  	if (searchResults != null) {
			 		String[] filenames = searchResults.getLfnArray();
			 		for (int i = 0; i < filenames.length; i++){
						VDSCatalogEntry e = (VDSCatalogEntry) elab.getDataCatalogProvider().getEntry(filenames[i]);
						if (e != null) {
							benchmarkTuples.put(filenames[i], e);
							detectorBenchmark.put(filenames[i], key);				
							}				
					}//end for loop
			  	}//end check searchResults
			}//end looping through detectors
		request.setAttribute("detectorBenchmark", detectorBenchmark);
		request.setAttribute("benchmarkTuples", benchmarkTuples);
		request.setAttribute("exceptionMessage", exceptionMessage);

		%>
		
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Upload Raw Data</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/upload.css"/>
		<link rel="stylesheet" type="text/css" href="../css/two-column.css"/>
		<link rel="stylesheet" type="text/css" href="../css/benchmark.css" />
 		<script type="text/javascript" src="../include/upload.js"></script>
 		<script type="text/javascript" src="../include/elab.js"></script>
		<!-- <script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>	-->
		<script type="text/javascript" src="../include/jquery/js/jquery-1.12.4.min.js"></script>
        <script type="text/javascript" src="../../dwr/interface/UploadMonitor.js"></script>
        <script type="text/javascript" src="../../dwr/engine.js"></script>
        <script type="text/javascript" src="../../dwr/util.js"></script>
        <script>
    	$(document).ready(function() {
				$('select').each(function(){
				    if (!$(this).find('option').length){ 
				        $(this).hide(); 
				    }
				});
				$('select option').each(function() {
					  $(this).prevAll('option[value="' + this.value + '"]').remove();
				});
		});
        </script>
	</head>
	
	<body id="search_default" class="data">
		<!-- entire page container -->
		<div id="container">
			<div id="top">
				<div id="header">
					<%@ include file="../include/header.jsp" %>
					<%@ include file="../include/nav-rollover.jspf" %>
				</div>
			</div>
			
			<div id="content">

<h1>Upload raw data collected by your cosmic ray detector.</h1>

<p>Blessing Tutorials: 
	<a href="../analysis-blessing/benchmark-overview-tutorial.jsp">Overview</a> |
	<a href="../analysis-blessing/benchmark-tutorial.jsp">Benchmark</a> |
	<a href="../analysis-blessing/benchmark-process-tutorial.jsp">Blessing</a><br /><br />
</p>

<ul>
	<li>Select the <strong>detector</strong> associated with the data you are uploading.</li>
	<li>Select <strong>benchmark</strong> file from dropdown. <a href="../analysis-blessing/benchmark.jsp">Add</a> file if no benchmark has been setup.</li>
	<li>Click <strong>Choose File/Browse</strong> to locate the data file on your computer.</li>
	<li>Click <strong>Upload</strong> to upload the file.</li>
</ul>

<form name="uploadform" id="upload-form" method="post" enctype="multipart/form-data" onSubmit="startProgress()">
    <!-- file, detector, and upload table -->	
    <div class="redborder">
<strong>Please <em>do not</em> upload files larger than 2 GB in size. You'll have to split them up into smaller pieces. Questions? See the <a href="../library/FAQ.jsp">FAQ</a> </strong>
</div>
	<p>
		<table style="text-align: left; margin-left: 5%;" width="90%">
		    <tr>
		    	<td class="benchmarkHeader">Detector</td>
		    	<td class="benchmarkHeader">Benchmark File <a href="javascript:showRefLink('../library/ref-benchmark-upload.jsp',520,400)"><img src="../graphics/question.gif"></a></td>
		    </tr>
			<c:forEach items="${detectorIDs}" var="d">
			  	<tr>
			  		<td class="benchmarkSelection"><input type="radio" name="detector" value="${d}"/>${d}</td>
			  		<td>
						<table style="text-align: left;">
						  <tr><td>
			    			<select name="benchmark_${d}">
								<c:forEach var="detectorBenchmark" items="${detectorBenchmark}" >
									<c:choose>
										<c:when test="${detectorBenchmark.value == d}">
			    							<option>No benchmark</option>
						    				<c:forEach items="${benchmarkTuples}" var="benchmarkTuples">
						    					<c:choose>
						    					   <c:when test="${benchmarkTuples.key == detectorBenchmark.key }">
								    					<c:choose>
								    						<c:when test="${ benchmarkTuples.value.tupleMap.benchmarkdefault == true }">
								    							<option value="${benchmarkTuples.key}" selected="selected">${benchmarkTuples.value.tupleMap.benchmarklabel}</option>
								    						</c:when>
								    						<c:otherwise>
								    							<option value="${benchmarkTuples.key}">${benchmarkTuples.value.tupleMap.benchmarklabel}</option>
								    						</c:otherwise>
								    					</c:choose>
								    				</c:when>
								    				</c:choose>
						    				</c:forEach>
										</c:when>
									</c:choose>						
								</c:forEach>
			    			</select>
						  </td></tr>							
						</table>
			  		</td>
			  	</tr>
			</c:forEach>
		</table>
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
    	<table border="0" style="width: 450px; text-align: center;">
    		<tr>
    			<td>
					<input name="load" type="submit" value="Upload" id="uploadbutton"/>
				</td>
				<td>
					<div id="progressBar" style="display: none">
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
		<div id="uploadwarning" class="redborder">
			<strong><em>Don't navigate away from this page</em></strong> until we've started analyzing your file!
		</div>
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
