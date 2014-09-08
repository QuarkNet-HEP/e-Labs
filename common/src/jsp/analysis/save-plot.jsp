<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>

<%
	//get parameters
	String filename = request.getParameter("filename");
	String imagedata = request.getParameter("imagedata");
	String[] metadata = request.getParameterValues("metadata[]");
	request.setAttribute("metadata", metadata);
	
	String id = request.getParameter("id");
	if (id == null) {
	    throw new ElabJspException("Missing run id parameter");
	}
	AnalysisRun run = AnalysisManager.getAnalysisRun(elab, user, id);
	String outputDir = run.getOutputDir();
	
	byte[] imageDataBytes = Base64.decodeBase64(imagedata);

	//save the chart
	ElabGroup group = user.getGroup();
	String groupName = user.getGroup().getName();
	String plotDir = user.getDir("plots");
	//check if the directory exist, create otherwise
	File file = new File(plotDir); 
	if (!file.exists()) {
		file.mkdirs(); 
	}
	
	GregorianCalendar gc = new GregorianCalendar();
	java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
	String date = sdf.format(gc.getTime());

	String dstFile = "savedimage-" + groupName + "-" + date + ".png";
    String dstThumb = "savedimage-" + groupName + "-" + date + "_thm.png";
    String provenanceFile = "savedimage-" + groupName + "-" + date + "_provenance.png";
    //String dotCmd = elab.getProperties().getProperty("dot.location", "/usr/bin/dot") + 
    //        " -Tsvg -o \"" + outputDir + "/dv.svg\" \"" + outputDir + "/dv.dot\"";
    //ElabUtil.runCommand(elab, dotCmd);
    //ElabUtil.SVG2PNG(outputDir + File.separator + "dv.svg", plotDir + File.separator + provenanceFile);
 
    String success = "";
    try {
		//write a image byte array into file system
		FileOutputStream imageOutFile = new FileOutputStream(plotDir+"/"+dstFile);
		imageOutFile.write(imageDataBytes);		            
		//use previously computed timestamp to create a Derivation name
		String newDVName = groupName + "-" + sdf.format(gc.getTime());
		
		//save Derivation used to create this plot
		ElabAnalysis analysis = run.getAnalysis();
		AnalysisCatalogProvider acp = elab.getAnalysisCatalogProvider();
		//DataCatalogProvider dcp = elab.getDataCatalogProvider();
		//TODO have a namespace
		acp.insertAnalysis(newDVName, analysis);
		
		DataCatalogProvider dcp = elab.getDataCatalogProvider();
		List<String> meta = new ArrayList();
	
		meta.add("city string " + group.getCity());
		meta.add("group string " + group.getName());
		meta.add("name string " + filename);
		meta.add("project string " + elab.getName());
		meta.add("school string " + group.getSchool());
		meta.add("state string " + group.getState());
		meta.add("teacher string " + group.getTeacher());
		meta.add("year string " + group.getYear());
		meta.add("thumbnail string " + dstFile);
		meta.add("filename string " + dstFile);
		meta.add("study string blesschart");
		meta.add("type string plot"); 
		meta.add("creationdate date " + (new Timestamp(System.currentTimeMillis())).toString()); 
		meta.add("provenance string " + provenanceFile);
		meta.add("dvname string " + newDVName);
		meta.addAll(Arrays.asList(metadata));
		
		dcp.insert(DataTools.buildCatalogEntry(dstFile, meta));
	
		imageOutFile.close();

    } catch (Exception e) {
    	success = e.toString();
    }
    
	String url = group.getDirURL("plots") + '/' + dstFile;    
	response.getWriter().print(url);
%>

	