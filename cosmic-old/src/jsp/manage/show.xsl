<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" />
<xsl:template match="/">
	<html>
		<body>
            <h1><xsl:value-of select="elab/class/@name"/> Information</h1>
            <xsl:apply-templates select="elab/class" />
		</body>
	</html>
</xsl:template>
			
<xsl:template match="class">
    <a href="manage.jsp?object={@name}&amp;a=edit&amp;id={attr/value[../@name='id']}">
        manage this <xsl:value-of select="@name" /><br/>
    </a>
    <table>
        <xsl:for-each select="attr|relationship">
            <xsl:sort select="@name" />
            <tr>
                <td>
                    <xsl:value-of select="@display"/>: 
                </td>
                <td>
                    <xsl:choose>
                        <xsl:when test="@type = 'to_many'">
                            <xsl:for-each select="rel">
                                <xsl:sort select="." />
                                <a href="show.jsp?object={@class}&amp;id={@id}"><xsl:value-of select="." /></a> - 
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="@type = 'to_one'">
                            <a href="show.jsp?object={rel/@class}&amp;id={rel/@id}"><xsl:value-of select="rel" /></a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="value"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </td>
            </tr>
        </xsl:for-each>
    </table>
</xsl:template>
</xsl:stylesheet>
