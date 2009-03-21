<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:datetime="http://exslt.org/dates-and-times"	
	version="1.0">
<xsl:output method="html" indent="yes" encoding="US-ASCII" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" />

<xsl:template match="testResults">
	<html>
		<head>
			<title>I2U2 Cosmic Test Results</title>
			<style type="text/css">
				body {
					font:normal 68%;
					color:#000000;
				}
				table tr td, table tr th {
					font-size: 68%;
				}
				table.details tr th{
					font-weight: bold;
					text-align:left;
					background:#b0b0b0;
					white-space: nowrap;
				}
				table.details tr td{
					background:#eeeee0;
					white-space: nowrap;
				}
				h1 {
					margin: 0px 0px 5px; font: 165% verdana,arial,helvetica
				}
				h2 {
					margin-top: 1em; margin-bottom: 0.5em; font: bold 125% verdana,arial,helvetica
				}
				h3 {
					margin-bottom: 0.5em; font: bold 115% verdana,arial,helvetica
				}
				.Failure {
					color:red;
				}
			</style>
		</head>
		<body>
		
			<xsl:call-template name="pageHeader" />
			
			<xsl:call-template name="summary" />
			<hr size="1" width="98%" align="left" />
			
			<xsl:call-template name="pagelist" />
			<hr size="1" width="98%" align="left" />
			
			<!--<xsl:call-template name="detail" />-->

		</body>
	</html>
</xsl:template>

<xsl:template name="pageHeader">
	<h1>Load Test Results</h1>
	<table width="100%">
		<tr>
			<td align="left"></td>
			<td align="right"></td>
		</tr>
	</table>
	<p>Page generated on <xsl:value-of select="datetime:dateTime()"/></p>
	<hr size="1" />
</xsl:template>

<xsl:template name="summary">
	<h2>Summary</h2>
	<table class="details" border="0" cellpadding="2" cellspacing="2" width="98%">
		<tr valign="top">
			<th>Tests</th>
			<th>Failures</th>
			<th>Success Rate</th>
			<th>Average Time</th>
			<th>Min Time</th>
			<th>Max Time</th>
		</tr>
		<tr valign="top">
			<xsl:variable name="allCount" select="count(/testResults/httpSample)" />
			<xsl:variable name="allFailureCount" select="count(/testResults/httpSample[attribute::s='false'])" />
			<xsl:variable name="allSuccessCount" select="count(/testResults/httpSample[attribute::s='true'])" />
			<xsl:variable name="allSuccessPercent" select="$allSuccessCount div $allCount" />
			<xsl:variable name="allTotalTime" select="sum(/testResults/httpSample/@t)" />
			<xsl:variable name="allAverageTime" select="$allTotalTime div $allCount" />
			<xsl:variable name="allMinTime">
				<xsl:call-template name="min">
					<xsl:with-param name="nodes" select="/testResults/httpSample/@t" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:variable name="allMaxTime">
				<xsl:call-template name="max">
					<xsl:with-param name="nodes" select="/testResults/httpSample/@t" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:attribute name="class">
				<xsl:choose>
					<xsl:when test="$allFailureCount &gt; 0">Failure</xsl:when>
				</xsl:choose>
			</xsl:attribute>
			<td>
				<xsl:value-of select="$allCount" />
			</td>
			<td>
				<xsl:value-of select="$allFailureCount" />
			</td>
			<td>
				<xsl:call-template name="display-percent">
					<xsl:with-param name="value" select="$allSuccessPercent" />
				</xsl:call-template>
			</td>
			<td>
				<xsl:call-template name="display-time">
					<xsl:with-param name="value" select="$allAverageTime" />
				</xsl:call-template>
			</td>
			<td>
				<xsl:call-template name="display-time">
					<xsl:with-param name="value" select="$allMinTime" />
				</xsl:call-template>
			</td>
			<td>
				<xsl:call-template name="display-time">
					<xsl:with-param name="value" select="$allMaxTime" />
				</xsl:call-template>
			</td>
		</tr>
	</table>
</xsl:template>

<xsl:template name="pagelist">
	<h2>Pages</h2>
	<table class="details" border="0" cellpadding="2" cellspacing="2" width="98%">
		<tr valign="top">
			<th>Test Name</th>
			<th>Step</th>
			<th>Time</th>
			<th>Status</th>
			<th>Error Message</th>
			<th>URL</th>
		</tr>
		<xsl:for-each select="/testResults/httpSample">
			<xsl:variable name="tn" select="@tn"/>
			<xsl:variable name="label" select="@lb"/>
			<xsl:variable name="failed" select="current()[attribute::s='false']"/>
			<xsl:variable name="failuremsg" select="current()/assertionResult/failureMessage/text()"/>
			<xsl:variable name="errormsg" select="@rm"/>
			<xsl:variable name="totalTime" select="@t"/>
			<xsl:variable name="url" select="url/text()"/>
			<tr valign="top">
				<xsl:attribute name="class">
					<xsl:choose>
						<xsl:when test="$failed">Failure</xsl:when>
					</xsl:choose>
				</xsl:attribute>
				<td>
					<xsl:choose>
						<xsl:when test="not(preceding-sibling::*[1]/@tn = current()/@tn)">
							<strong>
								<xsl:value-of select="$tn"/>
							</strong>
						</xsl:when>
					</xsl:choose>
				</td>
				<td>
					<xsl:value-of select="$label"/>
				</td>
				<td>
					<xsl:call-template name="display-time">
						<xsl:with-param name="value" select="$totalTime" />
					</xsl:call-template>
				</td>
				<td>
					<xsl:choose>
						<xsl:when test="$failed">Failed</xsl:when>
						<xsl:otherwise>OK</xsl:otherwise>
					</xsl:choose>
				</td>
				<td>
					<xsl:value-of select="$failuremsg"/>
					<!--<br />
					<xsl:value-of select="$errormsg"/>-->
				</td>
				<td>
					<a>
						<xsl:attribute name="href">
							<xsl:value-of select="$url"/>
						</xsl:attribute>
						<xsl:choose>
							<xsl:when test="string-length($url) > 50">
								<xsl:value-of select="concat(substring($url, 0, 50), '...')"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$url"/>
							</xsl:otherwise>
						</xsl:choose>
					</a>
				</td>
			</tr>
		</xsl:for-each>
	</table>
</xsl:template>

<xsl:template name="detail">
	<xsl:variable name="allFailureCount" select="count(/testResults/httpSample[attribute::s='false'])" />

	<xsl:if test="$allFailureCount > 0">
		<h2>Failure Detail</h2>

		<xsl:for-each select="/testResults/httpSample[not(@lb = preceding::*/@lb)]">

			<xsl:variable name="failureCount" select="count(../httpSample[@lb = current()/@lb][attribute::s='false'])" />

			<xsl:if test="$failureCount > 0">
				<h3><xsl:value-of select="@lb" /></h3>

				<table class="details" border="0" cellpadding="5" cellspacing="2" width="95%">
				<tr valign="top">
					<th>Response</th>
					<th>Failure Message</th>
				</tr>
			
				<xsl:for-each select="/testResults/httpSample[@lb = current()/@lb][attribute::s='false']">
					<tr>
						<td><xsl:value-of select="@responseCode" /> - <xsl:value-of select="@responseMessage" /></td>
						<td><xsl:value-of select="assertionResult/@failureMessage" /></td>
					</tr>
				</xsl:for-each>
				
				</table>
			</xsl:if>

		</xsl:for-each>
	</xsl:if>
</xsl:template>

<xsl:template name="min">
	<xsl:param name="nodes" select="/.." />
	<xsl:choose>
		<xsl:when test="not($nodes)">NaN</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$nodes">
				<xsl:sort data-type="number" />
				<xsl:if test="position() = 1">
					<xsl:value-of select="number(.)" />
				</xsl:if>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="max">
	<xsl:param name="nodes" select="/.." />
	<xsl:choose>
		<xsl:when test="not($nodes)">NaN</xsl:when>
		<xsl:otherwise>
			<xsl:for-each select="$nodes">
				<xsl:sort data-type="number" order="descending" />
				<xsl:if test="position() = 1">
					<xsl:value-of select="number(.)" />
				</xsl:if>
			</xsl:for-each>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="display-percent">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0.00%')" />
</xsl:template>

<xsl:template name="display-time">
	<xsl:param name="value" />
	<xsl:value-of select="format-number($value,'0 ms')" />
</xsl:template>
	
</xsl:stylesheet>
