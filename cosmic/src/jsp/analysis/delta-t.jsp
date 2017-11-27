<%-- Author:  Sudha Balakrishnan, 10/13/17 --%>
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
		//BufferedWriter bw2 = null;    	
		String src2 = dst;				//eventCandidates-date is source in this phase
		String dst2 = dD+"/"+"delta-t"+"-"+date+".txt";	//eclipseFormat-date is a new destination in this phase
		//String dst2b = dD+"/"+"delta-tRate"+"-"+date+".txt";	//eclipseRate-date is another destination in this phase		 
				     
    		try{
        		br = new BufferedReader(new FileReader(src2));
        		bw = new BufferedWriter(new FileWriter(dst2));
        		//bw2 = new BufferedWriter(new FileWriter(dst2b));
 		       	TimeZone TIMEZONE  = TimeZone.getTimeZone("UTC");
 		       	 		       	
 		       	String DATEFORMAT = "MMM d, yyyy HH:mm:ss z";
 		       	String line = br.readLine();        		        				 
				//String lastJD = " "; 
				String jd = "1";	
				List<String> listRate = new ArrayList<String>(); //endInterval, numEvents	
				
				double endInterval = 0.0; //endInterval represents the end of a 10-min period, measured in fractional day after 1st event
				double rateInterval = 1.0/144.0; // 10 min = 6*10^11 ns = 1.0/144.0
				//double rateInterval = 1.0/360.0; // 4 min = 1.0/360.0
				double minFracDay = 0.0, fracDayToNs = 0.0; 
				double delta_t = 0.0, firstHitDAQ1 = 0.0, firstHitDAQ2 = 0.0; 		
				List<Double> delta_tList = new ArrayList<Double>();	
				
				int numEvents = 1;//number of events in a 10-min window; assume there's at least 1 event in first window.
				int i = 0; //i keeps count of number of times through while loop
				int eventNum = 1, numHits = 1, numBlankInt= 0; 
				
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
					
					//initialize output arrays
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
					
					//find smallest fractional day for each DAQ.  
					//first guess that 1.1 is the smallest fractional day for DAQ1
					firstHitDAQ1 = 1.1; 
					for (int p=0; p<4; p++){
					    if (!"-1".equals(outArray[p]) && Double.parseDouble(outArray[p])<firstHitDAQ1){
					    	firstHitDAQ1 = Double.parseDouble(outArray[p]);
					    }//if
					}//for
					
					//first guess that 1.1 is the smallest fractional day for DAQ2
					firstHitDAQ2 = 1.1; 
					for (int p=4; p<8; p++){
					    if (!"-1".equals(outArray[p]) && Double.parseDouble(outArray[p])<firstHitDAQ2){
					    	firstHitDAQ2 = Double.parseDouble(outArray[p]);
					    }//if
					}//for
					
					delta_t = Math.abs(firstHitDAQ1 - firstHitDAQ2);
					delta_tList.add(delta_t);
					       
					//check if all the Julian Day values are the same for the whole line
					boolean jdBool = true;//assume true all Julian Day values are same for whole line
					for (int j=0; j<arrayDJF.length; j++){						
						if (j%3 == 1){
							if(!jd.equals(arrayDJF[j])){
								jdBool = false;
							}//if
						}//if				
					}//for
					
					
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
						
						result.append(Double.toString(firstHitDAQ1)); result.append("\t");//new line of code
						result.append(Double.toString(firstHitDAQ2)); result.append("\t");//new line of code
						result.append(Double.toString(delta_t)); result.append("\n");//new line of code
						
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
								heading.append("FracD"+DAQ2+".4"); heading.append("\t");heading.append("nsAft1stHit"+DAQ2+".4"); heading.append("\t");
								heading.append("firstHitDAQ1"); heading.append("\t"); heading.append("firstHitDAQ2"); heading.append("\t");
								heading.append("delta-t");
							}//else
							
							String outHeading = heading.toString();
							bw.write(outHeading); bw.newLine();
						}//if
						
				        bw.write(outline); 
				        //out.println(outline); out.println("<br>"); 
				        //lastJD = jd;
						   			        
				}//if 
				//The first 2 lines (i = 1, 2) from eventCandidates file fall into 'else' - they start with '#'.
				else if (i < 3)  {
					bw.write(line);bw.newLine();
				}//else
				
				line = br.readLine();        		
			}//while
			
			
			//In this section, create data for histogram.
			double binWidth = 10.0, totNumBins = 1; //binWidth in ns
			List<Double> binList = new ArrayList<Double>();
			int binCount = 0;
			
			//Convert delta_tList to array delta_tArray
			Double[] delta_tArray = delta_tList.toArray(new Double[delta_tList.size()]);
			//Convert each element of delta_tArray from fractional day to ns		
			for (int k = 0; k < delta_tArray.length; k++){
				delta_tArray[k] = 3600*24*Math.pow(10,9)*delta_tArray[k];
			}//for
			
			//Sort delta_tArray; 
			Arrays.sort(delta_tArray);						
			
			//totNumBins = Math.ceil((delta_tArray[delta_tArray.length - 1] - delta_tArray[0])/binWidth);
			//out.println("totNumBins: "+totNumBins);
			
			//Traverse delta_tArray and determine which bin each element belongs to
				int binNum = 1; 	
				for (int j = 0; j < delta_tArray.length; j++){
					//if (delta_tArray[j] < (floor(delta_tArray[0]*(10^-2))*10^2)+(binWidth*binNum)){
					if (delta_tArray[j] < 100+(binWidth*binNum)){
						binCount++;
					}//if
					else{
						binList.add((double)binNum);
						binList.add((double)binCount);	
						out.println("binNum: "+binNum);
						out.println("binCount: "+binCount); 
						binCount = 0;
						binNum++;						
					}//else
				}//for
				out.println("binNum: "+binNum);
				out.println("binCount: "+binCount); 
		       
			//Convert binList to binArray (binNum, binCount)
			Double[] binArray = binList.toArray(new Double[binList.size()]);
	                         /*	
				//Write second section
				StringBuffer heading2 = new StringBuffer();	
				heading2.append("binNum"); heading2.append("\t"); heading2.append("binCount"); heading2.append("\n");
				String outHeading2 = heading2.toString();
				bw.write(outHeading2); 	
				
				StringBuffer result2 = new StringBuffer();
				for (int j = 0; j < binArray.length  ; j+=2){
						result2.append(binArray[j]); result2.append("\t");						
						result2.append(binArray[j+1]); result2.append("\n");						
				}//for
				String outline2 = result2.toString();
				bw.write(outline2);			
				*/	
			
				//Write second section
				StringBuffer heading2 = new StringBuffer();	
				heading2.append("Delta_t"); heading2.append("\n"); 
				String outHeading2 = heading2.toString();
				bw.write(outHeading2); 	
				
				StringBuffer result2 = new StringBuffer();
				for (int j = 0; j < delta_tArray.length  ; j++){
						result2.append(delta_tArray[j]);  result2.append("\n");						
				}//for
				String outline2 = result2.toString();
				bw.write(outline2);			
				
				//request.setAttribute("dst2", dst2);	
				//request.setAttribute("dst2b", dst2b);	
	        	br.close();
	        	bw.close();
	        	//bw2.close();
        		
        		
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
    			/*
    			String phrase2 = dst2b;
                String[] tokens = phrase2.split("/");
                String dst2bv2 = dst2v2;
                */
                
                //concatenate last element	 
                //dst2bv2 = dst2v2 + tokens[tokens.length - 1];//this should happen first		               	
    			dst2v2 = dst2v2 + tokensArray2[tokensArray2.length-1];
    			
    			
    			//add http:// to start
                dst2v2 = "http://" + request.getServerName() + dst2v2;
                //dst2bv2 = "http://" + request.getServerName() + dst2bv2;
                
				request.setAttribute("dst2v2", dst2v2);					
				//request.setAttribute("dst2bv2", dst2bv2);	
				
				
    		}//try
    		catch(Exception e){
        		out.println("Exception caught : " + e);
    		}//catch
    	}//if-file2 exists
    	else{
    		out.println("eventCandidates file did not copy over to plots/ from scratch/!");
    	}//else
	%>
			<a href = "${dst2v2}">Download delta-t!</a>
			<%--<a href = "${dst2bv2}">Download delta-tRate!</a>--%>
			<%--Server host name is: <b><%=request.getServerName() %></b>--%>
	
	</body>
</html>

