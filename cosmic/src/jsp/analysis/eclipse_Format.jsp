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
		String dF = "eFtemp-"+date;//dF = destination Filename
 
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
        	        } catch (IOException e) {
                        e.printStackTrace();
                	}
		}		

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
 		       	String line = br.readLine();
 		       	
         		int i = 0;           
				double endTen = 0.0; //endTen represents the end of a 10-min period, measured in fractional day after 1st event
				double tenMin = 1.0/144.0;
				int numBlankTen = 0;
				List<String> listRate = new ArrayList<String>(); 
				int numEvents = 1;//number of events in a 10-min window
				
         	//loop through each line of input file src2 (eFtemp-date)
         	//while (line != null){ 
         	while (i < 50){ 
				i++;
				String[] words = line.split("\\s+");
				
				//1st time through this section of code, i=3 (after 2 lines that begin with '#').
				if(words[0].charAt(0) != '#'){
					int eventNum = Integer.parseInt(words[0]);
					int numHits = Integer.parseInt(words[1]);
					String jd = words[4];
					String partial = words[5];//minimum fractional day		
					double minFracDay = Double.parseDouble(partial); //assume 5th column of eventCandidates is min; check later	
					double numBlankTen= 0.0; 
					
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
					//out.println("Length of arrayDJF:  " + String.valueOf(arrayDJF.length));
					
					//find smallest fraction of day in arrayDJF
					for (int p=0; p<arrayDJF.length; p++){	
						if (p%3 == 2){
							if(Double.parseDouble(arrayDJF[p]) < minFracDay){
								minFracDay = Double.parseDouble(arrayDJF[p]);
							}//if
						}//if
					}//for-p
					
					//convert minFracDay to sec
					double SecSinDayBeg = 3600*24*minFracDay;
						
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
					Set<String> setDAQ = new HashSet<String>(listDAQ);
					String[] arrayDAQ = setDAQ.toArray(new String[setDAQ.size()]);
    				if (arrayDAQ.length != 2) {
    					out.println("2 DAQs were not chosen!");
       				}//if
					Arrays.sort(arrayDAQ); 					
					String DAQ1 = arrayDAQ[0];
					String DAQ2 = arrayDAQ[arrayDAQ.length - 1];					
					
					//Calculate number of hits for each DAQ.  Note: Only considering UNIQUE DAQ.ch combos.
					int numHits1 = 0;
					int numHits2 = 0;	
					for (int k=0; k<listDAQ.size(); k++){
						if (DAQ1.equals(listDAQ.get(k))){numHits1++;}
						else if (DAQ2.equals(listDAQ.get(k))){numHits2++;}	
					}			
					
					// get the date and time of the shower in human readable form
	                NanoDate nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), Double.parseDouble(partial));
    	            String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
        	        TimeZone TIMEZONE  = TimeZone.getTimeZone("UTC");
        	        String eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);//
        	        
					//output arrays
					String [] outArray = new String[8];
					for (int m=0; m<8; m++){outArray[m] = "-1";}
					String [] outArrayNs = new String[8];
					for (int m=0; m<8; m++){outArrayNs[m] = "-1";}
					
					//convert fraction of julian day to ns
					for (int p=0; p<arrayDJF.length; p++){	
						if (p%3 == 0){
							double FracDayToNs = 3600*24*Math.pow(10,9)*(Double.parseDouble(arrayDJF[p+2])-minFracDay);
										
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
					for (int p=0; p<arrayDJF.length; p++){						
						if (p%3 == 1){
							if(!jd.equals(arrayDJF[p])){
								jdBool = false;
							}//if
						}//if				
					}//for
					
					//Calculate rates
					if (i == 3){endTen = minFracDay + tenMin;} // 10 min = 6*10^11 ns = 1.0/144.0			
					if (i > 3){
						if (minFracDay > endTen){
							listRate.add(String.valueOf(endTen)); listRate.add(String.valueOf(numEvents));	
							numBlankTen = (int)  ((minFracDay - endTen)/tenMin);
							endTen = endTen + tenMin;
							//append numBlankTen number of "0 event" lines
							for (int j = 0; j < numBlankTen; j++){	
								listRate.add(String.valueOf(endTen)); listRate.add("0");	
								endTen = endTen + tenMin;
							}//for		
							numEvents = 1;												
						}//if	
						else {
							numEvents++;
						}//else					
					}//if
					
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
   							result.append( outArray[p] ); result.append("\t"); result.append( outArrayNs[p] ); 
						}//for
						result.append("\n");
						String outline = result.toString();
						
						//Write heading after writing 2 lines that begin with '#'.  
						if (i == 3){
							StringBuffer heading = new StringBuffer();
							heading.append("Evnt"); heading.append("\t"); heading.append("#Hit1"); heading.append("\t");
							heading.append("#Hit2"); heading.append("\t"); heading.append("Partial"); heading.append("\t"); 
							heading.append("JulDay"); heading.append("\t"); heading.append("SSDB"); heading.append("\t"); 
							heading.append("eventDateTime"); heading.append("\t");
							heading.append(DAQ1+".1FracDay"); heading.append("\t");heading.append(DAQ1+".1nsAfter1stHit"); heading.append("\t");
							heading.append(DAQ1+".2FracDay"); heading.append("\t");heading.append(DAQ1+".2nsAfter1stHit"); heading.append("\t");	
							heading.append(DAQ1+".3FracDay"); heading.append("\t");heading.append(DAQ1+".3nsAfter1stHit"); heading.append("\t");		
							heading.append(DAQ1+".4FracDay"); heading.append("\t");heading.append(DAQ1+".4nsAfter1stHit"); heading.append("\t");	
							heading.append(DAQ2+".1FracDay"); heading.append("\t");heading.append(DAQ2+".1nsAfter1stHit"); heading.append("\t");		
							heading.append(DAQ2+".2FracDay"); heading.append("\t");heading.append(DAQ2+".2nsAfter1stHit"); heading.append("\t");		
							heading.append(DAQ2+".3FracDay"); heading.append("\t");heading.append(DAQ2+".3nsAfter1stHit"); heading.append("\t");		
							heading.append(DAQ2+".4FracDay"); heading.append("\t");heading.append(DAQ2+".4nsAfter1stHit"); 

							String outHeading = heading.toString();
							bw.write(outHeading); bw.newLine();
						}//if
						
				        bw.write(outline); 
				        out.println(outline); out.println("<br>");         			        
				}//if (i >= 3)
				//The first 2 lines (i = 1, 2) from eventCandidates file fall into 'else' - they start with '#'.
				else {
					bw.write(line);bw.newLine();
					listRate.add("*"); listRate.add(line);
				}//else
				
				line = br.readLine();        		
			}//while
				
				//Write second section	
				for (int j = 0; j < listRate.size(); j++){
					result.append(listRate.get(j)); result.append("\t"); result.append(j+1); result.append("\n");	
					String outline = result.toString();
					bw.write(outline);				
				}//for				
				
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
	<%--<Phase III:  Provide link to download file eclipseFormat--%>	
			<a href = "${dst2v2}">Download!</a>
			<%--Server host name is: <b><%=request.getServerName() %></b>--%>
	
	</body>
</html>

