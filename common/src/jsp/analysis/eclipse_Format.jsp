<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %><%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>
<%@ page import="java.nio.file.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
	<head>
		<title>Creating eclipseFormat . . . </title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
	<%	
		//Create variables src and dst
		String sF = request.getParameter("srcF");
		String sD = request.getParameter("srcD");
			GregorianCalendar gc = new GregorianCalendar();
			java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
			String date = sdf.format(gc.getTime());
		String dF = "eFtemp-"+date;
		String dD = user.getDir("plots");/*This is like how it's done in save.jsp:  String plotDir = user.getDir("plots");*/
		String src = "webapps"+sD+"/"+sF;
		String dst = dD+"/"+dF;
		
		out.println("Source: "+src);
		out.println("Destination: "+dst);	
		
		//copy eventCandidates file to eFtemp in user's "plots" directory
		File file1 = new File(src);
        	File file2 = new File(dst);
		
		if (file1.exists()){
			out.println("Source exists!");
			out.println("\n");
			Path source = Paths.get(src);
			Path destination = Paths.get(dst);
			try {
	                        Files.copy(source, destination);
        	        } catch (IOException e) {
                        e.printStackTrace();
                	}
		}		
		
		if (file2.exists()){
                        out.println("Copy successful!");
                }

		//Read one line at a time from eFtemp and copy it to eclipseFormat
		BufferedReader br = null;
    		BufferedWriter bw = null;
		String src2 = dst;				//eFtemp is new source
		String dst2 = dD+"/"+"eclipseFormat"+"-"+date;	//eclipseFormat is new destination
     
    		try{
        		br = new BufferedReader(new FileReader(src2));
        		bw = new BufferedWriter(new FileWriter(dst2));
         
 		       	String line = br.readLine();
         
	        	for( int i = 1; i <= 10 && line != null; i++){
			String delims = "[ ]+";
			String[] tokens = line.split(delims);
				if( (tokens[0](0)) != "#"){
				for (int j=0; j<tokens.length; j++){
					bw.write(tokens[j]);
        	    			bw.write("\n");
				}
				}
				line = br.readLine();        		
			}
         
        		out.println("Lines are Successfully copied!");
         
	        	br.close();
        		bw.close();
    		}
    		catch(Exception e){
        		System.out.println("Exception caught : " + e);
    		}
	
	%>
	</body>
</html>

