<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.text.*" %>
<%@ page import="gov.fnal.elab.expression.data.engine.*" %>
<%@ page import="gov.fnal.elab.cosmic.bless.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="org.apache.commons.lang.*" %>
<%@ page import="com.google.gson.*" %>
<%@ page import="java.net.HttpURLConnection" %>

<%@ include file="../include/elab.jsp" %>

<%
		String file = request.getParameter("file");
		String cleanString = file.replace("[", "");
		cleanString = cleanString.replace("]", "");
		String[] indFiles = cleanString.split(",");
	
		if (indFiles != null) {
			// debug - set to JSON for real stuff
			response.setContentType("application/json");
			int validEntries = 0;
			for (int i = 0; i < indFiles.length; i++) {
				if (!indFiles[i].equals("[]") && !indFiles[i].equals("")) {
					validEntries += 1;
				}
			}

			File[] pfns = new File[validEntries];
			String[] filenames = new String[validEntries];
			for (int i = 0; i < indFiles.length; i++) {
				// add in proper path handling!
				if (!indFiles[i].equals("[]") && !indFiles[i].equals("")) {
					String cleanname = indFiles[i].replace(" ","");
					String pfn = RawDataFileResolver.getDefault().resolve(elab, cleanname) + ".bless";
					pfns[i] = new File(pfn);
					filenames[i] = cleanname;
				}
			}
				
			BlessData bd;
			
			if (pfns.length > 0) {
				bd = new BlessData(elab, pfns, filenames);	
				GsonBuilder gb = new GsonBuilder();
				gb.registerTypeAdapter(BlessData.class, new BlessDataLongJsonSerializer());
				Gson gson = gb.create(); 
				out.write(gson.toJson(bd)); 
			}
		}
%>
