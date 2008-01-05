<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<%@ page contentType="image/svg+xml; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.util.*" %>

<%@ include file="gauge-indicator.jspf" %>
<%
	request.setAttribute("c", coords(request.getParameter("value1"), 50, true));
	request.setAttribute("d", coords(request.getParameter("value2"), 40, true));
	request.setAttribute("e", coords(request.getParameter("value3"), 30, true));
%>

<svg version="1.1" baseProfile="full" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="svg-root" width="160" height="70">
	<g transform="scale(0.8)">
		<c:choose>
			<c:when test="${param.disabled}">
				<image id="image1PNG" x="0" y="0" width="200" height="93" xlink:href="gauge-log-bg-disabled.png"/>
			</c:when>
			<c:otherwise>
				<image id="image1PNG" x="0" y="0" width="200" height="93" xlink:href="gauge-log-bg.png"/>
				<line x1="${e[0]}" y1="${e[1]}" x2="${e[2]}" y2="${e[3]}" style="stroke:rgb(50,50,150);stroke-width:5"/>
				<line x1="${d[0]}" y1="${d[1]}" x2="${d[2]}" y2="${d[3]}" style="stroke:rgb(50,150,50);stroke-width:3"/>
				<line x1="${c[0]}" y1="${c[1]}" x2="${c[2]}" y2="${c[3]}" style="stroke:rgb(150,0,50);stroke-width:1"/>
			</c:otherwise>
		</c:choose>
	</g>
</svg>

