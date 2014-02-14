﻿<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
    xmlns="http://schemas.microsoft.com/developer/msbuild/2003"
    xmlns:msbuild="http://schemas.microsoft.com/developer/msbuild/2003"
>
  <xsl:output method="xml" indent="yes"/>
  <xsl:param name="StrongNamePath" />

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="msbuild:Project/msbuild:PropertyGroup/msbuild:AssemblyOriginatorKeyFile">
    <AssemblyOriginatorKeyFile>
      <xsl:value-of select="$StrongNamePath"/>
    </AssemblyOriginatorKeyFile>
  </xsl:template>
</xsl:stylesheet>