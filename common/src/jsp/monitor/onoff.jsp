<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<%@ page contentType="image/svg+xml; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<svg version="1.1" baseProfile="full" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" id="svg-root" width="50" height="70">
	<g>
		<rect x="0" y="0" rx="0" ry="0" width="100%" height="100%" fill="white"/>
		<c:choose>
			<c:when test="${param.disabled}">
				<c:set var="ct" value="rgb(128,148,110)"/>
				<c:set var="cft" value="rgb(110,110,110)"/>
				<c:set var="cf" value="rgb(148,128,110)"/>
				<c:set var="cff" value="rgb(110,110,110)"/>
			</c:when>
			<c:when test="${param.value}">
				<c:set var="ct" value="rgb(140,255,80)"/>
				<c:set var="cft" value="rgb(20,20,20)"/>
				<c:set var="cf" value="rgb(148,128,110)"/>
				<c:set var="cff" value="rgb(110,110,110)"/>
			</c:when>
			<c:otherwise>
				<c:set var="ct" value="rgb(128,148,110)"/>
				<c:set var="cft" value="rgb(110,110,110)"/>
				<c:set var="cf" value="rgb(255,120,70)"/>
				<c:set var="cff" value="rgb(20,20,20)"/>
			</c:otherwise>
		</c:choose>
		<rect x="1" y="6" rx="1" ry="1" width="48" height="28" stroke="rgb(30,30,30)" stroke-width="2" fill="${ct}"/>
		<rect x="1" y="38" rx="1" ry="1" width="48" height="28" stroke="rgb(30,30,30)" stroke-width="2" fill="${cf}"/>
		<text  x="49%" y="25" fill="${cft}" font-size="12" text-anchor="middle">OK</text>
		<text  x="49%" y="57" fill="${cff}" font-size="12" text-anchor="middle">Failed</text>
	</g>
</svg>

