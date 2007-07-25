<?xml version="1.0"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:template match="/">
 <xsl:for-each select="/file">
    <!--
   <tr>
    <td align="center">
     <xsl:value-of select="filename"/>
    </td>
    -->
    <td align="center">
     <xsl:value-of select="events"/>
    </td>
    <td align="center">
     <xsl:value-of select="gatewidth"/> ns
    </td>
    <td align="center">
     <xsl:value-of select="average"/>
    </td>
    <td align="center">
     <xsl:value-of select="gps/good/byevent/percent"/>%
    </td>
    <td align="center">
     <xsl:value-of select="gps/bad/byevent/percent"/>%
    </td>
    <td align="center">
     <xsl:value-of select="gps/noupdate/percent"/>%
    </td>
  </xsl:for-each>
</xsl:template>
</xsl:stylesheet>
