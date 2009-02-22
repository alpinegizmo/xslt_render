<?xml version="1.0" encoding="UTF-8"?>
<!-- RAILS view helpers -->
<xsl:stylesheet version="1.0"
                xmlns="http://www.w3.org/1999/xhtml" 
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template name="link-to">
    <xsl:param name="text" />
    <xsl:param name="base" />
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="/*/url-root" />/<xsl:value-of select="$base" />
      </xsl:attribute>
      <xsl:if test="/*/frame-target">
        <xsl:attribute name="target"><xsl:value-of select="/*/frame-target" /></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="$text" />
    </a>
  </xsl:template>

  <xsl:template name="form-attributes">
    <xsl:param name="method">post</xsl:param>
    <xsl:param name="base" />
    <xsl:attribute name="method"><xsl:value-of select="$method" /></xsl:attribute>
    <xsl:attribute name="action">
      <xsl:value-of select="/*/url-root" />/<xsl:value-of select="$base" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="img-path">
    <xsl:param name="file" />
    <xsl:value-of select="/*/url-root" />/images/<xsl:value-of select="$file" />
  </xsl:template>

  <xsl:template name="img-src">
    <xsl:param name="file" />
    <xsl:attribute name="src">
      <xsl:call-template name="img-path">
        <xsl:with-param name="file" select="$file" />
      </xsl:call-template>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="url">
    <xsl:param name="base" />
    <xsl:value-of select="/*/url-root" />/<xsl:value-of select="$base" />
  </xsl:template>

  <xsl:template name="button-to">
    <xsl:param name="text" />
    <xsl:param name="base" />
    <form method="post" class="button-to">
      <xsl:call-template name="form-attributes">
        <xsl:with-param name="base"><xsl:value-of select="$base" /></xsl:with-param>
      </xsl:call-template>
      <div>
        <input type="submit">
          <xsl:attribute name="value" >
            <xsl:value-of select="$text" />
          </xsl:attribute>
        </input>
      </div>
    </form>
  </xsl:template>

  <xsl:template name="javascript-body">
    <xsl:param name="body" />
    <script type="text/javascript"><xsl:text disable-output-escaping="yes">
        // &lt;![CDATA[
      </xsl:text><xsl:value-of select="$body" /><xsl:text disable-output-escaping="yes">
        // ]]&gt;
    </xsl:text></script>
  </xsl:template>

  <!-- TODO: salt the stylesheet and javascript links -->
  <xsl:template match="stylesheet">
    <xsl:call-template name="stylesheet">
      <xsl:with-param name="sheet" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="javascript|default-javascript">
    <xsl:call-template name="javascript">
      <xsl:with-param name="script" select="." />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="stylesheet">
    <xsl:param name="sheet" />
    <link media="screen" rel="stylesheet" type="text/css">
      <xsl:choose>
        <xsl:when test="starts-with($sheet,'http')">
          <xsl:attribute name="href"><xsl:value-of select="$sheet" /></xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="href">
            <xsl:value-of select="/*/url-root" />/stylesheets/<xsl:value-of select="$sheet" />
            <xsl:if test="not(contains($sheet,'.css'))">
              <xsl:text>.css</xsl:text>
            </xsl:if>
          </xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
    </link>
  </xsl:template>

  <xsl:template name="javascript-src">
    <xsl:param name="script" />
    <xsl:attribute name="src">
      <xsl:value-of select="/*/url-root" />/javascripts/<xsl:value-of select="$script" />
      <xsl:if test="not(contains($script,'.js'))">
        <xsl:text>.js</xsl:text>
      </xsl:if>
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="javascript">
    <xsl:param name="script">defaults</xsl:param>
    <xsl:choose>
      <xsl:when test="$script='defaults'">
        <xsl:apply-templates select="../../default-javascripts/*" />
      </xsl:when>
      <xsl:otherwise>
        <script type="text/javascript">
          <xsl:call-template name="javascript-src">
            <xsl:with-param name="script" select="$script" />
          </xsl:call-template>
        </script>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="uri-delete-param">
    <xsl:param name="param" />
    <xsl:param name="base-uri" select="/*/request-uri" />
    <xsl:variable name="param-equate" select="concat($param, '=')" />
    <xsl:variable name="rest" select="substring-after(substring-after($base-uri, $param-equate), '&amp;')" />
    <xsl:variable name="before" select="substring-before($base-uri, $param-equate)" />
    <xsl:variable name="result" select="concat($before, $rest)" />
    
    <xsl:choose>
      <xsl:when test="not(contains($base-uri, $param-equate))">
        <xsl:value-of select="$base-uri" />
      </xsl:when>
      <xsl:when test="substring-after($result, '?') = ''">
        <xsl:value-of select="substring-before($result, '?')" />
      </xsl:when>
      <xsl:when test="substring($result, string-length($result)) = '&amp;'">
        <xsl:value-of select="substring($result, 1, string-length($result) - 1)" />
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$result" /></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="uri-attribute-set-param">
    <xsl:param name="param" />
    <xsl:param name="value" />
    <xsl:param name="attribute">href</xsl:param>
    <xsl:param name="base-uri" select="/*/request-uri" />

    <xsl:variable name="param-equate" select="concat($param, '=')" />
    <xsl:attribute name="{$attribute}">
      <xsl:choose>
        <xsl:when test="contains($base-uri, $param-equate)">
          <xsl:variable name="rest" select="substring-after(substring-after($base-uri, $param-equate), '&amp;')" />
          <xsl:value-of select="concat(substring-before($base-uri, $param-equate), $param-equate, $value)" />
          <xsl:if test="$rest">
            <xsl:value-of select="concat('&amp;', $rest)" />
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="separator">
            <xsl:choose>
              <xsl:when test="contains($base-uri,'?')">
                <xsl:text>&amp;</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>?</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:value-of select="concat($base-uri, $separator, $param-equate, $value)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>
</xsl:stylesheet>
