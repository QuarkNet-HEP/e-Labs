<%@ tag language="java" %>
<%@ tag import="gov.fnal.elab.Elab" %>
<%@ taglib uri="http://jakarta.apache.org/taglibs/xtags-1.0" prefix="xtags" %>

<% System.out.println("getrundataxml"); %>
<xtags:variable id="uri" select="${elab.attributes['xmlFile']}"/>
<xtags:variable id="ds"  select="${elab.attributes['dataset']}"/>

<!-- Put up the table header -->
<tr align="center" valign="baseline">
	<% String [] fieldHeaders = new String[12]; int counter = 0; %>

	<!------ Get field Headers Here -------->
	<xtags:parse uri="<%= uri %>"/>
	<xtags:forEach select="/root/dataset">
		<xtags:if test="@name=$ds">
			<xtags:forEach select="database/field">
				<xtags:variable id="header" select="@name"/>

				<% fieldHeaders[counter++] = header; %>
				<td><FONT color="blue"><H4><%=header%></H4></FONT></td>

			</xtags:forEach> <!-- End xtags:forEach select="database/field" -->
		</xtags:if>        <!-- End xtags:if test="@name='tb05'" -->
	</xtags:forEach>     <!-- End xtags:forEach select="/root/dataset" -->

</tr>

<xtags:forEach select="/root/dataset">
	<xtags:if test="@name=$ds">
		<%
			if (request.getQueryString() != null) {
				String [] run_numbers = request.getParameter("run").split(",");
				int i = 0;
				%>
				<xtags:forEach select="file">
					<xtags:variable id="run_number" select="@run" />
					<%
						while (i < run_numbers.length) {
							if (run_number.equalsIgnoreCase(run_numbers[i])) {
								%>
									<tr>
										<td><xtags:valueOf select="@run"      /></td>
										<td><xtags:valueOf select="@nevents"  /></td>
										<td><xtags:valueOf select="@dataset"  /></td>
										<td><xtags:valueOf select="@filename" /></td>
										<td><xtags:valueOf select="@energy"   /></td>
										<td><xtags:valueOf select="@beam"     /></td>
										<td><xtags:valueOf select="@runtype"  /></td>
										<td><xtags:valueOf select="@eta"      /></td>
										<td><xtags:valueOf select="@phi"      /></td>
										<td><xtags:valueOf select="@date"     /></td>
										<td><xtags:valueOf select="@time"     /></td>
									</tr>
								<%
							}
							i++;
						} // End While ( i < run_numbers.length )
						i = 0;
					%>
				</xtags:forEach> <!-- End xtags:forEach select="file" -->
				<%
			} // End if (request.getQueryString() != null ) 
		%>
	</xtags:if>        <!-- End xtags:if test="@name='tb05'" -->
</xtags:forEach>       <!-- End xtags:forEach select="/root/dataset/file" -->
