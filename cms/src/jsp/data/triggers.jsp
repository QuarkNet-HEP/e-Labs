<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="../include/elab.jsp" %>
<%@ page import="gov.fnal.elab.cms.dataset.*" %>

<script type="text/javascript" src="../data/triggers.js"></script>
<table id="triggers">
	<tr>
		<td>
			<table id="inclexcl">
				<tr>
					<td id="incl">
						<h3>Include</h3>
						<table class="trigger-container" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<table class="trigger-expression" id="incltable" border="0" 
										cellpadding="0" cellspacing="0">
										<tr>
										</tr>
									</table>
								</td>
								<td>
									<a class="tbutton ortrigger" id="triggerincl" href="#">
										<img class="buttonicon" src="../graphics/plus.png" />
									</a>
								</td>
							</tr>
							<tr>
								<td colspan="2">
								</td>
							</tr>
						</table>
					</td>
					<td id="excl">
						<h3>Exclude</h3>
						<table class="trigger-container" border="0" cellpadding="0" cellspacing="0">
							<tr>
								<td>
									<table class="trigger-expression" id="excltable" border="0" 
										cellpadding="0" cellspacing="0">
										<tr>
										</tr>
									</table>
								</td>
								<td>
									<a class="tbutton ortrigger" id="triggerincl" href="#">
										<img class="buttonicon" src="../graphics/plus.png" />
									</a>
								</td>
							</tr>
							<tr>
								<td colspan="2">
								</td>
							</tr>
						</table>
					</td>
				</tr>
				<tr>
					<td colspan="2">
						<table border="0" id="exprtable">
							<tr>
								<td style="vertical-align: middle">
									Trigger&nbsp;expression:
								</td>
								<td width="100%">
									<input id="expr" name="expr" type="text" size="100" onchange="initializeFromExpr()" value="${param.expr}"/>
								</td>
								<td>
									<input id="clear" type="button" value="Clear" onclick="clearExpr();" />
								</td>
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%
	request.setAttribute("dataset", Datasets.getDataset(elab, session, request.getParameter("dataset")));
%>

<c:set var="lastgroup" value=""/>
<ul id="trigger-list" class="jeegoocontext cm_blue">
	<c:forEach var="trigger" items="${dataset.triggers}">
		<c:set var="name" value="${trigger.displayName}"/>
		<c:if test="${name == ''}">
			<c:set var="name" value="${trigger.name}"/>
		</c:if>
		<c:if test="${(trigger.group != lastgroup) and (lastgroup != '')}">
			<li class="separator"></li>
		</c:if>
		<li value="${trigger.id}">${name}</li>
		<c:set var="lastgroup" value="${trigger.group}"/>
	</c:forEach>
</ul>
<ul id="trigger-list-and" class="jeegoocontext cm_blue">
</ul>
<ul id="trigger-list-or" class="jeegoocontext cm_blue">
</ul>
<script>
	var list = document.getElementById("trigger-list");
	document.getElementById("trigger-list-and").innerHTML = "<li class=\"title\">... AND</li>" + list.innerHTML;
	document.getElementById("trigger-list-or").innerHTML = "<li class=\"title\">... OR</li>" + list.innerHTML;
</script>
<div id="trigger-template" class="template">
	<div value="" class="active-label"></div>
</div>
<div id="and-button-template" class="template">
	<a class="tshbutton andtrigger" id="triggerincl" href="#"><img class="buttonicon" src="../graphics/darrow.png" /></a>
</div>
<div id="ortable-template" class="template">
	<table class="ortable" border="0" cellspacing="0" cellpadding="0">
	</table>
</div>