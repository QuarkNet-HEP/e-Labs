<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.*" %>
<html>
	<head>
		<title>Quarknet Detector Calibration</title>
		<style>
body {
	font-family: sans, Verdana, Arial;
	font-size: 10pt;
}
tr.step td {
	font-size: 14pt;
	font-weight: bold;
	padding-top: 8px;
	padding-bottom: 8px;
}

div.detcmd {
	width: 100px;
	font-family: monospace;
	padding: 4px;
	background-color: #ffffff;
	border: thin solid black;
	margin: 8px;
}

div.explanation {
	font-size: 8pt;
	color: #808080; 
}

tr.prompt>td {
	border: solid thin #000080;
	background-color: #e0e0ff;
	padding: 8px;
	font-size: 9pt;
}

tr.prompt-done>td {
	border: solid thin #008000;
	background-color: #e0ffe0;
	padding: 8px;
	font-size: 9pt;
}

tr.reply-done>td {
	border: solid thin #808000;
	background-color: #ffffe0;
	padding: 8px;
	font-size: 9pt;
}


tr.error td {
	border: solid thin #ff0000;
	background-color: #ff8080;
	padding: 8px;
	font-size: 9pt;
}

tr.reply>td {
	border: solid thin #808000;
	background-color: #ffffe0;
	padding: 8px;
	font-size: 9pt;
}

tr.reply table {
	border: solid thin #e0e0c0;
}

tr.reply table td {
	border: solid thin #fffff0;
	font-size: 9pt;
	text-align: right;
}

tr.reply-done table {
	border: solid thin #e0e0c0;
}

tr.reply-done table td {
	border: solid thin #fffff0;
	font-size: 9pt;
	text-align: right;
}

.button {
	border: solid thin black;
}

tr.reply th {
	font-size: 9pt;
	background-color: #e0e0c0;
}

tr.reply-done th {
	font-size: 9pt;
	background-color: #e0e0c0;
}

tr.input>td {
	border: solid thin #800000;
	background-color: #ffe0e0;
	padding: 8px;
}

.ch {
	font-weight: bold;
}

.vlt {
	background-color: #fff0a0;
	font-weight: bold;	
}

.nop {
	background-color: #a0ffa0;
}

.graph0 {
	position: fixed;
	top: 16px;
	right: 16px;
}

.graph1 {
	position: fixed;
	top: 216px;
	right: 16px;
}

.graph2 {
	position: fixed;
	top: 416px;
	right: 16px;
}

.graph3 {
	position: fixed;
	top: 616px;
	right: 16px;
}

#main {
	padding-left: 16px;
}
		</style>
	</head>
	<body onLoad="javascript:window.scroll(0, document.body.scrollHeight);">
		<form>
			<table border="0" id="main">
<%
	String reply = request.getParameter("reply");
	String action = request.getParameter("action");
	String prompt = "";
	String error = null;
	String decodedReply = null;
	if ("Reset".equals(action)) {
		session.removeAttribute("calibration-log");
		session.removeAttribute("calibration-step");
		session.removeAttribute("calibration-substep");
		session.removeAttribute("calibration-datav");
		session.removeAttribute("calibration-datac");
		session.removeAttribute("calibration-data2");
		session.removeAttribute("calibration-reqv");
		session.removeAttribute("calibration-voltages");
	}
	List<Map<String, Object>> log = (List<Map<String, Object>>) session.getAttribute("calibration-log");
	if (log == null) {
	    log = new ArrayList<Map<String, Object>>();
	    session.setAttribute("calibration-log", log);
	}
	List<List<Double>> datav = (List<List<Double>>) session.getAttribute("calibration-datav");
	List<List<Integer>> datac = (List<List<Integer>>) session.getAttribute("calibration-datac");
	if (datav == null) {
	    datav = new ArrayList<List<Double>>();
	    datac = new ArrayList<List<Integer>>();
	    //for testing purposes
	    //datav.add(Arrays.asList(0.5, 0.5, 0.5, 0.5));datac.add(Arrays.asList(3, 4, 5, 2, 0));
	    //datav.add(Arrays.asList(0.6, 0.6, 0.6, 0.6));datac.add(Arrays.asList(9, 16, 25, 4, 1));
	    //datav.add(Arrays.asList(0.7, 0.7, 0.7, 0.7));datac.add(Arrays.asList(27, 64, 125, 8, 2));
	    //datav.add(Arrays.asList(0.8, 0.8, 0.8, 0.8));datac.add(Arrays.asList(81, 256, 625, 16, 3));
	    session.setAttribute("calibration-datav", datav);
	    session.setAttribute("calibration-datac", datac);
	}
	List<SortedMap<Double, Integer>> cdata = (List<SortedMap<Double, Integer>>) session.getAttribute("calibration-data2");
	if (cdata == null) {
	    cdata = new ArrayList<SortedMap<Double, Integer>>();
	    for (int i = 0; i < 4; i++) {
	        cdata.add(new TreeMap<Double, Integer>());
	    }
	    //cdata.get(0).put(0.5, 0);
	    //cdata.get(0).put(0.6, 1);
	    //cdata.get(0).put(0.7, 2);
	    //cdata.get(0).put(0.8, 3);
	    session.setAttribute("calibration-data2", cdata);
	}
	List<Double> calv = (List<Double>) session.getAttribute("calibration-voltages");
	if (calv == null) {
	    calv = Arrays.asList(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0);
	    session.setAttribute("calibration-voltages", calv);
	}
	double PERCENTAGE = .95;
	Integer step = (Integer) session.getAttribute("calibration-step");
	if (step == null) {
	    step = 0;
	}
	int MAX_COUNTS = 2000;
	double MIN_VOLTAGE = 0.56;
	double START_VOLTAGE = 0.56;
	double VOLTAGE_STEP_1 = 0.04;
	double VOLTAGE_STEP_2 = 0.02;
	int STEP_SETUP = 0;
	int STEP_MAXIMIZE_COUNTS = 1;
	int STEP_CALIBRATE_1 = 2;
	int STEP_CALIBRATE_2 = 3;
	int STEP_CALIBRATE_3 = 4;
	int STEP_CALIBRATE_4 = 5;
	int STEP_DONE = 6;
	int SUBSTEP_DONE = 1000;
	
	Integer substep = (Integer) session.getAttribute("calibration-substep");
	if (substep == null) {
	    substep = 0;
	}
	String[] STEP_TITLE = new String[] {"Detector setup", "Maximum Coincidence Count", 
	        "Channel 1 Calibration", "Channel 2 Calibration", "Channel 3 Calibration", 
	        "Channel 4 Calibration", "Done"};
	int[] STEPS = new int[] {2, SUBSTEP_DONE, SUBSTEP_DONE, SUBSTEP_DONE, SUBSTEP_DONE, SUBSTEP_DONE, 1};
	
	NumberFormat NF = new DecimalFormat("0.00");
	int initialSubstep = substep;
	boolean input = false;
	boolean table = false;
	try {
		if (step == STEP_SETUP) {
		    switch (substep) {
		        case 0:
		    		prompt = "Connect to the detector (using HyperTerminal or whatever your usual means)";
		    		substep++;
		    		break;
		        case 1:
		            prompt = "Consecutively send the following commands to the DAQ card:<br>" + 
		            			"<div class=\"detcmd\">CD</div>" + "<div class=\"explanation\">Disables event output</div><br />" + 
		            			"<div class=\"detcmd\">TL 4 100</div>" + "<div class=\"explanation\">Sets the discriminator threshold voltage to 100mv on all channels</div><br />" +
		            			"<div class=\"detcmd\">WC 00 3F</div>" + "<div class=\"explanation\">Sets 4-fold coincidence and all channels enabled</div><br />" +
		            			"<div class=\"detcmd\">ST 3 1</div>" + "<div class=\"explanation\">Enables periodic display of counters at 1 minute interval while resetting the counters each time</div><br />";
		            substep++;
		            break;
		    }
		}
		List<Integer> counts = Arrays.asList(0, 0, 0, 0, 0);
		List<Double> reqVoltages = (List<Double>) session.getAttribute("calibration-reqv");
		if (step >= STEP_MAXIMIZE_COUNTS && step <= STEP_CALIBRATE_4) {
		    if (substep == 0) {
		    	reply = "DS 00000000 00000000 0000000 00000000 00000000";   
		    }
		    else {
		        if (reply == null) {
		            input = true;
		            throw new IllegalArgumentException("Please type the output of the last DS line from the DAQ card");
		        }
		        String[] rs = reply.trim().split("\\s+");
		        if (rs.length != 6 || !rs[0].equals("DS")) {
		            input = true;
					throw new IllegalArgumentException("Invalid input. The status line should look like this: "
					+ "<span class=\"detout\">DS 00000010 0000002f 00000e0 000012aa 0000000c</span>");   
		        }
		        for (int i = 0; i < 5; i++) {
		            counts.set(i, Integer.parseInt(rs[i + 1], 16));
		        }
		    }
		}
		if (step == STEP_MAXIMIZE_COUNTS) {
		    table = true;
		    if (substep == 0) {
		        reqVoltages = Arrays.asList(START_VOLTAGE, START_VOLTAGE, START_VOLTAGE, START_VOLTAGE);
		        session.setAttribute("calibration-reqv", reqVoltages);
		    }
		    int done = 0;
		    String voltages = null;
		    if (substep != 0) {
		        datav.add(new ArrayList<Double>(reqVoltages));
		        datac.add(new ArrayList<Integer>(counts));
		    }
		    prompt = "<b>Adjust PMT voltages</b> as follows: <br />";
	    	for (int i = 0; i < 4; i++) {
	            prompt += "&nbsp;&nbsp;<span class=\"ch\">channel " + (i + 1) + "</span>: ";
	            if (counts.get(i) < MAX_COUNTS) {
	                reqVoltages.set(i, reqVoltages.get(i) + VOLTAGE_STEP_1);
	                prompt += "<span class=\"vlt\">" + NF.format(reqVoltages.get(i)) + " V</span>";
	                if (i != 3) {
	                    prompt += ", ";
	                }
	            }
	            else {
	                prompt += "<span class=\"nop\">leave unchanged (" + NF.format(reqVoltages.get(i)) + " V)</span>";
	                calv.set(i + 4, reqVoltages.get(i));
	                cdata.get(i).put(reqVoltages.get(i), counts.get(4));
	                cdata.get(i).put(MIN_VOLTAGE, 0);
	                done++;
	            }
	        }
	        if (done == 4) {
	            session.setAttribute("calibration-max-coincidence", counts.get(4));
	            substep = 0;
	            step = STEP_CALIBRATE_1;
	            prompt = "";
	        }
	        else {
	            prompt += "<br />After adjusting the voltages, reset the counters and timer by typing the following into the DAQ terminal: "+
	            		"<div class=\"detcmd\">ST</div>";
	            prompt += "Wait for one minute until the next ST line is printed and copy and paste it into the field below. " + 
	            		 "Then press <span class=\"button\">OK</span>";
	            input = true;
	        }
	        substep++;
		}
		if (step >= STEP_CALIBRATE_1 && step <= STEP_CALIBRATE_4) {
		    //out.write(step + ", " + substep + ", ");
		    int channel = step - STEP_CALIBRATE_1;
		    if (substep != 0) {
		        cdata.get(channel).put(reqVoltages.get(channel), counts.get(4));
		        datav.add(new ArrayList<Double>(reqVoltages));
		        datac.add(new ArrayList<Integer>(counts));
		    }
		    //out.write(cdata.get(channel).toString());
    		int max = (Integer) session.getAttribute("calibration-max-coincidence");
    		double target = PERCENTAGE * max;
			Iterator<Map.Entry<Double, Integer>> it = cdata.get(channel).entrySet().iterator();
			SortedMap<Double, Integer> filtered = new TreeMap<Double, Integer>();
			double lastVoltage = MIN_VOLTAGE;
			int lastCount = 0;
			while (it.hasNext()) {
			    Map.Entry<Double, Integer> e = it.next();
			    if (lastCount > e.getValue()) {
			        //we don't believe you
			        int mean = (lastCount + e.getValue()) / 2;
			        filtered.put(lastVoltage, mean);
			        filtered.put(e.getKey(), mean);
			    }
			    else {
			        filtered.put(e.getKey(), e.getValue());
			    }
			    lastVoltage = e.getKey();
			    lastCount = e.getValue();
			}
			//out.write(filtered.toString() + " - " + target);
			lastVoltage = MIN_VOLTAGE;
			lastCount = 0;
			it = filtered.entrySet().iterator();
			while (it.hasNext()) {
			    Map.Entry<Double, Integer> e = it.next();
			    if (lastCount < target && e.getValue() > target) {
			        if (e.getKey() - lastVoltage > VOLTAGE_STEP_2) {
			            double rv = (e.getKey() - lastVoltage) / 2 + lastVoltage;
			            rv = (double) Math.round(rv * 100) / 100;
			            //out.write("<br/>key: " + e.getKey() + ", lv: " + lastVoltage + ", rv: " + rv + "<br />");
			        	reqVoltages.set(channel, rv);
			        	prompt = "<b>Adjust PMT " + (channel + 1) + "</b> to " + 
			        		"<span class=\"vlt\">" + NF.format(reqVoltages.get(channel)) + " V</span>";
			        	prompt += "<br />After adjusting the voltage, reset the counters and timer by typing the following into the DAQ terminal: "+
	            			"<div class=\"detcmd\">ST</div>";
	            		prompt += "Wait for one minute until the next ST line is printed and copy and paste it into the field below. " + 
	            			"Then press <span class=\"button\">OK</span>";
			        	input = true;
			        	table = true;
			        }
			        else {
			 			calv.set(channel, e.getKey());
			 			prompt += "<b>Adjust PMT " + (channel + 1) + "</b> to " + 
			        		"<span class=\"vlt\">" + NF.format(calv.get(4 + channel)) + 
			        		" v</span> the press <span class=\"button\">OK</span>";
			        	step++;
			        	substep = 0;
			        }
			        break;
			    }
			    lastVoltage = e.getKey();
			    lastCount = e.getValue();
			    substep++;
			}
			if (step == STEP_DONE) {
			    prompt = "You are done!. The final voltages are as follows:<br />";
			    for (int i = 0; i < 4; i++) {
	            	prompt += "&nbsp;&nbsp;<span class=\"ch\">channel " + (i + 1) + "</span>: ";
	                prompt += "<span class=\"vlt\">" + NF.format(calv.get(i)) + " v</span>";
	                if (i != 3) {
	                    prompt += ", ";
	                }
	            }
			}
		}
	}
	catch (IllegalArgumentException e) {
	    error = e.getMessage();
	}
	
	Iterator<Map<String, Object>> i = log.iterator();
	int pstep = -1;
	while (i.hasNext()) {
	    Map<String, ?> m = i.next();
	    int lstep = (Integer) m.get("step");
	    if (pstep != lstep) {
	        if (lstep != step) {
	        	out.write("<tr class=\"step\"><td><span class=\"step\">" + STEP_TITLE[lstep] + "<img src=\"../graphics/Completed.png\" /></span></td></tr>\n");
	        }
	        else {
	            out.write("<tr class=\"step\"><td><span class=\"step\">" + STEP_TITLE[lstep] + "</span></td></tr>\n");
	        }
	        pstep = lstep;
	    }
	    String tprompt = (String) m.get("prompt");
	    if (error != null && !i.hasNext()) {
	    	out.write("<tr class=\"prompt\"><td><span class=\"prompt\">" + tprompt + "</span></td></tr>\n");
	    }
	}
	
	if (!log.isEmpty()) {
		Map<String, Object> lastm = log.get(log.size() - 1);
		lastm.put("reply", reply);
		lastm.put("decoded-reply", decodedReply);
	}
	
	if (error == null) {
	    Map<String, Object> m = new HashMap<String, Object>();
		m.put("step", step);
		m.put("prompt", prompt);
		m.put("error", error);
		log.add(m);
	}
	
	request.setAttribute("STEP_TITLE", STEP_TITLE);
	request.setAttribute("step", step);
	request.setAttribute("initialSubstep", initialSubstep);
	request.setAttribute("table", table);
	request.setAttribute("error", error);
	request.setAttribute("prompt", prompt);
	request.setAttribute("input", input);
	request.setAttribute("datav", datav);
	request.setAttribute("datac", datac);
	request.setAttribute("decodedReply", decodedReply);
%>
	
	<c:if test="${initialSubstep == 0}">
		<tr class="step"><td><span class="step">${STEP_TITLE[step]}</span></td></tr>
	</c:if>
	<c:if test="${table}">
		<tr class="reply">
			<td>
				<table border="0">
					<tr>
						<th>n</th><th>C1 v</th><th>C2 v</th><th>C3 v</th><th>C4 v</th>
						<th>C1 count</th><th>C2 count</th><th>C3 count</th><th>C4 count</th><th>Coinc. count</th></tr>
					<c:forEach items="${datav}" var="cd" varStatus="s">
						<tr>
							<th>${s.count}</th>
							<td><fmt:formatNumber pattern="0.00" value="${cd[0]}"/></td>
							<td><fmt:formatNumber pattern="0.00" value="${cd[1]}"/></td>
							<td><fmt:formatNumber pattern="0.00" value="${cd[2]}"/></td>
							<td><fmt:formatNumber pattern="0.00" value="${cd[3]}"/></td>
							<td>${datac[s.count - 1][0]}</td>
							<td>${datac[s.count - 1][1]}</td>
							<td>${datac[s.count - 1][2]}</td>
							<td>${datac[s.count - 1][3]}</td>
							<td>${datac[s.count - 1][4]}</td>
						</tr>
					</c:forEach>
				</table>
				<c:if test="${decodedReply != null}">
					$decodedReply
				</c:if>
			</td>
		</tr>
	</c:if>
	<c:choose>
		<c:when test="${error == null}">
			<tr class="prompt"><td><span class="prompt">${prompt}</span></td></tr>
		</c:when>
		<c:otherwise>
			<tr class="error"><td><span class="error">${error}</span></td></tr>
		</c:otherwise>
	</c:choose>
	<tr class="prompt"><td>
		<table width="100%">
			<tr>
				<td align="left">
				</td>
				<td align="right">
					<c:if test="${input}">
						<input type="text" size="40" name="reply" tabindex="0"/>&nbsp;
					</c:if>
					<input type="submit" class="button" name="action" value="OK" tabindex="1"/>
					<input type="submit" class="button" name="action" value="Reset" tabindex="100"/>
				</td>
			</tr>
		</table>
	</td></tr>
	<c:forEach items="0,1,2,3" var="i">
		<a href="../geometry/graph-data.jsp?index=${i}&large=yes">
			<img style="border:none" class="graph${i}" src="../geometry/graph-data.jsp?index=${i}" />
		</a>
	</c:forEach>
<%	
	
	if (substep >= STEPS[step]) {
	    step++;
	    substep = 0;
	}
	session.setAttribute("calibration-step", step);
	session.setAttribute("calibration-substep", substep);
%>
			</table>
		</form>
	</body>
</html>