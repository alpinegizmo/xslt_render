<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template mode="json" match="*[@type='date']">
    <xsl:value-of select="translate(name(), '-', '_')" />
    <xsl:text>: new Date("</xsl:text>
    <xsl:value-of select="translate(., '-', '/')" />
    <xsl:text>")</xsl:text>
  </xsl:template>

  <xsl:template mode="json" match="*[@type='datetime']">
    <xsl:variable name="date"
      select="translate(substring-before(., 'T'), '-', '/')"
    />
    <xsl:variable name="full-time" select="substring-after(., 'T')" />
    <xsl:variable name="time">
      <xsl:choose>
        <xsl:when test="contains($full-time, '-')">
          <xsl:value-of select="substring-before($full-time, '-')" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="substring-before($full-time, '+')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="time-zone" 
      select="substring-after($full-time,$time)"
    />
    <xsl:value-of select="translate(name(), '-', '_')" />
    <xsl:text>: new Date("</xsl:text>
    <xsl:value-of select="$date" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="$time" />
    <xsl:text> </xsl:text>
    <xsl:value-of select="$time-zone" />
    <xsl:text>")</xsl:text>
  </xsl:template>

  <xsl:template mode="json" 
    match="*[@type='integer']|*[@type='float']|*[@type='boolean']">
    <xsl:value-of select="translate(name(), '-', '_')" />
    <xsl:text>: </xsl:text>
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template mode="json" priority="-1" 
    match="*[count(./text()) = 1][count(./*) = 0]">
    <xsl:value-of select="translate(name(), '-', '_')" />
    <xsl:text>: "</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:template>

  <xsl:template priority="-2" mode="json" match="*">
    <xsl:value-of select="translate(name(), '-', '_')" />
    <xsl:text>: {</xsl:text>
    <xsl:for-each select="*[position()&lt;last()]">
      <xsl:apply-templates mode="json" select="." />
      <xsl:text>,
      </xsl:text>
    </xsl:for-each>
    <xsl:apply-templates mode="json" select="*[last()]" />
    <xsl:text>}</xsl:text>
  </xsl:template>

</xsl:stylesheet>
