<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="xml"/>

    <xsl:param name="title">default</xsl:param>
    <xsl:template match="/">
        <html>
            <head>
                <title><xsl:value-of select="$title" /></title>
            </head>
            <body>
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
