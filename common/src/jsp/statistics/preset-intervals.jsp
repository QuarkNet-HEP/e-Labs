<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:useBean id="years" class="gov.fnal.elab.statistics.YearList"/>
<jsp:useBean id="months" class="gov.fnal.elab.statistics.MonthList"/>
<jsp:setProperty name="months" property="crtyear" value="${param.crtyear}"/>

<table border="0">
	<tr>
		<td>
			<c:forEach var="yr" items="${years.items}">
				<a class="${yr.value == param.crtyear ? 'silink' : 'ilink'}" 
					href="?${yr.params}&crtyear=${yr.value}${param.extra}">${yr.value}</a>
			</c:forEach>
		</td>
		
	</tr>
	<tr>
		<td>
			<c:forEach var="mo" items="${months.items}">
				<a class="${mo.value == param.crtmo ? 'silink' : 'ilink'}" 
					href="?${mo.params}&crtyear=${param.crtyear}&crtmo=${mo.value}${param.extra}">${mo.value}</a>
			</c:forEach>
		</td>
	</tr>
</table>