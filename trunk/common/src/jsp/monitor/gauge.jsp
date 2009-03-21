<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<%@ page contentType="image/svg+xml; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%@ include file="gauge-indicator.jspf" %>
<%
	request.setAttribute("c", coords(request.getParameter("value"), 50, false));
%>

<svg version="1.1" baseProfile="full" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="svg-root" width="160" height="70">
	<g transform="scale(0.80)">
		<c:choose>
			<c:when test="${param.disabled}">
				<image id="image1PNG" x="0" y="0" width="200" height="93" xlink:href="gauge-bg-disabled.png"/>
			</c:when>
			<c:otherwise>
				<image id="image1PNG" x="0" y="0" width="200" height="93" xlink:href="gauge-bg.png"/>
				<line x1="${c[0]}" y1="${c[1]}" x2="${c[2]}" y2="${c[3]}" style="stroke:rgb(50,50,50);stroke-width:3"/>
			</c:otherwise>
		</c:choose>
	</g>
</svg>

