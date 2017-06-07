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
		out.print('\n');
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
         		
	        	for( int i = 1; i<4; i++){
				//Write heading after writing 2 lines that begin with '#'.  
				if (i == 3){
					bw.write("DAQ1.ch1   "+"DAQ1.ch2   "+"DAQ1.ch3   "+"DAQ1.ch4"+"DAQ2.ch1   "+"DAQ2.ch2"+"DAQ2.ch3   "+"DAQ2.ch4");         
				}//if

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
					
					//Create List of DAQs.
					List<String> listDAQ = new ArrayList<String>();
					for ( int k=0; k < arrayDJF.length; k++){
						if (k%3 == 0){
							String numChanDAQ = arrayDJF[k];
							String DAQ = (numChanDAQ.split("\\."))[0];
							listDAQ.add(DAQ);
						}//if
					}//for
					
					//Get set of unique DAQs, convert to array, and sort. DAQ1: smaller DAQ#; DAQ2: bigger DAQ#.
					Set<String> setDAQ = new HashSet<String>(listDAQ);
					String[] arrayDAQ = setDAQ.toArray(new String[setDAQ.size()]);
					Arrays.sort(arrayDAQ); 					
					String DAQ1 = arrayDAQ[0];
					String DAQ2 = arrayDAQ[arrayDAQ.length - 1];				
					out.println("DAQ1:  " + DAQ1 + "    DAQ2:  " + DAQ2);		
					
					//output array
					String [] outArray = new String[8];
					for (int k=0; k<outArray.length; k++){outArray[k] = "-1";}
					
					for (int p=3; p<arrayDJF.length; p++){	
						if (p%3 == 0){
							if(DAQ1+".1" == arrayDJF[p]){outArray[0]=arrayDJF[p+2];}
  							else if (DAQ1+".2" == arrayDJF[p]){outArray[1]=arrayDJF[p+2];}
        					else if (DAQ1+".3" == arrayDJF[p]){outArray[2]=arrayDJF[p+2];}
							else if (DAQ1+".4" == arrayDJF[p]){outArray[3]=arrayDJF[p+2];}
							else if (DAQ2+".1" == arrayDJF[p]){outArray[4]=arrayDJF[p+2];}
							else if (DAQ2+".2" == arrayDJF[p]){outArray[5]=arrayDJF[p+2];}
							else if (DAQ2+".3" == arrayDJF[p]){outArray[6]=arrayDJF[p+2];}
							else if (DAQ2+".4" == arrayDJF[p]){outArray[7]=arrayDJF[p+2];}
						}//if
					}//for
					
					//write to output file.
						StringBuffer result = new StringBuffer();
						result.append("\n");
						for (int n = 0; n < outArray.length; n++) {
   							result.append( outArray[n] ); result.append("       ");
						}//for
						String outline = result.toString(); 
				        bw.write(outline);
				}//if
				else {
					bw.write(line);
				}//else
				
				bw.newLine();
				line = br.readLine();        		
			}//for

         		File file22 = new File(dst2);	
				if (file22.exists() && file22.length() != 0){
	        		out.println("eclipseFormat file exists and is not empty!");
                }//if

	        	br.close();
        		bw.close();
    			
    		}//try
    		catch(Exception e){
        		out.println("Exception caught : " + e);
    		}//catch
	
	%>
	</body>
</html>

