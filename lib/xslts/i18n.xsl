<?xml version="1.0" encoding="UTF-8"?>
<!--This stylesheet is used internally by the xslt plugin to do internationalization.-->
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation"
  exclude-result-prefixes="tr">

  <xsl:output indent="yes" method="xml" encoding="UTF-8"
      doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
      doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"
  />

  <xsl:param name="termfile" />
  
  <xsl:variable name="termdoc" select="document($termfile)" />
  
  <xsl:key name="terms" match="term" use="@name" />
  
  <xsl:variable name="language">
    <xsl:for-each select="$termdoc">
      <xsl:value-of select="/terms/@lang" />
    </xsl:for-each>
  </xsl:variable>

  <xsl:template match="/">
    <xsl:apply-templates select="*" />
  </xsl:template>

  <xsl:template match="tr:term">
    <xsl:choose>
      <xsl:when test="count(*)=0 and count(text())=1">
        <xsl:variable name="term"><xsl:value-of select="text()" /></xsl:variable>
        <xsl:variable name="pass-thru"><xsl:value-of select="@pass-thru" /></xsl:variable>
        <xsl:for-each select="$termdoc">
          <xsl:variable name="translation" select="key('terms', $term)" />
          <xsl:choose>
            <xsl:when test="$translation">
              <xsl:value-of select="$translation" />
            </xsl:when>
            <xsl:when test="$pass-thru = 'true'">
              <xsl:value-of select="$term" />
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="*|@*|text()" />
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*[starts-with(.,'tr:')]">
    <xsl:variable name="term"><xsl:value-of select="substring(.,4)" /></xsl:variable>
    <xsl:variable name="attrName"><xsl:value-of select="name()" /></xsl:variable>
    <xsl:for-each select="$termdoc">
      <xsl:attribute name="{$attrName}">
        <xsl:value-of select="key('terms', $term)" />
      </xsl:attribute>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tr:ordered">
    <xsl:variable name="before"><xsl:value-of select="@before" /></xsl:variable>
    <xsl:variable name="text"><xsl:value-of select="text()" /></xsl:variable>
    <xsl:variable name="after"><xsl:value-of select="@after" /></xsl:variable>
    <xsl:variable name="before-translation">
      <xsl:for-each select="$termdoc">
        <xsl:value-of select="key('terms', $before)" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="after-translation">
      <xsl:for-each select="$termdoc">
        <xsl:value-of select="key('terms', $after)" />
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$language = 'ja'">
        <xsl:value-of select="$after-translation" />
        <xsl:value-of select="$text" /> 
        <xsl:value-of select="$before-translation" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$before-translation != ''">
          <xsl:value-of select="$before-translation" />
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="$text" /> 
        <xsl:if test="$after-translation != ''">
          <xsl:text> </xsl:text>
          <xsl:value-of select="$after-translation" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="xhtml:div|xhtml:script|xhtml:span">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:choose>
        <xsl:when test="count(*)=0 and count(text())=0">
          <xsl:text> </xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*|text()" />        
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="*|@*|text()" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*">
    <xsl:copy />
  </xsl:template>
</xsl:stylesheet>

