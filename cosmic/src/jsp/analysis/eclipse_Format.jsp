<%-- Author:  Sudha Balakrishnan, 5/8/17 --%>
<%-- This program gets called by show-dir.jsp --%>

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
		//Phase I:  copy eventCandidates file into eFtemp-date
		//Create variables src and dst
		String sF = request.getParameter("srcF");
		String sD = request.getParameter("srcD");
			GregorianCalendar gc = new GregorianCalendar();
			java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
			String date = sdf.format(gc.getTime());
		String dF = "eFtemp-"+date;
 
		//SB,5/8/17:  This is like how it's done in save.jsp:  String plotDir = user.getDir("plots");
		//"user" is set in cosmic/src/jsp/include/elab.jsp from the session data, and getDir() is a method belonging to user.
		
		String dD = user.getDir("plots");
		String src = "webapps"+sD+"/"+sF;
		String dst = dD+"/"+dF;
		
		out.println("Source: "+src);
		out.println("Destination: "+dst);	
		
		//copy eventCandidates file to eFtemp in user's "plots" directory
		File file1 = new File(src);
        	File file2 = new File(dst);
		
		if (file1.exists()){
			Path source = Paths.get(src);
			Path destination = Paths.get(dst);
			try {
	                        Files.copy(source, destination);
        	        } catch (IOException e) {
                        e.printStackTrace();
                	}
		}		
		
		if (file2.exists()){
                        out.println("Copy of eventCandidates to eFtemp successful!");
                }

		//Phase II:  Read one line at a time from eFtemp; parse, perform calculations, and copy it to eclipseFormat
		BufferedReader br = null;
    		BufferedWriter bw = null;
		String src2 = dst;				//eFtemp-date is source in this phase
		String dst2 = dD+"/"+"eclipseFormat"+"-"+date;	//eclipseFormat-date is destination in this phase
     
    		try{
        		br = new BufferedReader(new FileReader(src2));
        		bw = new BufferedWriter(new FileWriter(dst2));
         
 		       	String line = br.readLine();
         		
			//for( int i = 1; line != null; i++){
	        	for( int i = 1; i<4; i++){
				String[] words = line.split("\\s+");
				
				if(words[0].charAt(0) != '#'){
					int eventNum = Integer.parseInt(words[0]);
					int numEvents = Integer.parseInt(words[1]);
					//listDJF will contain a list of all (DAQ.ch, JulianDay, FractionDay) combos in a line for unique DAQ.ch.
					List<String> listDJF = new ArrayList<String>();
					for ( int j=0; j<words.length; j++){
						if (j != 0 && j%3 == 0){
							if (!listDJF.contains(words[j])){
								listDJF.add(words[j]);
								listDJF.add(words[j+1]);
								listDJF.add(words[j+2]);
							}//if
	                                        }//if
					}//for
					
					String[] arrayDJF = new String[listDJF.size()];
					arrayDJF = listDJF.toArray(arrayDJF);
					out.println("arrayDJF:  " + Arrays.toString(arrayDJF));					
					out.println("Length of arrayDJF:  " + String.valueOf(arrayDJF.length));
					
					//Create List of DAQs and sort it.
					List<String> listDAQ = new ArrayList<String>();
					for ( int k=0; k < arrayDJF.length; k++){
						if (k%3 == 0){
							String numChanDAQ = arrayDJF[k];
							String DAQ = (numChanDAQ.split("\\."))[0];
							listDAQ.add(DAQ);
						}//if
					}//for
					Collections.sort(listDAQ);
					out.println("List of DAQs:  " + listDAQ);
					
					//Get set of unique DAQs and convert to an array.
					Set<String> setDAQ = new HashSet<String>(listDAQ);
					out.println("Set of DAQs:  " + setDAQ);
					String[] arrayDAQ = setDAQ.toArray(new String[setDAQ.size()]);
					
					//DAQ1 will have smaller DAQ# and DAQ2 will have bigger DAQ#.
					String DAQ1 = arrayDAQ[0];
					String DAQ2 = arrayDAQ[arrayDAQ.length - 1];				
					out.println("DAQ1:  " + DAQ1 + " DAQ2:  " + DAQ2);
					
					String outline = "Hello world!";
				        bw.write(outline);
				}//if
				else {
					bw.write(line);
				}//else
				
				bw.newLine();
				line = br.readLine();        		
			}

         		File file22 = new File(dst2);	
			if (file22.exists() && file22.length() != 0){
	        		out.println("eclipseFormat file exists and is not empty!");
                        }

	        	br.close();
        		bw.close();
    		}
    		catch(Exception e){
        		out.println("Exception caught : " + e);
    		}
	
	%>
	</body>
</html>

