<%@ page import="org.apache.regexp.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.util.regex.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="org.apache.commons.codec.net.URLCodec" %>

<script type="text/javascript" src="../include/tiny_mce/jquery.tinymce.js"></script>
<script type="text/javascript" src="formchanges.js"></script>
<script>
	$().ready(function() {
		$('textarea.tinymce').tinymce({
			entity_encoding: 'raw',
			script_url : '../include/tiny_mce/tiny_mce.js',
			theme : 'advanced',
			plugins : 'tabfocus, fmath_formula, table',
			relative_urls: false,
			remove_script_host: false,
			convert_urls: false,
			
			theme_advanced_buttons1 : ",italic,underline,|,bullist,numlist,|,sub,sup,|,cleanup,code,|,fmath_formula,|,table,tablecontrols",
			theme_advanced_buttons2 : "",
			theme_advanced_buttons3 : "", 
			theme_advanced_toolbar_location : "top",
			theme_advanced_toolbar_align : "left",
		    setup: function(ed) {
		        ed.onClick.add(function(ed, e) {
		    		if (ed.getContent() == "<p><span style=\"color: gray;\"><strong>Claim</strong><br />Say what you know:<br /><em>I claim that the data on this date...</em></span></p>"  ||
		    			ed.getContent() == "<p><span style=\"color: gray;\"><strong>Evidence</strong><br />What you see in your data plots that support your claim:<br /><em>My data show on this plot or observation that...</em></span></p>" ||
		        		ed.getContent() == "<p><span style=\"color: gray;\"><strong>Reasoning</strong><br />Why the evidence supports the claim:<br /><em>My data plot explains the evidence for these reasons...</em></span></p>" ) {
			        	ed.setContent("");
		        	}
		        });
		    },
		});
	});
</script>


<%
	//Policy policy = Policy.getInstance(Elab.class.getClassLoader().getResource("antisamy-i2u2.xml").openStream());
	//AntiSamy as = new AntiSamy(); 
	
	String title = "Make/Edit Poster";
	Date now = new Date();
	DateFormat df = new SimpleDateFormat("MM/dd/yyyy");
	String dateString = df.format(now);

	boolean posterNameEntered = false; //true if the field is filled in by the user.

	String dfile = ""; //data file (e.g., poster.data)
   
	String selectDefault = "Select graphic for figure.";
	HashMap<String, String> tags = new HashMap();
	String pdata = ""; // data written to the poster.data file.

	String posterName = request.getParameter("posterName");
	String action = request.getParameter("action");
	String[] posterTag = request.getParameterValues("posterTag");
	
	if (StringUtils.isNotBlank(posterName)) {
   	    posterNameEntered = true;
       	posterName = posterName.replace(' ', '_');
        posterName = posterName.replace('/', '_');
   	    if (action == null || action.equals("")) {
			//let's make a unique title! It turned out that this code generated lots of orphans ;)
			java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd");
    		String titleDate = sdf.format(now.getTime());
    		String suffix = "-" + elab.getName() + "-" + user.getGroup().getName() + 
    						"-" + user.getGroup().getTeacher() + "-" + user.getGroup().getSchool() +
    						"-" + user.getGroup().getCity() + "-" + user.getGroup().getState() +"-";
    		suffix = suffix.replace(' ', '_');
    		suffix = suffix.toLowerCase();
    		if (!posterName.contains(suffix)) {
				posterName = posterName + suffix + titleDate;
    		}
   	    }
   	    posterName = posterName.toLowerCase();   	    
       	dfile = posterName + ".data";
	} else {
		//EPeronja-06/28/2013 Find other posters by this user so we do not overwrite existing ones
		And q = new And();
		q.add(new Equals("type", "poster"));
		q.add(new Equals("project", elab.getName()));
		q.add(new Equals("group", user.getGroup().getName()));
	
		ResultSet rset = elab.getDataCatalogProvider().runQuery(q);
		request.setAttribute("existingposters", rset);	
	}
	
	request.setAttribute("edit", posterNameEntered);
	request.setAttribute("posterName", posterName);

	String posterTitle = request.getParameter("WORDS:TITLE");
	if ((posterTitle != null) && (posterTitle.length() == 0)) {
	    throw new ElabJspException("Missing poster title. Please go back and enter the title for the poster.");
	}

	String reqType = request.getParameter("button");
	String posterDir = user.getDir("posters");
	String posterDirURL = user.getDirURL("posters");
	String plotDir = user.getDir("plots");
	String plotDirURL = user.getDirURL("plots");
	request.setAttribute("plotDirURL", plotDirURL);
	String templateDir = user.getDir("templates");
	String showPosterVar = request.getParameter("showPoster");

	if ("Make Poster".equals(reqType) || "View Poster".equals(reqType) || "Save Changes".equals(reqType)) {
		String val = "", name = ""; 
	    RE re = new RE("(PARA|WORDS|FIG):([A-Z0-9]+)");
	    Map<String, String[]> fieldMap = request.getParameterMap();
	    for (Map.Entry<String, String[]> entry : fieldMap.entrySet()) {
	    	val = entry.getValue()[0].trim(); 
	    	name = entry.getKey();
	    	if (!val.equals(selectDefault) && re.match(name)) {  
	    		if (val.contains("/elab/capture/img/")) {
	    	    	val = ElabUtil.escapePoster(val); 
	    		} else {
			    	val = ElabUtil.stringSanitization(val, elab, "Posters");
	    		}
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
			
	        // Write the content to file
			File f = new File(posterDir, dfile);
			boolean fileExists = f.exists();  // we want to check before writing into rc.data so we don't fail.
			PrintWriter pw = new PrintWriter(new FileWriter(f));
			pw.println(pdata);
			pw.close();
			    
			//get metadata 
			String author = request.getParameter("WORDS:AUTHORS");
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
			meta.add("title string "+ request.getParameter("WORDS:TITLE") );
			meta.add("author string "+ author);
			meta.add("date date " + dateString);
			meta.add("name string " + dfile);
			meta.add("plotURL string " + plotDirURL);
			
			StringBuilder sb = new StringBuilder();
			if (posterTag != null) {
				for (int i = 0; i < posterTag.length; i++) {
					if (i == posterTag.length - 1) {
						sb.append(posterTag[i]);					
					} else {
						sb.append(posterTag[i] + ",");					
					}
				}
				meta.add("postertag string " + sb.toString());
			}			
			//EPeronja-06/11/2013: Add the plot names to metadata so 'delete plots' 
			//					   can check whether the plots are part of a poster or not.
			RE figures = new RE("(FIG:([A-Z0-9]))");
		    for (Map.Entry<String, String[]> entry : fieldMap.entrySet()) {
		    	String entryValue = entry.getValue()[0].trim(); 
		    	String entryName = entry.getKey();
		    	if (figures.match(entryName)) {  
		    		meta.add(entryName + " string " + entryName);
		    	}
		    }			
			
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
	if (posterNameEntered) { // if not entered, then we will use pdata that we built from input parameters.
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
	    int p = 0;
	    
	    // Parse the poster data file 
	    while (re.match(pdata, p)) {
	        String tagtype = re.getParen(1);
	        String tagname = re.getParen(2);
	        String tagval = re.getParen(3).trim();
	        tagval = ElabUtil.unescapePoster(tagval);
	        tagval = tagval.replace("\n", " ");
	        
	        p = re.getParenEnd(0);
	        //          if (tagtype.equals("FIG")) tagval = tagval.trim();
	        if (tagtype.equals("PARA") && tagname.equals("AUTHORS")) {
	        	// Legacy handling
	        	tagtype = "WORDS"; 
	        }
	        tags.put(tagtype+":"+tagname, tagval);
	    }
	    //retrieve the tags
	    
	    DataCatalogProvider dcp = elab.getDataCatalogProvider();
    	CatalogEntry e = dcp.getEntry(posterName + ".data");	 
    	if (e != null) {
    		String pt = (String) e.getTupleValue("postertag");
    		if (pt != null) {
	    		posterTag = pt.split(",");
    		}
    	}
	}

	// Find files posted to plot directory
	Map<String, String> images = new TreeMap();
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
		    String type = (String) e.getTupleValue("type");
		    if (elab.getName().equals("ligo")) {
		    	if (name == null || name.equals("")) {
				    String ligoName = (String) e.getTupleValue("title");
				    if (ligoName != null) {
				    	images.put(ligoName, lfn);
				    }
		    	} else {
			    images.put(name, lfn);
		    	}
		    } else {
			    if ("plot".equals(type) || "uploadedimage".equals(type)) {
			    	images.put(StringUtils.isNotBlank(name) ? name : lfn, lfn); 
			    }
		    }
		}
	}
	
	ResultSet rsTags = DataTools.retrieveTags(elab);
	String[] availablePosterTags = rsTags.getLfnArray();
	//build map with selected
	TreeMap<String, String> posterTags = new TreeMap<String, String>();
	
	for (int i = 0; i < availablePosterTags.length; i++) {
		boolean selectedTag = false;
		if (posterTag != null) { 
			for (int x = 0; x < posterTag.length; x++) {
				if (availablePosterTags[i].equals(posterTag[x])) {
					posterTags.put(availablePosterTags[i], "selected");
					selectedTag = true;
				} 
			}
		}
		if (!selectedTag) {
			posterTags.put(availablePosterTags[i], "");			
		}
	}
	request.setAttribute("rsTags", rsTags);
	request.setAttribute("availablePosterTags", availablePosterTags);
	request.setAttribute("posterTags", posterTags);
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
			<%@ include file="../posters/poster-example.jspf" %>
		 </li>
			 <li>Be sure to write a good <a href="javascript:glossary('abstract',300)">abstract</a>.
		</li>

		<li>
			To view the plots that you might want to include for the figures 
			in your poster, click <b>View Plots</b> in the navigation bar. 
			You can fill in fields for up to five figures. You don't have to 
			fill them all in.
		</li>
		<li>
			Composing your text in <strong>Microsoft Word</strong>?. Set the
			font to <strong>Arial 12</strong>.
		</li>
		<li>
			Click <b>${edit?'Save Changes':'Make Poster'}</b> to save the data for the poster and display your poster. If you have "pop-ups" blocked, you will need to click on </b>Display Poster</b> below.
		</li>
	</ul>


	<!-- Emit input form for replacement tags found in poster template -->
	<script language="JavaScript">
		function previewImage(name) {
			var div = document.getElementById("image-preview");
			div.innerHTML = "<img width=\"320\" src=\"${plotDirURL}/" + name + "\" alt=\"Image not found\"/>";
			div.style.display = "block";
			div.style.visibility = "visible";
		}

		function clearPreviewImage() {
			var div = document.getElementById("image-preview");
			div.innerHTML = "";
			div.style.display = "none";
			div.style.visibility = "";
		}
		//EPeronja-06/27/2013 -Bug 185:Weird characters in name of poster cause problems.
		//					   Also check if the name already exists so we do not overwrite
		function validatePosterName(objectId) {
			var posterName = document.getElementById(objectId);
			var divMsg = document.getElementById("errorMsg");
			var message = "";
			$("input[name=existingposters]").each(function() {
				var newName = posterName.value;
				var existingName = this.value;
				if (newName == existingName) {
					message = "<i>* The name you selected already exists. Choose a different name.</i>";
				}
			});
			if (message != "") {
				divMsg.innerHTML = message;
				return false;
			}
			if (! /^[a-zA-Z0-9_-]+$/.test(posterName.value)) {
				var message = "Poster File Name contains invalid characters. Use any alphanumeric combination, dashes or underscores.";
				divMsg.innerHTML = "<i>* "+message+"</i>";
				alert(message);
			    return false;
			}
			divMsg.innerHTML = "";
			return true;
		}	
	</script>

	<form id="posterForm" method="post">
           <table width="800">
                <tr>
                	<c:choose>
                		<c:when test="${edit == true}" >
                			<td></td>
                        	<td valign="top" align="left"><input type="text" name="posterName" id="posterName" value="${posterName}"  style="visibility: hidden;" /></td>
                		</c:when>
                		<c:otherwise>
		                	<td valign="top" align="right">Poster File Name:<br>(e.g.,poster_lifetime)</td>
		                	<td valign="top" align="left"><input type="text" name="posterName" id="posterName" onChange='return validatePosterName("posterName");' value="${posterName}" />
                								  <div id="errorMsg"></div></td>
                		</c:otherwise>
                	</c:choose>
                </tr>
                 
                <c:if test="${not empty posterTags}">
                 <tr>
                	<td valign="top" align="right"><strong>Poster Tag</strong></td>
                	<td><select name="posterTag" size=4 multiple>
                			<option></option>
               				<c:forEach items="${posterTags}" var="posterTags">
               					<c:choose>
                					<c:when test="${posterTags.value == 'selected'}">
	                					<option name="${posterTags.key}" value="${posterTags.key}" selected="selected">${posterTags.key}</option>
    	            				</c:when>
        	        				<c:otherwise>
            	    					<option name="${posterTags.key}" value="${posterTags.key}">${posterTags.key}</option>
                					</c:otherwise>
                				</c:choose>
                			</c:forEach>
                		</select>
                	</td>
 				  </tr>
 				</c:if> 
                <tr> 
     
<%
                RE re = new RE("%(PARA|FIG|WORDS):([A-Z0-9]+)%");
                int p = 0; // search pointer
                String ht = "";
                while (re.match(template, p)) {
                    String type = re.getParen(1);
                    String name = re.getParen(2);
                    String lowerPart = (name.substring(1, name.length())).toLowerCase();
                    String fixedName = name.substring(0, 1) + lowerPart;
                    String val = tags.get(type + ":" + name);
                    if (StringUtils.isBlank(val)) {
                        if (name.equals("DATE")) {
                            val = dateString;
                        }
                    else {
                            val = "";
                        }
                    }
                    pageContext.setAttribute("type", type);
                    pageContext.setAttribute("tvalue", val);
                    pageContext.setAttribute("name", name);
                    pageContext.setAttribute("plotsurl", user.getDirURL("plots"));
                    int previewIndex = 0;
                    String nameAnnotation="";
                     if (fixedName.equals("Abstract")) {nameAnnotation="<br>(Brief Overview of purpose, procedures, results & conclusions)";}
                     if (fixedName.equals("Procedure")) {nameAnnotation="<br>(Research or study plan)";}
                     if (fixedName.equals("Results")) {nameAnnotation="<br>(Support claims with data)";}
                     if (fixedName.equals("Conclusion")) {nameAnnotation="<br>(Interpret results, suggest further study)";}
                     if (fixedName.equals("Introduction")) {nameAnnotation="<br>(Background and researchable question)";}
					//EPeronja-06/04/2014: Placeholders for the tinymce textarea. If you make a change in any of the three following strings, please make the same changes in the 
					//					   javascript for the tinymce on top of this page, otherwise they will not clear when user clicks on the textarea.
                    String extraAnnotation="";
                    if (fixedName.equals("Introduction")) {extraAnnotation="<p><span style=\"color: gray;\"><strong>Claim</strong><br />Say what you know:<br /><em>I claim that the data on this date...</em></span></p>";}
 					if (fixedName.equals("Results")) {extraAnnotation="<p><span style=\"color: gray;\"><strong>Evidence</strong><br />What you see in your data plots that support your claim:<br /><em>My data show on this plot or observation that...</em></span></p>";}
                    if (fixedName.equals("Conclusion")) {extraAnnotation="<p><span style=\"color: gray;\"><strong>Reasoning</strong><br />Why the evidence supports the claim:<br /><em>My data plot explains the evidence for these reasons...</em></span></p>";}
                    pageContext.setAttribute("extraAnnotation", extraAnnotation);
 					
                     %>
                    	<tr>
                    		<td align="right" valign="top"><b><%= fixedName %></b>:<%= nameAnnotation %></td>
                    		<c:choose>
                    			<c:when test="${type == 'PARA'}">
                    				<td align="left">
                    					<c:choose>
                    						<c:when test='${tvalue > ""}'>
		                    					<textarea name="${type}:${name}" id="${type}:${name}" rows="6" cols="80" class="tinymce">${tvalue}</textarea>
		                    				</c:when>
		                    				<c:otherwise>
		                    					<textarea name="${type}:${name}" id="${type}:${name}" rows="6" cols="80" class="tinymce">${extraAnnotation}</textarea>		                    				
		                    				</c:otherwise>
		                    			</c:choose>
                    				</td>
                    			</c:when>
                    			<c:when test="${type == 'WORDS'}">
                    				<td align="left">
                    					<input size="50" name="${type}:${name}" id="${type}:${name}"
                    						value="${tvalue}"/>
                    				</td>
                    			</c:when>
                    			<c:when test="${type == 'FIG'}">
                    				<td align="left">
                    					<c:if test="${name == 'FIGURE1'}">
                    						<div id="image-preview" style="display: none; position: fixed; left: 1%; bottom: 4%;">image-preview</div>
                    					</c:if>
                    					<select name="${type}:${name}" id="${type}:${name}" >
                    						<option><%= selectDefault %></option>
                    						<c:forEach items="${images}" var="image">
                    							<c:choose>
                    								<c:when test="${tvalue == image.value}">
                    									<option selected="true" value="${image.value}"
                    										onmouseout="clearPreviewImage();" 
                    										onmouseover="previewImage('${image.value}');">${image.key}</option>
													</c:when>
													<c:otherwise>
														<option value="${image.value}"
															onmouseout="clearPreviewImage();" 
															onmouseover="previewImage('${image.value}');">${image.key}</option>
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
			    <input type="hidden" name="showPoster" id="showPoster" value="" />
			    <c:choose>
			    	<c:when test="${edit}">
			    		 <input type="hidden" name="action" id="action" value="edit" />
			    	</c:when>
			    </c:choose>
	            <input type="submit" name="button" id="submitButton" value="${edit?'Save Changes':'Make Poster'}" onclick='return validatePosterName("posterName");' />
    	        To see poster, don't block popups! Otherwise click <b>Display Poster</b> below.
			</td>
           	<td valign="left" align="right"></td>

		</tr>
		<c:choose>
			<c:when test="${not empty existingposters}">
				<c:forEach items="${existingposters}" var="existingposter" varStatus="counter">
					<tr>
						<td>
							<input type="hidden" name="existingposters" id="existingposters${counter.count}" value="${fn:substringBefore(existingposter.tupleMap.name, ".data")}" />
						</td>
					</tr>
				</c:forEach>
			</c:when>		
		</c:choose>
	</form>
</table>
</span></center>


<%
//this functionality is not working as of 8-19-04. Must go through search.jsp to view it...

if ("Make Poster".equals(reqType) || "Save Changes".equals(reqType)) {
    if (posterNameEntered) {
        // If "Make Poster" request, merge tag values into html template, by iterating over hash
        // of tag values and inserting them into the template string;
        // then write template into (user's) poster_mgb.html file XXXX
        
        for (Map.Entry<String, String> e : tags.entrySet()) {
        	template = template.replaceAll("%" + e.getKey() + "%", Matcher.quoteReplacement(e.getValue()));
        }

        // Write out the new poster

        try {
            String htmlName = posterName + ".html";
            File f = new File(posterDir, htmlName);
            PrintWriter pw = new PrintWriter(new FileWriter(f));
            pw.println(template);
            pw.close();
            // Add metadata to LFN for data file

            if (!showPosterVar.equals("NO"))
            {
            	String posterURL = "../posters/display.jsp?name=" + dfile;
				%> 
					<e:popup href="<%= posterURL %>" target="_blank" width="700" height="900" now="true" />
				<%
            }
        }
        catch (Exception e) { 
            out.println(e.getMessage()); 
        }
    }
}

%>
<% if (dfile != "") {
%>
<div align="center"><a href="../posters/display.jsp?name=<%= dfile %>" target="_blank" width="700" height="900" now="true">Display Poster</a></div>
<%
}
%>
<script>
//EPeronja-02/15/2013: Bug499- Implement autosave for posters
// 		   There is a timer firing a detect changes routine every minute
//		   If there has been a change in the form, then it will proceed to autosave
//		   These functions are in formchanges.js
var form = document.getElementById("posterForm");

function DynamicDiv() {
	var	dynDiv = document.createElement('div');
	dynDiv.setAttribute('id', 'dynDiv');
	dynDiv.style.position = "fixed";
	dynDiv.style.height = "40px";
	dynDiv.style.width = "150px";
	dynDiv.style.top = "105px";
	dynDiv.style.border = "1px solid #000";
	dynDiv.style.background = 'yellow';
	dynDiv.innerHTML = "Looking for changes to autosave...";
	document.body.appendChild(dynDiv);
}
function RemoveDiv() {
	var dynDiv = document.getElementById("dynDiv");
	if (dynDiv) {
		document.body.removeChild(dynDiv);
	}
}

function DetectChanges() {
	//console.debug("detecting changes and trying to autosave...")
	var f = FormChanges(form);
	//console.debug(f);
	if (f.length > 0) {
		var posterNameVar = document.getElementById("posterName").value;
		var posterTitleVar = document.getElementById("WORDS:TITLE").value ;
		if (posterNameVar != '' && posterNameVar != null) {
			if (posterTitleVar != '' && posterTitleVar != null) {
				var showPosterVar = document.getElementById('showPoster');
				showPosterVar.value = "NO";
				document.getElementById('submitButton').click();
			}
		}
	}
}

//a second: 1000
//25 minutes
var repeatTime =  25 * 60 * 1000; 
function UpdatePoster(){
	DynamicDiv();
	DetectChanges();
 	setTimeout(UpdatePoster, repeatTime); // start call over again
 	setTimeout(RemoveDiv, repeatTime + 10000);
}

setTimeout(UpdatePoster, repeatTime);
setTimeout(RemoveDiv, repeatTime + 10000);

</script>