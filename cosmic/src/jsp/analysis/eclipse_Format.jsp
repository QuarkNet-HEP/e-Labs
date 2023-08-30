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
		
		//******Phase I:  copy eventCandidates file into eventCandidates-date******
		//Create variables src and dst
		String sF = request.getParameter("srcF");//sF = source Filename
		String sD = request.getParameter("srcD");//sD = source Directory
		String writeAllEvents = request.getParameter("writeAllEvents").trim();
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

		//**Phase II:  Read one line at a time from eventCandidates-date; parse, perform calculations, & write to eclipseFormat-date & eclipseRate-date**
		
		if (file2.exists()){               
		//Code assumes the first 2 lines of input file start with '#'.
		BufferedReader br = null;
    	BufferedWriter bw = null;
		BufferedWriter bw2 = null;    	
		String src2 = dst;				//eventCandidates-date is source in this phase
		String dst2 = dD+"/"+"eclipseFormat"+"-"+date+".txt";	//eclipseFormat-date is a new destination in this phase
		String dst2b = dD+"/"+"eclipseRate"+"-"+date+".txt";	//eclipseRate-date is another destination in this phase		 
				     
    		try{
        		br = new BufferedReader(new FileReader(src2));
	         	bw = new BufferedWriter(new FileWriter(dst2));
        		bw2 = new BufferedWriter(new FileWriter(dst2b));
 		       	TimeZone TIMEZONE  = TimeZone.getTimeZone("UTC");
 		       	 		       	
 		       	String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
 		       	String line = br.readLine();        		        				 
				String lastJD = " "; String jd = "1";	
				List<String> listRate = new ArrayList<String>(); //endInterval, numEvents	
				
				double endInterval = 0.0; //endInterval represents the end of a 10-min period, measured in fractional day after 1st event
				double rateInterval = 1.0/144.0; // 10 min = 6*10^11 ns = 1.0/144.0
				//double rateInterval = 1.0/360.0; // 4 min = 1.0/360.0
				double minFracDay = 0.0, fracDayToNs = 0.0, ratio13_12 = -1.0; 
				
				int numEvents = 1;//number of events in a 10-min window; assume there's at least 1 event in first window.
				int i = 0; //i keeps count of number of times through while loop
				int eventNum = 1, numHits = 1, numBlankInt= 0; 
				int rateCount12 = 0, rateCount13 = 0, rateCount34 = 0, rateCount1234 = 0; 
				int rateCount24 = 0, rateCount14 = 0, rateCount23 = 0;
				int rateCount123 = 0, rateCount124 = 0, rateCount134 = 0, rateCount234 = 0;
				
				NanoDate nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), minFracDay); 
				NanoDate nd2 = ElabUtil.julianToGregorian(Integer.parseInt(jd), minFracDay); 
				NanoDate nd3 = ElabUtil.julianToGregorian(Integer.parseInt(jd), minFracDay);
				String eventDateTime = " ", eventDateTime2 = " ", eventDateTime3 = " ";
				Boolean oneDAQMsg = false;//becomes true if we've output to the screen once "Only 1 DAQ was chosen!"
				
         	//loop through each line of input file src2 (eventCandidates-date)
         	while (line != null){ 
				i++;
				//split String line into array of substrings using all whitespace characters (' ', '\t', '\n', etc.) as delimiters
				String[] words = line.split("\\s+"); 
				
				//1st time through this section of code, i=3 (after 2 lines that begin with '#').
				if(words[0].charAt(0) != '#' && i >= 3){
					eventNum = Integer.parseInt(words[0]);
					numHits = Integer.parseInt(words[1]);
					jd = words[4];	
					minFracDay = Double.parseDouble(words[5]); //assume 6th col of eventCandidates is min frac day		
					
					// get the date and time of the event (minFracDay) in human readable form
	                nd = ElabUtil.julianToGregorian(Integer.parseInt(jd), minFracDay);
        	        eventDateTime = DateFormatUtils.format(nd, DATEFORMAT, TIMEZONE);        	        	
					
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
    				if (arrayDAQ.length < 2 && !oneDAQMsg) {
    					out.println("Only 1 DAQ was chosen!");
    					oneDAQMsg = true;
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
					
					//output arrays
					String [] outArray = new String[8];
					for (int j=0; j<8; j++){outArray[j] = "-1";}
					String [] outArrayNs = new String[8];
					for (int j=0; j<8; j++){outArrayNs[j] = "-1";}
					
					//convert fraction of julian day to ns
					for (int p=0; p<arrayDJF.length; p++){	
						if (p%3 == 0){
							//logic for Julian Day change within a row					
							if ((Double.parseDouble(arrayDJF[p+2])-minFracDay) < 0.0){
								fracDayToNs = 3600*24*Math.pow(10,9)*(1.0 + Double.parseDouble(arrayDJF[p+2]) - minFracDay);
							}//if
							else{
								fracDayToNs = 3600*24*Math.pow(10,9)*(Double.parseDouble(arrayDJF[p+2])-minFracDay);
							}//else
																
							if((DAQ1+".1").equals(arrayDJF[p]))
								{outArray[0]=arrayDJF[p+2]; outArrayNs[0]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
  							else if ((DAQ1+".2").equals(arrayDJF[p]))
  								{outArray[1]=arrayDJF[p+2]; outArrayNs[1]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
        					else if ((DAQ1+".3").equals(arrayDJF[p]))
        						{outArray[2]=arrayDJF[p+2]; outArrayNs[2]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
							else if ((DAQ1+".4").equals(arrayDJF[p]))
								{outArray[3]=arrayDJF[p+2]; outArrayNs[3]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
							else if ((DAQ2+".1").equals(arrayDJF[p]))
								{outArray[4]=arrayDJF[p+2]; outArrayNs[4]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
							else if ((DAQ2+".2").equals(arrayDJF[p]))
								{outArray[5]=arrayDJF[p+2]; outArrayNs[5]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
							else if ((DAQ2+".3").equals(arrayDJF[p]))
								{outArray[6]=arrayDJF[p+2]; outArrayNs[6]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
							else if ((DAQ2+".4").equals(arrayDJF[p]))
								{outArray[7]=arrayDJF[p+2]; outArrayNs[7]=String.valueOf(Math.round(fracDayToNs*10.0)/10.0);}
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
						//heading - 15 columns
						listRate.add("EndFracDay"); listRate.add("EndTime(min)"); listRate.add("IntervalEnd");
						listRate.add("numEvents"); listRate.add("D1CH12#Evnt"); listRate.add("D1CH13#Evnt"); 
						listRate.add("D1CH34#Evnt"); listRate.add("D1CH1234#Evnt"); listRate.add("D1CH24#Evnt"); 
						listRate.add("D1CH14#Evnt"); listRate.add("D1CH23#Evnt");
						listRate.add("D1CH123#Evnt"); listRate.add("D1CH124#Evnt"); 
						listRate.add("D1CH134#Evnt"); listRate.add("D1CH234#Evnt");
				
						
						if (!outArray[0].equals("-1") && !outArray[1].equals("-1")){rateCount12++;}//if
						if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){rateCount13++;}//if
						if (!outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount34++;}//if
						if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount1234++;}//if
						if (!outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount24++;}//if
						if (!outArray[0].equals("-1") && !outArray[3].equals("-1")){rateCount14++;}//if
						if (!outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount23++;}//if						

						if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount123++;}//if
						if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount124++;}//if
						if (!outArray[0].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount134++;}//if
						if (!outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount234++;}//if
					
					}//if
					if(i > 3){
						if (jd.equals(lastJD)){			
							if (minFracDay > endInterval){							
								listRate.add(String.valueOf(endInterval)); 
								listRate.add(String.valueOf(endInterval*24.0*60.0)); 
							
								nd2 = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval);
								eventDateTime2 = DateFormatUtils.format(nd2, DATEFORMAT, TIMEZONE);
								listRate.add(eventDateTime2);
							
								listRate.add(String.valueOf(numEvents));//number of events
								listRate.add(String.valueOf(rateCount12));//number of events that meet criteria DAQ1CH12
								listRate.add(String.valueOf(rateCount13));//number of events that meet criteria DAQ1CH13
								listRate.add(String.valueOf(rateCount34));//number of events that meet criteria DAQ1CH34
								listRate.add(String.valueOf(rateCount1234));//number of events that meet criteria DAQ1CH1234
								listRate.add(String.valueOf(rateCount24));//number of events that meet criteria DAQ1CH24
								listRate.add(String.valueOf(rateCount14));//number of events that meet criteria DAQ1CH14
								listRate.add(String.valueOf(rateCount23));//number of events that meet criteria DAQ1CH23

								listRate.add(String.valueOf(rateCount123));//number of events that meet criteria DAQ1CH123
								listRate.add(String.valueOf(rateCount124));//number of events that meet criteria DAQ1CH124
								listRate.add(String.valueOf(rateCount134));//number of events that meet criteria DAQ1CH134
								listRate.add(String.valueOf(rateCount234));//number of events that meet criteria DAQ1CH234

								//if (rateCount12 != 0) {
								//	ratio13_12 = rateCount13*1.0/rateCount12;	
								//}//if
								//else {
								//	ratio13_12 = -1.0;
								//}//else
								//listRate.add(String.valueOf(ratio13_12)); 
								
								numBlankInt = (int)  ((minFracDay - endInterval)/rateInterval);
								endInterval = endInterval + rateInterval;
								//append numBlankInt number of "0 event" lines
								for (int j = 0; j < numBlankInt; j++){	
									listRate.add(String.valueOf(endInterval));
									listRate.add(String.valueOf(endInterval*24.0*60.0)); 
								
									nd2 = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval);
									eventDateTime2 = DateFormatUtils.format(nd2, DATEFORMAT, TIMEZONE);
									listRate.add(eventDateTime2);
									
									listRate.add("0");//number of events	
									//if num of events = 0, num of events that fulfill each criteria = 0 
									for (int k = 0; k < 10; k++){ 
										listRate.add("0");
									}//for
									listRate.add("-1.0");//For a blank interval, rateCount12 = 0, so ratio13_12 = -1.0
									
									endInterval = endInterval + rateInterval;
								}//for		
								numEvents = 1; 
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1")){rateCount12 = 1;}//if
									else {rateCount12 = 0;}//else		
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){rateCount13 = 1;}//if
									else {rateCount13 = 0;}//else		
								if (!outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount34 = 1;}//if
									else {rateCount34 = 0;}//else			
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount1234 = 1;}//if
									else {rateCount1234 = 0;}//else			
								if (!outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount24 = 1;}//if
									else {rateCount24 = 0;}//else	
								if (!outArray[0].equals("-1") && !outArray[3].equals("-1")){rateCount14 = 1;}//if
									else {rateCount14 = 0;}//else	
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount23 = 1;}//if
									else {rateCount23 = 0;}//else										

								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount123 = 1;}//if
									else {rateCount123 = 0;}//else			
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount124 = 1;}//if
									else {rateCount124 = 0;}//else			
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount134 = 1;}//if
									else {rateCount134 = 0;}//else			
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount234 = 1;}//if
									else {rateCount234 = 0;}//else			
							
							}//if	
							else {
								numEvents++;
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1")){rateCount12++;}//if
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){rateCount13++;}//if
								if (!outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount34++;}//if
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount1234++;}//if
								if (!outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount24++;}//if
								if (!outArray[0].equals("-1") && !outArray[3].equals("-1")){rateCount14++;}//if
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount23++;}//if

								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount123++;}//if
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount124++;}//if
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount134++;}//if
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount234++;}//if

							}//else											
						}//if
						
						else if (!jd.equals(lastJD)){					
							endInterval = endInterval - 1.0;
							if (minFracDay > endInterval){
								listRate.add(String.valueOf(endInterval+1.0));
								listRate.add(String.valueOf((endInterval+1.0) * 24.0 * 60.0));
								
								nd2 = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval+1.0);
								eventDateTime2 = DateFormatUtils.format(nd2, DATEFORMAT, TIMEZONE);
								listRate.add(eventDateTime2);
								
								listRate.add(String.valueOf(numEvents));//number of events
								listRate.add(String.valueOf(rateCount12));//number of events that meet criteria DAQ1CH12
								listRate.add(String.valueOf(rateCount13));//number of events that meet criteria DAQ1CH13
								listRate.add(String.valueOf(rateCount34));//number of events that meet criteria DAQ1CH34
								listRate.add(String.valueOf(rateCount1234));//number of events that meet criteria DAQ1CH1234
								listRate.add(String.valueOf(rateCount24));//number of events that meet criteria DAQ1CH24
								listRate.add(String.valueOf(rateCount14));//number of events that meet criteria DAQ1CH14
								listRate.add(String.valueOf(rateCount23));//number of events that meet criteria DAQ1CH23

								listRate.add(String.valueOf(rateCount123));//number of events that meet criteria DAQ1CH123
								listRate.add(String.valueOf(rateCount124));//number of events that meet criteria DAQ1CH124
								listRate.add(String.valueOf(rateCount134));//number of events that meet criteria DAQ1CH134
								listRate.add(String.valueOf(rateCount234));//number of events that meet criteria DAQ1CH234
								
								//if (rateCount12 != 0) {
								//	ratio13_12 = rateCount13*1.0/rateCount12;	
								//}//if
								//else {
								//	ratio13_12 = -1.0;
								//}//else
								//listRate.add(String.valueOf(ratio13_12)); 
								
								numBlankInt = (int) ((minFracDay - endInterval)/rateInterval);
								endInterval = endInterval + rateInterval;
								//append numBlankInt number of "0 event" lines
								for (int j = 0; j < numBlankInt; j++){	
									listRate.add(String.valueOf(endInterval));
									listRate.add(String.valueOf(endInterval*24.0*60.0)); 
								
									nd2 = ElabUtil.julianToGregorian(Integer.parseInt(jd), endInterval+1.0);
									eventDateTime2 = DateFormatUtils.format(nd2, DATEFORMAT, TIMEZONE);
									listRate.add(eventDateTime2);
									
									listRate.add("0");//number of events	
									//if num of events = 0, num of events that fulfill each criteria = 0
									for (int k = 0; k < 10; k++){ 
										listRate.add("0");//number of events	
									}//for
									listRate.add("-1.0");//For a blank interval, rateCount12 = 0, so ratio13_12 = -1.0
									
									endInterval = endInterval + rateInterval;
								}//for
								numEvents = 1; 
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1")){rateCount12 = 1;}//if
									else {rateCount12 = 0;}//else		
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){rateCount13 = 1;}//if
									else {rateCount13 = 0;}//else			
								if (!outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount34 = 1;}//if
									else {rateCount34 = 0;}//else			
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount1234 = 1;}//if
									else {rateCount1234 = 0;}//else			
								if (!outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount24 = 1;}//if
									else {rateCount24 = 0;}//else	
								if (!outArray[0].equals("-1") && !outArray[3].equals("-1")){rateCount14 = 1;}//if
									else {rateCount14 = 0;}//else	
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount23 = 1;}//if
									else {rateCount23 = 0;}//else															

								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount123 = 1;}//if
									else {rateCount123 = 0;}//else			
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount124 = 1;}//if
									else {rateCount124 = 0;}//else			
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount134 = 1;}//if
									else {rateCount134 = 0;}//else			
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount234 = 1;}//if
									else {rateCount234 = 0;}//else			
							
							}//if
							else {
								numEvents++;
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1")){rateCount12++;}//if
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1")){rateCount13++;}//if
								if (!outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount34++;}//if
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount1234++;}//if
								if (!outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount24++;}//if
								if (!outArray[0].equals("-1") && !outArray[3].equals("-1")){rateCount14++;}//if
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount23++;}//if

								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[2].equals("-1")){rateCount123++;}//if
								if (!outArray[0].equals("-1") && !outArray[1].equals("-1") && !outArray[3].equals("-1")){rateCount124++;}//if
								if (!outArray[0].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount134++;}//if
								if (!outArray[1].equals("-1") && !outArray[2].equals("-1") && !outArray[3].equals("-1")){rateCount234++;}//if
								
							}//else
						}//else if		
					}//if (i>3)
					
					//Write to output file and console.
						StringBuffer result = new StringBuffer();												
						//Event number
						result.append(Integer.toString(eventNum)); result.append("\t"); 
						//num of hits for each DAQ
							result.append(Integer.toString(numHits1)); result.append("\t"); 
							result.append(Integer.toString(numHits2)); result.append("\t"); 
						//minFracDay
						result.append(Double.toString(minFracDay)); result.append("\t"); 
						//JulianDay
						if (jdBool){
							result.append(jd); result.append("\t");
						}//if
						else{
							result.append("Not1JD"); result.append("\t");
						}//else	
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
							heading.append("Evnt"); heading.append("\t"); heading.append("NmHitDAQ1"); heading.append("\t");
							heading.append("NmHitDAQ2"); heading.append("\t"); heading.append("MinFracDay"); heading.append("\t"); 
							heading.append("JulDay"); heading.append("\t"); heading.append("SSDB"); heading.append("\t"); 
							heading.append("eventDateTime"); heading.append("\t");
							heading.append("FracD"+DAQ1+".1"); heading.append("\t");heading.append("nsAft1stHit"+DAQ1+".1"); heading.append("\t");
							heading.append("FracD"+DAQ1+".2"); heading.append("\t");heading.append("nsAft1stHit"+DAQ1+".2"); heading.append("\t");	
							heading.append("FracD"+DAQ1+".3"); heading.append("\t");heading.append("nsAft1stHit"+DAQ1+".3"); heading.append("\t");		
							heading.append("FracD"+DAQ1+".4"); heading.append("\t");heading.append("nsAft1stHit"+DAQ1+".4"); heading.append("\t");
							if ( DAQ1.equals(DAQ2) && arrayDAQ.length == 1 ){	
								heading.append("FracD*.1"); heading.append("\t");heading.append("nsAft1stHit"+"*.1"); heading.append("\t");	
								heading.append("FracD*.2"); heading.append("\t");heading.append("nsAft1stHit"+"*.2"); heading.append("\t");
								heading.append("FracD*.3"); heading.append("\t");heading.append("nsAft1stHit"+"*.3"); heading.append("\t");
								heading.append("FracD*.4"); heading.append("\t");heading.append("nsAft1stHit"+"*.4"); heading.append("\t");	
							}//
							else {
								heading.append("FracD"+DAQ2+".1"); heading.append("\t");heading.append("nsAft1stHit"+DAQ2+".1"); heading.append("\t");
								heading.append("FracD"+DAQ2+".2"); heading.append("\t");heading.append("nsAft1stHit"+DAQ2+".2"); heading.append("\t");		
								heading.append("FracD"+DAQ2+".3"); heading.append("\t");heading.append("nsAft1stHit"+DAQ2+".3"); heading.append("\t");		
								heading.append("FracD"+DAQ2+".4"); heading.append("\t");heading.append("nsAft1stHit"+DAQ2+".4"); 
							}//else
							
							String outHeading = heading.toString();
							if (writeAllEvents.equals("yes")) {
								bw.write(outHeading); bw.newLine();
							}
						}//if
						if (writeAllEvents.equals("yes")) {
					        bw.write(outline); 
						}
				        //out.println(outline); out.println("<br>"); 
				        lastJD = jd;
						   			        
				}//if 
				//The first 2 lines (i = 1, 2) from eventCandidates file fall into 'else' - they start with '#'.
				else if (i < 3)  {
					if (writeAllEvents.equals("yes")) {
						bw.write(line);bw.newLine();
					}
					listRate.add(line);  
					for (int k = 0; k < 14; k++){
						listRate.add("*"); 
					}//for
				}//else
				
				line = br.readLine();        		
			}//while
				
				//Write second section		
			StringBuffer result2 = new StringBuffer();
			for (int j = 0; j < listRate.size()  ; j+=15){
				for (int k = 0; k < 14; k++){
					if ((j+k) < listRate.size()) {
						result2.append(listRate.get(j+k)); result2.append("\t");
					}
           		}//for	
				if ((j+14) < listRate.size()) {
					result2.append(listRate.get(j+14)); result2.append("\n");//last col of each row is followed by new-line, not tab		
				}
			}//for	
							
				//last row
				result2.append(minFracDay); result2.append("\t");
				result2.append(minFracDay*24.0*60.0); result2.append("\t");
					// get the date and time of the shower in human readable form
		            nd3 = ElabUtil.julianToGregorian(Integer.parseInt(jd), minFracDay);
        		    eventDateTime3 = DateFormatUtils.format(nd3, DATEFORMAT, TIMEZONE);
				result2.append(eventDateTime3); result2.append("\t");
				result2.append(numEvents); result2.append("\t");
				result2.append(rateCount12); result2.append("\t");
				result2.append(rateCount13); result2.append("\t");
				result2.append(rateCount34); result2.append("\t");
				result2.append(rateCount1234); result2.append("\t");
				result2.append(rateCount24); result2.append("\t");
				result2.append(rateCount14); result2.append("\t");
				result2.append(rateCount23); result2.append("\t");
				result2.append(rateCount123); result2.append("\t");
				result2.append(rateCount124); result2.append("\t");
				result2.append(rateCount134); result2.append("\t");
				result2.append(rateCount234); result2.append("\t");
				
				//result2.append(ratio13_12);	
				
				String outline2 = result2.toString();
				bw2.write(outline2);						
				
				//request.setAttribute("dst2", dst2);	
				//request.setAttribute("dst2b", dst2b);	
	        	br.close();
		        bw.close();
	        	bw2.close();
        		
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
    			
    			//create dst2bv2 
    			String phrase2 = dst2b;
                String[] tokens = phrase2.split("/");
                String dst2bv2 = dst2v2;
                
                //concatenate last element	 
                dst2bv2 = dst2v2 + tokens[tokens.length - 1];//this should happen first		               	
    			dst2v2 = dst2v2 + tokensArray2[tokensArray2.length-1];
    			
    			
    			//add http:// to start
                dst2v2 = "http://" + request.getServerName() + dst2v2;
                dst2bv2 = "http://" + request.getServerName() + dst2bv2;
                
				request.setAttribute("dst2v2", dst2v2);					
				request.setAttribute("dst2bv2", dst2bv2);	
				request.setAttribute("writeAllEvents", writeAllEvents);
				
				
    		}//try
    		catch(Exception e){
        		out.println("Exception caught : " + e);
    		}//catch
    	}//if-file2 exists
    	else{
    		out.println("eventCandidates file did not copy over to plots/ from scratch/!");
    	}//else
	%>
			<c:if test="${writeAllEvents=='yes'}">
				<a href = "${dst2v2}">Download eclipseFormat!</a>
			</c:if>
			<a href = "${dst2bv2}">Download eclipseRate!</a>
			<%--Server host name is: <b><%=request.getServerName() %></b>--%>
	
	</body>
</html>
