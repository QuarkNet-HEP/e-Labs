<%@ page import="java.io.*" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %>
<%@ page import="org.apache.commons.codec.binary.Base64" %>

<%
	//get parameters
	String filename = request.getParameter("filename");
	String imagedata = request.getParameter("imagedata");
	String imagethumbnail = request.getParameter("imagethumbnail");
	byte[] imageDataBytes = Base64.decodeBase64(imagedata);
	byte[] thumbnailDataBytes = Base64.decodeBase64(imagethumbnail);
	
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
    
    String success = "";
    try {
		//write a image byte array into file system
		FileOutputStream imageOutFile = new FileOutputStream(plotDir+"/"+dstFile);
		imageOutFile.write(imageDataBytes);
		FileOutputStream thumbnailOutFile = new FileOutputStream(plotDir+"/"+dstThumb);
		thumbnailOutFile.write(thumbnailDataBytes);
		
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
		meta.add("thumbnail string " + dstThumb);
		meta.add("filename string " + dstFile);
		meta.add("type string plot"); 
		meta.add("creationdate date " + (new Timestamp(System.currentTimeMillis())).toString()); 
	
		dcp.insert(DataTools.buildCatalogEntry(dstFile, meta));
	
		imageOutFile.close();
		thumbnailOutFile.close();
    } catch (Exception e) {
    	success = e.toString();
    }
	request.setAttribute("filename", filename);
	request.setAttribute("success", success);
%>

	