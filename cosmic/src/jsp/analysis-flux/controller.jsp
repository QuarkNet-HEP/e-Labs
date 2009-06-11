<%@ taglib prefix="elab" uri="http://www.i2u2.org/jsp/elabtl" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.StructuredResultSet.*" %>
<%@ page import="java.io.IOException" %>
<%@ page import="gov.fnal.elab.util.ElabUtil" %>
<%@ page import="gov.fnal.elab.util.ElabException" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.datacatalog.query.*" %>
<%@ page import="org.apache.commons.lang.StringUtils" %>
<%@ page import="org.apache.commons.lang.time.DateUtils" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>

<%
	

	/* This handles the POST-Redirect-GET design pattern */ 
	
	/* Globals */ 
	SimpleDateFormat DATEFORMAT = new SimpleDateFormat("MM/dd/yyyy");
	DATEFORMAT.setLenient(false);
	
	String action = request.getParameter("action");
	
	/* Handle checkbox submissions */
	int start, pageNo; 
	try {
		start = Integer.parseInt(request.getParameter("start"));
		pageNo = start/10; 
	}
	catch(Exception ex) {
		start = 0;
		pageNo = 0;
	}

	/* Stuff our checked data into the page object, if it already exists? Overwrite */
	String[] rawData = request.getParameterValues("rawData");
	HashMap<Integer, String[]> h = null;
	try {
		h = (HashMap) session.getAttribute("rawDataMap");
	}
	catch (ClassCastException ex) {
		h = null;
	}
	finally {
		if (h == null) {
			h = new HashMap(10, 0.75f);
		}
	}
	if (rawData != null) {
		h.put(pageNo, rawData); // Insert new data if anything is checked
	}
	else {
		h.remove(pageNo); // No checkboxes? Remove this page's information
	}
	session.setAttribute("rawDataMap", h);
	
	/* Initial search submission */ 
	if ("Search Data".equalsIgnoreCase(action)) {
		String key = request.getParameter("key");
		String value = request.getParameter("value");
		String date1 = request.getParameter("date1");
		String date2 = request.getParameter("date2");
		String stacked = request.getParameter("stacked");
		String blessed = request.getParameter("blessed");
		
		// New search, so purge old data
		session.setAttribute("rawDataMap", null);
		
		ResultSet searchResults = null;
		StructuredResultSet searchResultsStructured = null;
	    And and = new And();
		
		// Allow use of asterisk wildcards, remove leading/trailing whitespace 
		if (StringUtils.isNotBlank(value) && !key.equals("all")) {
			value = value.replace('*', '%').trim();
			and.add(new Like(key, value)); 
		}

		// Date bounds are only needed if specified   
	    String datetype = request.getParameter("datetype");
		if (StringUtils.isNotBlank(date1) || StringUtils.isNotBlank(date2)) {
			// In case someone makes their own search string and forgets the date type 
			if (StringUtils.isBlank(datetype)) datetype = "startdate"; 
			
			try {
				Date startDate = null, endDate = null; 
				
				if (StringUtils.isNotBlank(date1)) {
					startDate = DATEFORMAT.parse(date1); 
				}
				if (StringUtils.isNotBlank(date2)) {
					endDate = DATEFORMAT.parse(date2);
					endDate.setHours(23); 
					endDate.setMinutes(59);
					endDate.setSeconds(59);
				}
			
				// Start date undefined, therefore less or equal to the end date just before midnight
				if (StringUtils.isBlank(date1)) {
					and.add(new LessOrEqual(datetype, endDate));
				}
				
				// End date undefined, therefore greater than or equal to the start date
				else if (StringUtils.isBlank(date2)) {
					and.add(new GreaterOrEqual(datetype, startDate));
				}
				// Date range 
				else {
					and.add(new Between(datetype, startDate, endDate));
				}
			}
			catch (Exception ex) {
				%> 
				<h3>At least one of the dates you typed in was not understood. Please re-check the dates you typed in.</h3>
				<%
				return; 
			}
		}
				    
	    if ("yes".equals(blessed)) {
	    	and.add(new Equals("blessed", Boolean.TRUE));
	    }
	    if ("no".equals(blessed)) {
	    	and.add(new Equals("blessed", Boolean.FALSE));
	    }
	    
	    if ("yes".equals(stacked)) {
	    	and.add(new Equals("stacked", Boolean.TRUE));
	    }
	    if ("no".equals(stacked)) {
	    	and.add(new Equals("stacked", Boolean.FALSE));
	    }
	    
	    and.add(new Equals("type", "split"));
	    and.add(new Equals("project", elab.getName()));
	    
	    long startTime = System.currentTimeMillis();
		searchResults = elab.getDataCatalogProvider().runQuery(and);
		long endDataSearch = System.currentTimeMillis();
		long startOrganizing = endDataSearch; 
		
		searchResultsStructured = DataTools.organizeSearchResults(searchResults);
		searchResultsStructured.setKey(key);
		searchResultsStructured.setValue(value);
		
		long endTime = System.currentTimeMillis();
		String totalTime = ElabUtil.formatTime(endTime - startTime);
		String dataTime  = ElabUtil.formatTime(endDataSearch - startTime);
		String orgTime   = ElabUtil.formatTime(endTime - startOrganizing);
		
		searchResultsStructured.setTime(totalTime);
		
		// Stuff our results in our session.
		session.setAttribute("srs", searchResultsStructured);
		
		// Send it back home to display 
		response.setStatus(java.net.HttpURLConnection.HTTP_SEE_OTHER);
		response.setHeader("Location", "results.jsp");
	}
	
	/* Modification of data selection when pagination or back/forward is handled */ 
	else if ("Next Results".equalsIgnoreCase(action) || "Previous Results".equalsIgnoreCase(action)) {
		// Get next/previous page 
		if ("Next Results".equalsIgnoreCase(action)) {
			start += 10;
		}
		else {
			start -= 10;
		}

		// Redirect to show the values 
		response.setStatus(java.net.HttpURLConnection.HTTP_SEE_OTHER);
		response.setHeader("Location", "results.jsp?start=" + Integer.toString(start));
	}
	
	/* Shoot things off for analysis */
	else if ("Run flux study".equalsIgnoreCase(action)) {
		// Get the data in the way the analysis page wants it 
		String s = "";
		if (h != null) {
			for (String ids[] : h.values()) {
				for (String id : ids) {
					s += "rawData=" + id + "&";
				}
			}
		}
		response.setStatus(java.net.HttpURLConnection.HTTP_SEE_OTHER);
		response.setHeader("Location", "analysis.jsp?" + s);
	}
	
	/* Bounce back to the index page */ 
	else {
		response.setStatus(java.net.HttpURLConnection.HTTP_SEE_OTHER);
		response.setHeader("Location", "index.jsp");
	}
						
%>
