<%@ tag language="java"%>
<%@ taglib uri="http://jakarta.apache.org/taglibs/xtags-1.0" prefix="xtags"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="e" uri="http://www.i2u2.org/jsp/elabtl" %>

<table>
	<xtags:parse uri="../xml/tb_data.xml" />
	<xtags:forEach select="/root/tree/branch/leaf">
	
		<xtags:variable id="title" select="@title" />
		<xtags:variable id="id" select="@id" />
		<xtags:variable id="name" select="@name" />
	
		<tr>
			<td>
				<e:trinput type="checkbox" name="leaf" value="${id}"/>&nbsp;${title}
				<e:trinput type="hidden" name="root_leaf" value="${name}"/>
			</td>
	
			<td>
				<e:trselect name="cuttype" valueList="0, 1, 2" labelList="None, <, >"/>
				<e:trinput type="text" name="cut" size="5" maxlength="5" id="0" onBlur="javascript:isNumeric(this);"/>
			</td>
		
			<td align="center">
				<e:trselect name="color"
					valueList="0, 1, 2, 3, 4, 5, 6"
					labelList="None, Black, Red, Green, Blue, Yellow, Purple"/>			
			</td>
		</tr>
	</xtags:forEach>
	
	<xtags:forEach select="/root/tree/formula">
		<xtags:variable id="title" select="@title" />
		<xtags:variable id="id" select="@id" />
	
		<tr>
			<td>
				<e:trinput type="checkbox" name="formula" value="${id}"/>&nbsp;${title}
				<e:trinput type="text" name="cutf" size="32"/>
			<td>
			<td align="center">
				<e:trselect name="colorf"
					valueList="0, 1, 2, 3, 4, 5, 6"
					labelList="None, Black, Red, Green, Blue, Yellow, Purple"/>
			</td>
		</tr>
	</xtags:forEach>
	
	<tr>
		<td>
			Data Access:
			<c:choose>
				<c:when test="${usedb}">
<input type="radio" name="access" value="0" checked="true" onChange="javascript:changeCookie(1);"> SQL
<input type="radio" name="access" value="1" onChange="javascript:changeCookie(0);">XML
				</c:when>
				<c:otherwise>
<input type="radio" name="access" value="0" onChange="javascript:changeCookie(1);">SQL
<input type="radio" name="access" value=1 checked onChange="javascript:changeCookie(0);">XML
				</c:otherwise>
			</c:choose>
		</td>
		<td align="center">
			<e:trinput type="checkbox" name="savedata" value="1"/> Save Raw Data
		</td>
		<td align="center">
			<e:trinput type="checkbox" name="logx" value="1"/>logx
			<e:trinput type="checkbox" name="logy" value="1"/>logy
		</td>
	</tr>
</table>
