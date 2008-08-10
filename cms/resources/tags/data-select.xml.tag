<%@ tag language="java" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/xtags-1.0" prefix="xtags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="uri" value="${elab.properties.xmlfile}"/>
<xtags:variable id="ds"  select="${elab.properties.dataset}"/>


<xtags:parse uri="${uri}"/>
<xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
		<xtags:forEach select="runs/type">
			<xtags:variable id="beam" select="@beam"/>
			<input type="checkbox" name="${beam}_runs" 
		  		onClick="javascript:select_${beam}(this.checked);">&nbsp; ${beam}><BR>
		</xtags:forEach>
	</xtags:if>
</xtags:forEach>

<input type="checkbox" name="all_runs" onClick="javascript:select_all(this.checked);" > &nbsp;All
<td>
	<!-- Access the XML file and generate a list of available runs -->
	<select name="run_number" multiple="true" size="5" onChange="javascript:select_single_run();">
	
		<xtags:forEach select="/root/dataset">
			<xtags:if test="@name=$ds">
				<xtags:forEach select="file">
					<xtags:if test="@runtype!='NULL'">
						<xtags:variable id="run" select="@run"/>
						<option value="${run}">Run ${run}
					</xtags:if>
				</xtags:forEach> <!-- end select=runs/type -->
			</xtags:if>
		</xtags:forEach> <!-- end select=/root/dataset -->
	</select>
</td>
