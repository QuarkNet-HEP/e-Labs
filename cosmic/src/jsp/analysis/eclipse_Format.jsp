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
<%--<%@ page import="static java.lang.System.*"%>--%>

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
		
		//out.println("Source: "+src);
		//out.println("Destination: "+dst);	
		
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
		
		/*if (file2.exists()){
                        out.println("Copy of eventCandidates to eFtemp successful!");
                }*/

		//Phase II:  Read one line at a time from eFtemp; parse, perform calculations, and write it to eclipseFormat
		//Code assumes the first 2 lines of input file start with '#'.
		BufferedReader br = null;
    		BufferedWriter bw = null;
		String src2 = dst;				//eFtemp-date is source in this phase
		String dst2 = dD+"/"+"eclipseFormat"+"-"+date;	//eclipseFormat-date is destination in this phase
     
    		try{
        		br = new BufferedReader(new FileReader(src2));
        		bw = new BufferedWriter(new FileWriter(dst2));
 		       	String line = br.readLine();
         		int i = 0;
         		while (line != null){ 
				i++;
				String[] words = line.split("\\s+");
				
				if(words[0].charAt(0) != '#'){
					int eventNum = Integer.parseInt(words[0]);
					int numEvents = Integer.parseInt(words[1]);
					
					//listDJF will contain a list of all (DAQ.ch, JulianDay, FractionDay) combos in a line for UNIQUE DAQ.ch.
					List<String> listDJF = new ArrayList<String>();
					for ( int j=0; j<words.length; j++){
						if (j != 0 && j%3 == 0){
							if (!listDJF.contains(words[j])){
								listDJF.add(words[j]); //DAQ.ch
								listDJF.add(words[j+1]); //JulianDay
								listDJF.add(words[j+2]); //FractionDay
							}//if
	                     }//if
					}//for
					
					String[] arrayDJF = new String[listDJF.size()]; //DJF represents DAQ, Julian, Fraction
					arrayDJF = listDJF.toArray(arrayDJF); //arrayDJF can have different length for each line.
					//out.println("arrayDJF:  " + Arrays.toString(arrayDJF));					
					//out.println("Length of arrayDJF:  " + String.valueOf(arrayDJF.length));
					
					//Create List of DAQs.
					List<String> listDAQ = new ArrayList<String>();
					for ( int k=0; k < arrayDJF.length; k++){
						if (k%3 == 0){
							String DAQnumChan = arrayDJF[k];
							String DAQ = (DAQnumChan.split("\\."))[0];
							listDAQ.add(DAQ);
						}//if
					}//for
					
					//Get set of unique DAQs, convert to array, and sort. DAQ1: smaller DAQ#; DAQ2: bigger DAQ#.
					//Note:  This code was written assuming 2 unique DAQs would exist.
					Set<String> setDAQ = new HashSet<String>(listDAQ);
					String[] arrayDAQ = setDAQ.toArray(new String[setDAQ.size()]);
					Arrays.sort(arrayDAQ); 					
					String DAQ1 = arrayDAQ[0];
					String DAQ2 = arrayDAQ[arrayDAQ.length - 1];				
					//out.println("DAQ1:  " + DAQ1 + "    DAQ2:  " + DAQ2);		
					
					//Calculate number of hits for each DAQ.
					int numHits1 = 0;
					int numHits2 = 0;	
					for (int k=0; k<listDAQ.size(); k++){
						if (DAQ1.equals(listDAQ.get(k))){numHits1++;}
						else if (DAQ2.equals(listDAQ.get(k))){numHits2++;}	
					}			
					
					//output array
					String [] outArray = new String[8];
					for (int m=0; m<8; m++){outArray[m] = "-1";}
					
					boolean JD = true;//assume true all Julian Day values are same for whole line
					float minFracDay = Float.parseFloat(arrayDJF[2]); //assume 1st fraction day is min
					
					for (int p=0; p<arrayDJF.length; p++){	
						if (p%3 == 0){
							if((DAQ1+".1").equals(arrayDJF[p])){outArray[0]=arrayDJF[p+2];}
  							else if ((DAQ1+".2").equals(arrayDJF[p])){outArray[1]=arrayDJF[p+2];}
        					else if ((DAQ1+".3").equals(arrayDJF[p])){outArray[2]=arrayDJF[p+2];}
							else if ((DAQ1+".4").equals(arrayDJF[p])){outArray[3]=arrayDJF[p+2];}
							else if ((DAQ2+".1").equals(arrayDJF[p])){outArray[4]=arrayDJF[p+2];}
							else if ((DAQ2+".2").equals(arrayDJF[p])){outArray[5]=arrayDJF[p+2];}
							else if ((DAQ2+".3").equals(arrayDJF[p])){outArray[6]=arrayDJF[p+2];}
							else if ((DAQ2+".4").equals(arrayDJF[p])){outArray[7]=arrayDJF[p+2];}
						}//if		
						
						//check if all the Julian Day values are the same for the whole line.								
						if (p%3 == 1){
							if(!arrayDJF[1].equals(arrayDJF[p])){
								JD = false;
							}//if
						}//if
						
						//find smallest fraction of day in arrayDJF 
						if (p%3 == 2){
							if(Float.parseFloat(arrayDJF[p]) < minFracDay){
								minFracDay = Float.parseFloat(arrayDJF[p]);
							}//if
						}//if
					}//for

					
					//Write to output file.
						StringBuffer result = new StringBuffer();						
						
						//Event number
						result.append(Integer.toString(eventNum)+"    ");
						
						//num of hits for each DAQ
							result.append(Integer.toString(numHits1)+"   "+Integer.toString(numHits2)+"   " );
						
						//JulianDay
						if (JD){result.append(arrayDJF[1]+"    ");}//if
							else{result.append("          ");}//else	
						
						//SecSinDayBeg
						//convert minFracDay to sec
						double SecSinDayBeg = 3600*24*minFracDay;
						result.append(Double.toString(SecSinDayBeg)+"    ");
						
						//Data													 
						for (int n = 0; n < outArray.length; n++) {
   							result.append( outArray[n] ); result.append(" ");
						}//for
						result.append("\n");
						
						String outline = result.toString();
						
						//Write heading after writing 2 lines that begin with '#'.  
						if (i == 3){
							bw.write("Event #Hits1 #Hits2 JulDay  SecSinceDayBegin    "
							+DAQ1+".1             "+DAQ1+".2             "
							+DAQ1+".3             "+DAQ1+".4             "
							+DAQ2+".1             "+DAQ2+".2             "
							+DAQ2+".3             "+DAQ2+".4             ");  
							bw.newLine();
						}//if
						
				        bw.write(outline); 
				        out.println(outline); out.println("<br>");
				}//if
				//The first 2 lines from eventCandidates file fall into 'else' - they start with '#'.
				else {
					bw.write(line);bw.newLine();
					out.println(line); out.println("<br>");
				}//else
				
				line = br.readLine();        		
			}//while
				
         		/*File file22 = new File(dst2);	
				if (file22.exists() && file22.length() != 0){
	        		out.println("eclipseFormat file exists and is not empty!");
                }//if
  				*/	
				
	        	br.close();
        		bw.close();
        		
        	//Phase III:  Provide link to download file eclipseFormat
				//parse dst2 to remove /var/lib/tomcat7/ and create dst2v2
    			String phrase = dst2;
				String[] tokensArray = phrase.split("/");
				for (int q=0; q<tokensArray.length; q++){
					out.println("q:  "+tokensArray[q]+" "); 	
				}
				String[] tokensArray2 = new String[tokensArray.length-4];
				for (int q=0; q < tokensArray2.length; q++){
					tokensArray2[q] = tokensArray[q+4];//tokensArray[0] is a space
				}
				String dst2v2 = "";	
				for (int q = 0; q<tokensArray2.length-1; q++){	
    				dst2v2 = dst2v2 + tokensArray2[q] + "/";
    			}//for
    			dst2v2 = dst2v2 + tokensArray2[tokensArray2.length-1];
    			out.println("dst2v2:  " + dst2v2);
				request.setAttribute("dst2v2", dst2v2);	
						
    		}//try
    		catch(Exception e){
        		out.println("Exception caught : " + e);
    		}//catch
    		
	%>
	<a href="${dst2v2}">Download eclipseFormat file</a>
	</body>
</html>

