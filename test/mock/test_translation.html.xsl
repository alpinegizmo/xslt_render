<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tr="http://www.hotelsearch.com/XMLSchema/2007/translation">
    <xsl:output method="xml"/>

    <xsl:param name="title">default</xsl:param>
    <xsl:template match="/">
        <html>
            <head>
                <title><xsl:value-of select="$title" /></title>
            </head>
            <body>
                <p><tr:term>hello</tr:term> and <tr:term>language</tr:term></p>
                <dt>
                    <xsl:apply-templates />
                </dt>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="*">
        <dt><xsl:value-of select="name()" /></dt>
        <dd><dl><xsl:apply-templates select="*|@*|text()" /></dl></dd>
    </xsl:template>

    <xsl:template match="@*">
        <dt>@<xsl:value-of select="name()" /></dt>
        <dd><xsl:value-of select="." /></dd>
    </xsl:template>

    <xsl:template match="text()">
        <dt><xsl:value-of select="." /></dt>
    </xsl:template>
</xsl:stylesheet>
