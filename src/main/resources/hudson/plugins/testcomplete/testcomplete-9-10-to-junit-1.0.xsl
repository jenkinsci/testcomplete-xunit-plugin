<?xml version="1.0" encoding="UTF-8"?>
<!--
The MIT License (MIT)

Copyright (c) 2015 Fernando Miguélez Palomo and all contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
-->
<xsl:stylesheet version="2.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:xdt="http://www.w3.org/2005/xpath-datatypes">

	<xsl:param name="baseUrl" select="'http://localhost/'" />
	<xsl:param name="basePath" select="." />
	<xsl:param name="testPattern" select="'[^\]]+'" />

	<xsl:variable name="testLogNamePattern"
		select="concat(concat('[^ ]+ Test Log \[(',$testPattern), ')\]')" />
	<xsl:variable name="baseDir">
		<xsl:choose>
			<xsl:when test="ends-with($basePath,'/')">
				<xsl:value-of select="$basePath" />
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="concat($basePath,'/')" />
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>


	<xsl:output method="xml" indent="yes" />
	<xsl:template match="/LogData">
		<xsl:variable name="testCount"
			select="count(//LogData[matches(@name,$testLogNamePattern) and Provider/@name='Test Log'])" />
		<xsl:variable name="failureCount"
			select="count(//LogData[matches(@name,$testLogNamePattern) and Provider/@name='Test Log' and @status=2])" />

		<xsl:variable name="testSuiteData"
			select="document(concat($baseDir,lower-case(substring-after(Provider[position() = 1]/@href,$baseUrl))))" />

		<testsuite>
			<xsl:if
				test="$testSuiteData//*[ends-with(name(),'LogItem') and position()=1]/StartTime">
				<xsl:attribute name="timestamp">
					<xsl:call-template name="convertTc2XsdDateTime">
	                            <xsl:with-param name="inputDateTime"
					select="string($testSuiteData//*[ends-with(name(),'LogItem') and position()=1]/StartTime)" />
								<xsl:with-param name="inputMillis"
					select="number($testSuiteData//*[ends-with(name(),'LogItem') and position()=1]/StartTime/@msec) mod 1000" />
								<xsl:with-param name="dateTimeSeparator" select="'T'"/>
					</xsl:call-template>
	            </xsl:attribute>
			</xsl:if>
			<xsl:if test="$testSuiteData//*[ends-with(name(),'LogItem')]/RunTime">
				<xsl:attribute name="time">
					<xsl:call-template name="addUpIntervals">
						<xsl:with-param name="runTimeNodes" select="$testSuiteData//*[ends-with(name(),'LogItem')]/RunTime"/>
					</xsl:call-template>
	            </xsl:attribute>
			</xsl:if>
			<xsl:attribute name="tests">
					        <xsl:value-of select="$testCount" />
                    </xsl:attribute>
			<xsl:attribute name="errors">
                            <xsl:text>0</xsl:text>
                        </xsl:attribute>
			<xsl:attribute name="failures">
                            <xsl:value-of select="$failureCount" />
                        </xsl:attribute>
			<xsl:attribute name="skipped">
                            <xsl:text>0</xsl:text>
                    </xsl:attribute>
			<xsl:attribute name="name">
                            <xsl:value-of select="@name" />
                    </xsl:attribute>
			<xsl:for-each
				select="//LogData[matches(@name,$testLogNamePattern) and Provider/@name='Test Log']">
				<testcase>
					<xsl:variable name="testLogData">
						<xsl:if test="../Provider[ends-with(@name,'Log') and position() = 1]">
							<xsl:copy-of
								select="document(concat($baseDir,lower-case(substring-after(../Provider[ends-with(@name,'Log') and position() = 1]/@href,$baseUrl))))" />
						</xsl:if>
					</xsl:variable>
					<xsl:variable name="testItemsLogData">
						<xsl:copy-of
							select="document(concat($baseDir,lower-case(substring-after(Provider[ends-with(@name,'Log') and position() = 1]/@href,$baseUrl))))" />
					</xsl:variable>

					<xsl:variable name="testLogPosition">
						<xsl:value-of
							select="count(preceding-sibling::LogData[Provider/@name = 'Test Log']) + 1" />
					</xsl:variable>

					<xsl:if test="$testLogData//*[ends-with(name(),'LogItem') and position()=$testLogPosition]/RunTime">
						<xsl:attribute name="time">
							<xsl:call-template name="addUpIntervals">
								<xsl:with-param name="runTimeNodes" select="$testLogData//*[ends-with(name(),'LogItem') and position()=$testLogPosition]/RunTime"/>
							</xsl:call-template>
	                    </xsl:attribute>
					</xsl:if>
					<xsl:attribute name="name">
						<xsl:value-of select="replace(@name, $testLogNamePattern,'$1')" />
                    </xsl:attribute>
                    <xsl:variable name="classname">
					    <xsl:value-of
							select="ancestor::LogData[Provider/@name='Project Log' and position() = last()-1]/@name" />
					</xsl:variable>
					<xsl:if test="$classname != ''">
							<xsl:attribute name="classname">
								<xsl:value-of select="$classname"/>
							</xsl:attribute>
					</xsl:if>
					<xsl:if test="@status = '2'">
						<failure>
							<xsl:attribute name="message">
								<xsl:value-of
								select="normalize-space(string($testItemsLogData//TestLogItem[string(TypeDescription)  = 'Error' and position() = 1]/Message))" />
                            </xsl:attribute>
						</failure>
					</xsl:if>
					<system-out>
						<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
						<xsl:call-template name="dumpTestLogMessages">
							<xsl:with-param name="testItemsLogData" select="$testItemsLogData" />
						</xsl:call-template>
						<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
					</system-out>
				</testcase>
			</xsl:for-each>
		</testsuite>
	</xsl:template>

	<xsl:template name="addUpIntervals">
		<xsl:param name="runTimeNodes"/>
		<xsl:variable name="intervalsInSeconds">
			<xsl:for-each select="$runTimeNodes">
				<timeInSecs>
					<xsl:choose>
						<xsl:when test="number(@msec) = @msec">
							<!-- TC10 does have milliseconds so we just need to convert to seconds that field -->
							<xsl:value-of select="number(@msec) div 1000"/>						
						</xsl:when>
						<xsl:otherwise> 
							<!-- TC9 does not have millisecond resolution. We have to convert intervals in hh:mm:ss to seconds -->
							<xsl:analyze-string select="."
								regex="([0-9]+):([0-9]+):([0-9]+)$">
								<xsl:matching-substring>
									<xsl:variable name="hours" select="number(regex-group(1))"/>
									<xsl:variable name="minutes" select="number(regex-group(2))" />
									<xsl:variable name="seconds" select="number(regex-group(3))" />
									<xsl:value-of select="number($hours) * 3600 + number($minutes) * 60 + number($seconds)" />
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<xsl:text>0</xsl:text>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:otherwise>
					</xsl:choose>
				</timeInSecs>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:value-of select="format-number(sum($intervalsInSeconds//timeInSecs), '0.###')"/>
	</xsl:template>

	<!-- Adaptation from from http://stackoverflow.com/a/17084608 -->
	<xsl:template name="convertTc2XsdDateTime">
		<xsl:param name="inputDateTime" />
		<!-- Separator can be ' ' for log entries or 'T' to generate a valid ISO 8601 format for test suite timestamp  -->
		<xsl:param name="dateTimeSeparator"/>
		<xsl:param name="inputMillis" />
		
		<xsl:variable name="millisPart">
			<!-- Only TC10 supports milliseconds in time fields -->
			<xsl:choose>
				<xsl:when test="number($inputMillis) = $inputMillis">
					<xsl:value-of select="concat('.', format-number($inputMillis,'000'))"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<!-- Format TC10: MM/dd/yyyy hh:mm:ss aa -->
			<xsl:when test="matches($inputDateTime, '[0-9]{1,2}[/\-.][0-9]{1,2}[/\-.][0-9]{4} [0-9]{1,2}:[0-9]{2}:[0-9]{2} PM|AM$')">
				<xsl:analyze-string select="$inputDateTime"
					regex="([0-9]+)[/\-.]([0-9]+)[/\-.]([0-9]+) ([0-9]+):([0-9]+):([0-9]+) (PM|AM)$">
					<xsl:matching-substring>
						<xsl:variable name="month" select="number(regex-group(1))" />
						<xsl:variable name="day" select="number(regex-group(2))" />
						<xsl:variable name="year" select="number(regex-group(3))" />
						<xsl:variable name="hours">
							<xsl:choose>
								<xsl:when test="regex-group(7) = 'PM'">
									<xsl:value-of select="12 + number(regex-group(4))" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="number(regex-group(4)) mod 12" />
								</xsl:otherwise>
							</xsl:choose>
						</xsl:variable>
						<xsl:variable name="minutes" select="number(regex-group(5))" />
						<xsl:variable name="seconds" select="number(regex-group(6))" />
						<xsl:value-of select="concat($year, '-', format-number($month, '00'), '-', format-number($day, '00'), $dateTimeSeparator, format-number($hours, '00'), ':', format-number($minutes, '00'), ':', format-number($seconds, '00'), $millisPart)" />
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<!-- Format TC10: dd/MM/yyyy HH:mm:ss -->
			<xsl:when test="matches($inputDateTime, '[0-9]{1,2}[/\-.][0-9]{1,2}[/\-.][0-9]{4} [0-9]{1,2}:[0-9]{2}:[0-9]{2}$')">
				<xsl:analyze-string select="$inputDateTime"
					regex="([0-9]+)[/\-.]([0-9]+)[/\-.]([0-9]+) ([0-9]+):([0-9]+):([0-9]+)$">
					<xsl:matching-substring>
						<xsl:variable name="day" select="number(regex-group(1))" />
						<xsl:variable name="month" select="number(regex-group(2))" />
						<xsl:variable name="year" select="number(regex-group(3))" />
						<xsl:variable name="hours" select="number(regex-group(4))" />
						<xsl:variable name="minutes" select="number(regex-group(5))" />
						<xsl:variable name="seconds" select="number(regex-group(6))" />
						<xsl:value-of select="concat($year, '-', format-number($month, '00'), '-', format-number($day, '00'), $dateTimeSeparator, format-number($hours, '00'), ':', format-number($minutes, '00'), ':', format-number($seconds, '00'), $millisPart)" />
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
			<!-- Format TC9: yyyy-MM-dd HH:mm:ss -->
			<xsl:when test="matches($inputDateTime, '[0-9]{4}[/\-.][0-9]{1,2}[/\-.][0-9]{1,2} [0-9]{1,2}:[0-9]{2}:[0-9]{2}$')">
				<xsl:analyze-string select="$inputDateTime"
					regex="([0-9]+)[/\-.]([0-9]+)[/\-.]([0-9]+) ([0-9]+):([0-9]+):([0-9]+)$">
					<xsl:matching-substring>
						<xsl:variable name="year" select="number(regex-group(1))" />
						<xsl:variable name="month" select="number(regex-group(2))" />
						<xsl:variable name="day" select="number(regex-group(3))" />
						<xsl:variable name="hours" select="number(regex-group(4))" />
						<xsl:variable name="minutes" select="number(regex-group(5))" />
						<xsl:variable name="seconds" select="number(regex-group(6))" />
						<xsl:value-of select="concat($year, '-', format-number($month, '00'), '-', format-number($day, '00'), $dateTimeSeparator, format-number($hours, '00'), ':', format-number($minutes, '00'), ':', format-number($seconds, '00'), $millisPart)" />
					</xsl:matching-substring>
				</xsl:analyze-string>
			</xsl:when>
		</xsl:choose>
	</xsl:template>

	<xsl:template name="dumpTestLogMessages">
		<xsl:param name="testItemsLogData" />
		<xsl:for-each select="$testItemsLogData//TestLogItem">
			<xsl:variable name="testEntryTimestamp">
				<xsl:call-template name="convertTc2XsdDateTime">
					<xsl:with-param name="inputDateTime" select="Time" />
					<xsl:with-param name="dateTimeSeparator" select="' '"/>
					<xsl:with-param name="inputMillis" select="number(Time/@msec) mod 1000" />
				</xsl:call-template>
			</xsl:variable>
			<xsl:value-of
				select="concat('[',$testEntryTimestamp, '] ** ', TypeDescription, ' ** : ', Message)" />
			<xsl:text>&#xa;</xsl:text>
			<xsl:if test="count(CallStack/CallStackItem) > 0">
				<xsl:text>  Call Stack:&#xa;</xsl:text>
				<xsl:for-each select="CallStack/CallStackItem">
					<xsl:text>    </xsl:text>
					<xsl:value-of select="concat(LineNo,': ')" />
					<xsl:if test="normalize-space(string(UnitName)) != ''">
						<xsl:value-of select="concat(UnitName,'.')" />
					</xsl:if>
					<xsl:value-of select="Test" />
					<xsl:text>&#xa;</xsl:text>
				</xsl:for-each>
			</xsl:if>
			<xsl:if test="normalize-space(string(AdditionalInfo)) != ''">
				<xsl:text>  Additional Info:&#xa;</xsl:text>
				<xsl:value-of select="replace(string(AdditionalInfo),'^','    ','m')"
					disable-output-escaping="yes" />
				<xsl:text>&#xa;</xsl:text>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>