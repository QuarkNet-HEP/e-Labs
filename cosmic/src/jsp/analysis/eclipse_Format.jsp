<%-- Author:  Sudha Balakrishnan, 5/8/17 --%>
<%-- This program gets called by show-dir.jsp --%>

<%@ page import="java.text.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.util.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.datacatalog.*" %>
<%@ page import="gov.fnal.elab.cosmic.util.*" %>
<%@ page import="org.apache.commons.lang.time.DateFormatUtils" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/login-required.jsp" %><%@ page errorPage="../include/smallerrorpage.jsp" buffer="none" %>
<%@ page import="java.nio.file.*" %>
<%@ page import="java.lang.*" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">



<html>
	<head>
		<title>Creating eclipseFormat . . . </title>
		<meta http-equiv=Content-Type content="text/html; charset=iso-8859-1">
	</head>
	<body>
    
	<%	
		//******Phase I:  copy eventCandidates file into eFtemp-date******
		//Create variables src and dst
		String sF = request.getParameter("srcF");//sF = source Filename
		String sD = request.getParameter("srcD");//sD = source Directory
			GregorianCalendar gc = new GregorianCalendar();
			java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy.MMdd.HHmmss.SSSS");
			String date = sdf.format(gc.getTime());
		String dF = "eventCandidates-"+date;//dF = destination Filename
 
		//SB,5/8/17:  This is like how it's done in save.jsp:  String plotDir = user.getDir("plots");
		//"user" is set in cosmic/src/jsp/include/elab.jsp from the session data, and getDir() is a method belonging to user.
		
		String dD = user.getDir("plots");//dD = destination Directory
		String src = "webapps"+sD+"/"+sF;
		String dst = dD+"/"+dF;
		
		//copy eventCandidates file to eFtemp in user's "plots" directory
		File file1 = new File(src);
       	File file2 = new File(dst);
		
		if (file1.exists()){
			Path source = Paths.get(src);
			Path destination = Paths.get(dst);
			try {
	                Files.copy(source, destination);
        	}//try 
        	catch (IOException e) {
                    e.printStackTrace();
            }//catch
		}//if

		//******Phase II:  Read one line at a time from eFtemp; parse, perform calculations, & write to eclipseFormat******
		
		if (file2.exists()){               
		//Code assumes the first 2 lines of input file start with '#'.
		BufferedReader br = null;
    	BufferedWriter bw = null;
		String src2 = dst;				//eFtemp-date is source in this phase
		String dst2 = dD+"/"+"eclipseFormat"+"-"+date+".txt";	//eclipseFormat-date is destination in this phase
				     
    		try{
        		br = new BufferedReader(new FileReader(src2));
        		bw = new BufferedWriter(new FileWriter(dst2));
 		       	TimeZone TIMEZONE  = TimeZone.getTimeZone("UTC");
 		       	 		       	
 		       	String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
 		       	String line = br.readLine();        		        				 
				String lastJD = " "; String jd = " ";	
				List<String> listRate = new ArrayList<String>(); //endInterval, numEvents
				String rateDAQ = "6119";
				String rate1stCh = "1";
				String rate2ndCh = "2";				
				
				double endInterval = 0.0; //endInterval represents the end of a 10-min period, measured in fractional day after 1st event
				double rateInterval = 1.0/144.0; // 10 min = 6*10^11 ns = 1.0/144.0
				//double rateInterval = 1.0/360.0; // 4 min = 1.0/360.0
				double FracDayToNs = 0.0; 
				double minFracDay = 0.0;
				
				int i = 0;   
				int numEvents = 1;//number of events in a 10-min window; assume there's at least 1 event in first window.
				int eventNum = 1; 
				int numHits = 1;
				int numBlankInt= 0;
				int rateCount = 0;
				
				
         	//loop through each line of input file src2 (eFtemp-date)
         	//while (line != null){ 
         	while (i < 10){ 
				i++;
				String[] words = line.split("\\s+");
				
				//1st time through this section of code, i=3 (after 2 lines that begin with '#').
				if(words[0].charAt(0) != '#' && i >= 3){
					eventNum = Integer.parseInt(words[0]);
					numHits = Integer.parseInt(words[1]);
					jd = words[4];
					String partial = words[5];//minimum fractional day		
					minFracDay = Double.parseDouble(partial); //assume 5th column of eventCandidates is min					
					
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
					}//for-j
					
					String[] arrayDJF = new String[listDJF.size()]; //DJF represents DAQ, Julian, Fraction
					arrayDJF = listDJF.toArray(arrayDJF); //arrayDJF can have different length for each line.
					//out.println("arrayDJF:  " + Arrays.toString(arrayDJF));					
					
					//convert minFracDay to sec
					double SecSinDayBeg = 3600*24*minFracDay;
						
					//Create List of DAQs.
					List<String> listDAQ = new ArrayList<String>();
					for ( int j=0; j < arrayDJF.length; j++){
						if (j%3 == 0){
							String DAQnumChan = arrayDJF[j];
							String DAQ = (DAQnumChan.split("\\."))[0];
							listDAQ.add(DAQ);
						}//if
					}//for
					
					//Get set of unique DAQs, convert to array, and sort. DAQ1: smaller DAQ#; DAQ2: bigger DAQ#.
					Set<String> setDAQ = new HashSet<String>(listDAQ);
					String[] arrayDAQ = setDAQ.toArray(new String[setDAQ.size()]);
    				if (arrayDAQ.length < 2) {
    					out.println("Only 1 DAQ was chosen!");
       				}//if
       				else if (arrayDAQ.length > 2) {
       					out.println("More than 2 DAQs were chosen!");
       					//Runtime.exit();
       				}
					Arrays.sort(arrayDAQ); 					
					String DAQ1 = arrayDAQ[0];
					String DAQ2 = arrayDAQ[arrayDAQ.length - 1];					
					
					//Calculate number of hits for each DAQ.  Note: Only considering UNIQUE DAQ.ch combos.
					int numHits1 = 0;
					int numHits2 = 0;	
					for (int j=0; j<listDAQ.size(); j++){
						if (DAQ1.equals(listDAQ.get(j))){numHits1++;}
						else if (DAQ2.equals(listDAQ.get(j))){numHits2++;}	
					}			
					
					// get the date and time of the event in human readable form
	                NanoDate nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), Double.parseDouble(partial));
        	        String eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);
        	        
					//output arrays
					String [] outArray = new String[8];
					for (int j=0; j<8; j++){outArray[j] = "-1";}
					String [] outArrayNs = new String[8];
					for (int j=0; j<8; j++){outArrayNs[j] = "-1";}
					
					//convert fraction of julian day to ns
					for (int p=0; p<arrayDJF.length; p++){	
						if (p%3 == 0){
							if ((Double.parseDouble(arrayDJF[p+2])-minFracDay) < 0.0){
								FracDayToNs = 3600*24*Math.pow(10,9)*(Double.parseDouble(arrayDJF[p+2])+1-minFracDay);
							}//if
							else{
								FracDayToNs = 3600*24*Math.pow(10,9)*(Double.parseDouble(arrayDJF[p+2])-minFracDay);
							}//else
																
							if((DAQ1+".1").equals(arrayDJF[p]))
								{outArray[0]=arrayDJF[p+2]; outArrayNs[0]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
  							else if ((DAQ1+".2").equals(arrayDJF[p]))
  								{outArray[1]=arrayDJF[p+2]; outArrayNs[1]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
        					else if ((DAQ1+".3").equals(arrayDJF[p]))
        						{outArray[2]=arrayDJF[p+2]; outArrayNs[2]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
							else if ((DAQ1+".4").equals(arrayDJF[p]))
								{outArray[3]=arrayDJF[p+2]; outArrayNs[3]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
							else if ((DAQ2+".1").equals(arrayDJF[p]))
								{outArray[4]=arrayDJF[p+2]; outArrayNs[4]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
							else if ((DAQ2+".2").equals(arrayDJF[p]))
								{outArray[5]=arrayDJF[p+2]; outArrayNs[5]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
							else if ((DAQ2+".3").equals(arrayDJF[p]))
								{outArray[6]=arrayDJF[p+2]; outArrayNs[6]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
							else if ((DAQ2+".4").equals(arrayDJF[p]))
								{outArray[7]=arrayDJF[p+2]; outArrayNs[7]=String.valueOf(Math.round(FracDayToNs*1000.0)/1000.0);}
						}//if	
					}//for		
					
					//check if all the Julian Day values are the same for the whole line
					boolean jdBool = true;//assume true all Julian Day values are same for whole line
					for (int j=0; j<arrayDJF.length; j++){						
						if (j%3 == 1){
							if(!jd.equals(arrayDJF[j])){
								jdBool = false;
							}//if
						}//if				
					}//for
					
					//Calculate interval counts 
					if (i == 3){
						endInterval = minFracDay + rateInterval;
						//heading
						listRate.add("EndFracDay"); listRate.add("EndTime(min)"); 
						listRate.add("IntervalEnd"); listRate.add("numEvents"); listRate.add("numEventsDAQ1CH1,2");
					}//if
					else if(i > 3){
						if (jd.equals(lastJD)){			
							if (minFracDay > endInterval){
								listRate.add(String.valueOf(endInterval)); 
								listRate.add(String.valueOf(endInterval*24.0*60.0)); 
							
								nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval);
								eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);
								listRate.add(eventDateTime);
							
								listRate.add(String.valueOf(numEvents));	//number of events
								listRate.add(String.valueOf(rateCount));//number of events that meet criteria
								
								numBlankInt = (int)  ((minFracDay - endInterval)/rateInterval);
								endInterval = endInterval + rateInterval;
								//append numBlankInt number of "0 event" lines
								for (int j = 0; j < numBlankInt; j++){	
									listRate.add(String.valueOf(endInterval));
									listRate.add(String.valueOf(endInterval*24.0*60.0)); 
								
									nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval);
									eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);
									listRate.add(eventDateTime);
								
									listRate.add("0");//number of events	
									listRate.add("0");//number of events that fulfill criteria 
									endInterval = endInterval + rateInterval;
								}//for		
								numEvents = 1; rateCount = 0;																		
							}//if	
							else {
								numEvents++;
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){
									rateCount++;
									out.println(rateCount);
								}//if
							}//else											
						}//if
						
						else if (!jd.equals(lastJD)){					
							endInterval = endInterval - 1.0;
							if (minFracDay > endInterval){
								listRate.add(String.valueOf(endInterval+1.0));
								listRate.add(String.valueOf((endInterval+1.0) * 24.0 * 60.0));
								
								nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval+1.0);
								eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);
								listRate.add(eventDateTime);
								
								listRate.add(String.valueOf(numEvents));
								listRate.add(String.valueOf(rateCount));//number of events that meet criteria
								
								numBlankInt = (int) ((minFracDay - endInterval)/rateInterval);
								endInterval = endInterval + rateInterval;
								//append numBlankInt number of "0 event" lines
								for (int j = 0; j < numBlankInt; j++){	
									listRate.add(String.valueOf(endInterval));
									listRate.add(String.valueOf(endInterval*24.0*60.0)); 
								
									//listRate.add("*");
									nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval+1.0);
									eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);
									listRate.add(eventDateTime);
									
									listRate.add("0"); //number of events	
									listRate.add("0");//number of events that fulfill criteria 
									
									endInterval = endInterval + rateInterval;
								}//for
								numEvents = 1; rateCount = 0;								
							}//if
							else {
								numEvents++;
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){
									rateCount++;
								}//if
							}//else
						}//elseif		
					}//else if (i>3)
					
					//Write to output file and console.
						StringBuffer result = new StringBuffer();												
						//Event number
						result.append(Integer.toString(eventNum)); result.append("\t"); 
						//num of hits for each DAQ
							result.append(Integer.toString(numHits1)); result.append("\t"); 
							result.append(Integer.toString(numHits2)); result.append("\t"); 
						//partial
						result.append(partial); result.append("\t"); 
						//JulianDay
						if (jdBool){result.append(jd); result.append("\t");}//if
							else{result.append("Not1JD"); result.append("\t");}//else	
						//SecSinDayBeg (SSDB)
						result.append(Double.toString(SecSinDayBeg)); result.append("\t"); 						
						result.append(eventDateTime); result.append("\t"); 
						//Data													 
						for (int p = 0; p < outArray.length; p++) {
   							result.append( outArray[p] ); result.append("\t"); result.append( outArrayNs[p] ); result.append("\t");
						}//for
						result.append("\n");
						String outline = result.toString();
						
						//Write heading after writing 2 lines that begin with '#'.  
						if (i == 3){
							StringBuffer heading = new StringBuffer();
							heading.append("Evnt"); heading.append("\t"); heading.append("#HitDAQ1"); heading.append("\t");
							heading.append("#HitDAQ2"); heading.append("\t"); heading.append("Partial"); heading.append("\t"); 
							heading.append("JulDay"); heading.append("\t"); heading.append("SSDB"); heading.append("\t"); 
							heading.append("eventDateTime"); heading.append("\t");
							heading.append(DAQ1+".1FracDay"); heading.append("\t");heading.append(DAQ1+".1nsAfter1stHit"); heading.append("\t");
							heading.append(DAQ1+".2FracDay"); heading.append("\t");heading.append(DAQ1+".2nsAfter1stHit"); heading.append("\t");	
							heading.append(DAQ1+".3FracDay"); heading.append("\t");heading.append(DAQ1+".3nsAfter1stHit"); heading.append("\t");		
							heading.append(DAQ1+".4FracDay"); heading.append("\t");heading.append(DAQ1+".4nsAfter1stHit"); heading.append("\t");
							if ( DAQ1.equals(DAQ2) && arrayDAQ.length == 1 ){	
								heading.append("*.1FracDay"); heading.append("\t");heading.append("*.1nsAfter1stHit"); heading.append("\t");	
								heading.append("*.2FracDay"); heading.append("\t");heading.append("*.2nsAfter1stHit"); heading.append("\t");
								heading.append("*.3FracDay"); heading.append("\t");heading.append("*.3nsAfter1stHit"); heading.append("\t");
								heading.append("*.4FracDay"); heading.append("\t");heading.append("*.4nsAfter1stHit"); heading.append("\t");	
							}//
							else {
								heading.append(DAQ2+".1FracDay"); heading.append("\t");heading.append(DAQ2+".1nsAfter1stHit"); heading.append("\t");
								heading.append(DAQ2+".2FracDay"); heading.append("\t");heading.append(DAQ2+".2nsAfter1stHit"); heading.append("\t");		
								heading.append(DAQ2+".3FracDay"); heading.append("\t");heading.append(DAQ2+".3nsAfter1stHit"); heading.append("\t");		
								heading.append(DAQ2+".4FracDay"); heading.append("\t");heading.append(DAQ2+".4nsAfter1stHit"); 
							}//else
							
							String outHeading = heading.toString();
							bw.write(outHeading); bw.newLine();
						}//if
						
				        bw.write(outline); 
				        //out.println(outline); out.println("<br>"); 
				        lastJD = jd;
						   			        
				}//if 
				//The first 2 lines (i = 1, 2) from eventCandidates file fall into 'else' - they start with '#'.
				else if (i < 3)  {
					bw.write(line);bw.newLine();
					listRate.add("*"); listRate.add(line); listRate.add("*"); listRate.add("*"); listRate.add("*"); 
				}//else
				
				line = br.readLine();        		
			}//while
				
				//Write second section	
				StringBuffer result2 = new StringBuffer();
				for (int j = 0; j < listRate.size()  ; j+=5){
						result2.append(listRate.get(j)); result2.append("\t"); 
						result2.append(listRate.get(j+1)); result2.append("\t");
						result2.append(listRate.get(j+2)); result2.append("\t");		
						result2.append(listRate.get(j+3)); result2.append("\t");	
						result2.append(listRate.get(j+4)); result2.append("\n");
				}//for	
				result2.append(minFracDay); result2.append("\t");
				result2.append(minFracDay*24.0*60.0); result2.append("\t");
					// get the date and time of the shower in human readable form
		            NanoDate nd2 = ElabUtil.julianToGregorian(Integer.parseInt(jd), minFracDay);
        		    String eventDateTime2 = DateFormatUtils.format(nd2, DATEFORMAT, TIMEZONE);
				result2.append(eventDateTime2); result2.append("\t");
				result2.append(numEvents); 
				
				String outline2 = result2.toString();
				bw.write(outline2);						
				
				request.setAttribute("dst2", dst2);	
	        	br.close();
	        	bw.close();
        		
        	//******Phase III:  Create link to download file eclipseFormat******
				//parse dst2 to remove /var/lib/tomcat7/webapp/ and create dst2v2
				String phrase = dst2;
				String[] tokensArray = phrase.split("/");	
				for (int q=0; q<tokensArray.length; q++){
				}
				String[] tokensArray2 = new String[tokensArray.length-5];
				for (int q=0; q < tokensArray2.length; q++){
					tokensArray2[q] = tokensArray[q+5];//tokensArray[0] is a space
				}	
				String dst2v2 = "/";
				//Don't concatenate last element of tokensArray2 since we don't need slash after it.	
				for (int q = 0; q<tokensArray2.length-1; q++){	
    				dst2v2 = dst2v2 + tokensArray2[q] + "/";
    			}//for-q	
    			dst2v2 = dst2v2 + tokensArray2[tokensArray2.length-1];	            
                dst2v2 = "http://" + request.getServerName() + dst2v2;
				request.setAttribute("dst2v2", dst2v2);							
				
    		}//try
    		catch(Exception e){
        		out.println("Exception caught : " + e);
    		}//catch
    	}//if-file2 exists
    	else{
    		out.println("eventCandidates file did not copy over to plots/ from scratch/!");
    	}//else
	%>
			<a href = "${dst2v2}">Download!</a>
			<%--Server host name is: <b><%=request.getServerName() %></b>--%>
	
	</body>
</html>

