<%@ page errorPage="../include/errorpage.jsp" buffer="none" %>
<%@ page import="java.util.*" %>
<%@ page import="java.io.*" %>
<%@ page import="gov.fnal.elab.*" %>
<%@ page import="gov.fnal.elab.analysis.*" %>
<%@ page import="gov.fnal.elab.analysis.impl.swift.*" %>
<%@ page import="java.text.*" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ include file="../include/elab.jsp" %>
<%@ include file="../login/admin-login-required.jsp" %>

<%
	List<Map<String, Object>> l = (List<Map<String, Object>>) session.getAttribute("l");
	if (l == null) {
		throw new ElabJspException("no analysis list");
	}
	
	List<String> urls = new ArrayList<String>();
	List<Integer> delays = new ArrayList<Integer>();
	
	for (Map<String, Object> a : l) {
		StringBuilder sb = new StringBuilder();
		sb.append("../analysis-");
		sb.append(a.get("shortType"));
		sb.append("/analysis.jsp?rawData=");
		
		List<String> lfns = (List<String>) a.get("files");
		for (String lfn : lfns) {
			sb.append(lfn);
			sb.append("&");
		}
		sb.append("runMode=");
		sb.append(a.get("mode"));
		sb.append("&submit=Analyze");
		urls.add(sb.toString());
		delays.add((Integer) a.get("cDelay"));
	}
	
	request.setAttribute("urls", urls);
	request.setAttribute("delays", delays);
%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
		<title>Analysis Generator - Starter</title>
		<link rel="stylesheet" type="text/css" href="../css/style2.css"/>
		<link rel="stylesheet" type="text/css" href="../css/data.css"/>
		<link rel="stylesheet" type="text/css" href="../css/one-column.css"/>
		<link type="text/css" href="../include/jquery/css/blue/jquery-ui-1.7.2.custom.css" rel="Stylesheet" />	
		<script type="text/javascript" src="../include/jquery/js/jquery-1.6.1.min.js"></script>
		<script type="text/javascript" src="../include/jquery/js/jquery-ui-1.7.3.custom.min.js"></script>
		<script type="text/javascript" src="../include/elab.js"></script>
		<style>
			.panel {padding: 16px;}
			.panel {background-color: #e0e0e0; vertical-align: top;}
			#form th {background-color: #c0c0c0;}
			.help-item {display: none;}
			#list td.numeric {text-align: right;}
			#list td {padding-left: 4px; padding-right: 4px; background-color: #e0e0e0;}
			#list th {background-color: #c0c0c0;}
			.title {background-color: #63A2DB; font-size: 14pt; font-weight: bold; padding: 4px; margin-bottom: 10px; margin-top: 32px;}
		</style>
	</head>
	<body id="analysis-list" class="data">
		<!-- entire page container -->
		<script>
			var urls = new Array();
			var delays = new Array();
			<c:forEach var="url" items="${urls}">urls.push("${url}");
			</c:forEach>
			<c:forEach var="delay" items="${delays}">delays.push("${delay}");
			</c:forEach>
		</script>
		<div id="container">			
			<div id="content">
				<div class="title">Analysis generator - Starter</div>
				<%@ include file="tester-analysis-list.jspf" %>
				<div id="err">
				</div>	
			</div>
		</div>
		<script>
			var crt = 0;
			var time = 0;
			var table = document.getElementById("list");
						
			function setIcon(index, name, msg) {
				table.rows[index + 1].cells[6].innerHTML = '<img src="../graphics/' + name + '"/>';
				table.rows[index + 1].cells[6].setAttribute("error", msg);
			}
			
			function checkState(index, state, status, response) {
				if (state == 4) {
					if (status == 200) {
						setIcon(index, "Completed.png");
					}
					else {
						setIcon(index, "Failed.png", status + " - " + response);
					}
				}
			}
			
			function start(index) {
				var url = urls[index];
				setIcon(index, "busy5.gif");
				try {
					var req = new XMLHttpRequest();
					req.onreadystatechange = function() {
						checkState(index, this.readyState, this.status, this.responseText);
					};
					req.open("GET", url);
					req.send();
				}
				catch (err) {
					setIcon(index, "Failed.png", err);					
				}
			}
			
			function format(num) {
				if (num == Math.round(num)) {
					return num + ".0";
				}
				else {
					return num;
				}
			}
			
			function update() {
				if (crt >= delays.length) {
					return;
				}
				while (delays[crt] < time) {
					start(crt);
					crt++;
				}
				table.rows[crt + 1].cells[6].innerHTML = format((time - delays[crt]) / 10);
				table.rows[0].cells[6].innerHTML = format(time / 10); 
			}
			
			function ticker() {
				time = time + 1;
				update();
				setTimeout(ticker, 100);
			}
			
			setTimeout(ticker, 100);
			
			for (var i = 0; i < table.rows.length; i++) {
				table.rows[i].insertCell(6);
				table.rows[i].cells[6].className = "status";
				table.rows[i].cells[6].style.width = "36px";
				table.rows[i].cells[6].style.textAlign = "right"
				table.rows[i].cells[6].innerHTML = "&nbsp;";
			}
			
			$(".status").hover(
				function() {
					if ($(this).attr("error") != null) {
						$("#err").html($(this).attr("error"));
					}
				},
				
				function() {
					$("#err").html("");
				}
			);
			
		</script>
	</body>
</html>