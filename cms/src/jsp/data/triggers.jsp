<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="x" uri="http://java.sun.com/jsp/jstl/xml" %>

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
							</tr>
						</table>
					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<jsp:include page="../data/dataset-info.jsp">
	<jsp:param name="dataset" value="${param.dataset}"/>
</jsp:include>

<c:set var="lastgroup" value=""/>
<ul id="trigger-list" class="jeegoocontext cm_blue">
	<x:forEach var="trigger" select="$currentDataset/root/triggers/trigger">
		<x:set var="id" select="string($trigger/@id)"/>
		<x:set var="name" select="string($trigger/@displayname)"/>
		<x:set var="desc" select="string($trigger/@description)"/>
		<x:set var="group" select="string($trigger/@group)"/>
		<x:set var="fake" select="string($trigger/@fake)"/>
		<c:if test="${fake != 'true'}">
			<c:if test="${name == ''}">
				<x:set var="name" select="string($trigger/@name)"/>
			</c:if>
			<c:if test="${(group != lastgroup) and (lastgroup != '')}">
				<li class="separator"></li>
			</c:if>
			<li value="${id}">${name}</li>
			<c:set var="lastgroup" value="${group}"/>
		</c:if>
	</x:forEach>
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