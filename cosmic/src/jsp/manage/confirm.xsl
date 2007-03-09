<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" />
<xsl:template match="/">
	<html>
		<body>
            <h1><xsl:value-of select="elab/class/@name" /> updated successfully!</h1>
            <xsl:apply-templates select="elab/class" />
		</body>
	</html>
</xsl:template>
			
<xsl:template match="class">
    <a href="show.jsp?object={@name}&amp;id={attr/value[../@name='id']}">
        click to continue...
    </a>
</xsl:template>
</xsl:stylesheet>
