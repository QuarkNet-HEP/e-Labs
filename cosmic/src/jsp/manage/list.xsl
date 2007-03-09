<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" />
<xsl:template match="/">
	<html>
		<body>
            <h1><xsl:value-of select="elab/class/@name"/> List</h1>
			<xsl:apply-templates select="elab" />
		</body>
	</html>
</xsl:template>
			
<xsl:template match="elab">
	list total: <xsl:value-of select="count(class)" />
	<table border="1">
		<xsl:for-each select="class">
			<xsl:sort select="count(attr)" order="descending" />
			<xsl:if test="position() = 1">
				<!-- output a table header -->
				<tr>
					<xsl:for-each select="attr">
						<xsl:sort select="@name" />
						<td align="center">
							<xsl:value-of select="@display"/>: 
						</td>
					</xsl:for-each>
				</tr>
			</xsl:if>
            <tr onmouseover="this.style.background='lightgreen';this.style.cursor='pointer'"
                onmouseout="this.style.background='white';" onclick="location.href='show.jsp?object={/elab/class/@name}&amp;id={attr/value[../@name='id']}'">
				<xsl:for-each select="attr">
					<xsl:sort select="@name" />
					<td align="center">
						<xsl:if test="(position() mod 2) = 0">
							<xsl:attribute name="style">
                                <!-- <xsl:text>background-color: #ffeeff</xsl:text> -->
							</xsl:attribute>
						</xsl:if>
						<!-- <xsl:value-of select="@name"/> -->
						<!-- <xsl:value-of select="type"/> -->
						<xsl:value-of select="value"/>
					</td>
				</xsl:for-each>
			</tr>
		</xsl:for-each>
	</table>
</xsl:template>
</xsl:stylesheet>
