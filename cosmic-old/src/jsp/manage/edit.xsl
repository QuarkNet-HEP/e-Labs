<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" />
<xsl:template match="/">
	<html>
		<body>
            <h1>Edit this <xsl:value-of select="elab/class/@name"/></h1>
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
                                        <xsl:choose>
                                            <xsl:when test="value='true'">
                                                <option value="true" selected="selected">yes</option>
                                                <option value="false">no</option>
                                            </xsl:when>
                                            <xsl:when test="value='false'">
                                                <option value="true">yes</option>
                                                <option value="false" selected="selected">no</option>
                                            </xsl:when>
                                        </xsl:choose>
                                    </select>
                                </xsl:when>
                                <xsl:otherwise>
                                    <input name="{@name}" type="text" value="{value}" />
                                </xsl:otherwise>
                            </xsl:choose>
                        </td>
                    </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
        <input type="submit" name="submit" value="Submit" />
        <input type="hidden" name="object" value="{@name}" />
        <input type="hidden" name="a" value="edit" />
        <input type="hidden" name="id" value="{attr/value[../@name='id']}" />
    </form>
</xsl:template>
</xsl:stylesheet>
