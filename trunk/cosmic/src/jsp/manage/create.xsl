<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" />
<xsl:template match="/">
	<html>
		<body>
            <h1>Create new <xsl:value-of select="elab/class/@name"/></h1>
            <xsl:apply-templates select="elab/class" />
		</body>
	</html>
</xsl:template>
			
<xsl:template match="class">
    <form method="post" action="manage.jsp">
        <table>
            <xsl:for-each select="attr|relationship">
                <xsl:sort select="@name" />
                <xsl:if test="@name != 'id'">
                    <tr>
                        <td>
                            <xsl:value-of select="@display"/>: 
                        </td>
                        <td>
                            <xsl:choose>
                                <xsl:when test="type = 'boolean'">
                                    <select name="{@name}">
                                        <option value="true">yes</option>
                                        <option value="false">no</option>
                                    </select>
                                </xsl:when>
                                <xsl:otherwise>
                                    <input name="{@name}" type="text" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
        <input type="submit" name="submit" value="Submit" />
        <input type="hidden" name="object" value="{@name}" />
        <input type="hidden" name="a" value="new" />
    </form>
</xsl:template>
</xsl:stylesheet>
