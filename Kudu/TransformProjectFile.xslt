<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
    xmlns="http://schemas.microsoft.com/developer/msbuild/2003"
    xmlns:msbuild="http://schemas.microsoft.com/developer/msbuild/2003"
>
  <xsl:output method="xml" indent="yes"/>

  <!-- Specify parameters to configure the transform. -->
  <xsl:param name="StrongNamePath" />
  <xsl:param name="ReferenceDllPath" />

  <!-- Copy every node that we're not matching explicitly, so that the rest of the project file remains unchanged. -->
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- Replace the path to the strong name key file with the $StrongNamePath variable. 
       This just happens. No need to call it from a project-specific file. -->
  <xsl:template match="msbuild:Project/msbuild:PropertyGroup/msbuild:AssemblyOriginatorKeyFile">
    <!-- Output AssemblyOriginatorKeyFile element as CDATA to avoid adding msbuild namespace -->
    <xsl:text disable-output-escaping="yes"><![CDATA[<AssemblyOriginatorKeyFile>]]></xsl:text>
    <xsl:value-of select="$StrongNamePath"/>
    <xsl:text disable-output-escaping="yes"><![CDATA[</AssemblyOriginatorKeyFile>]]></xsl:text>
  </xsl:template>

  <!-- Remove any references to the MS Build version of NuGet package restore. These are only required to support the way we work locally,
       and cause problems when deployed to Azure. Empty templates cause the elements to be removed. -->
  <xsl:template match="msbuild:Project/msbuild:Target/msbuild:Error[@Condition=&quot;!Exists('$(SolutionDir)\.nuget\NuGet.targets')&quot;]">
    
  </xsl:template>

  <xsl:template match="msbuild:Project/msbuild:Import[@Project=&quot;$(SolutionDir)\.nuget\NuGet.targets&quot;]">
    
  </xsl:template>

  <!-- Update solution-relative references to NuGet packages to be project-relative, by removing everything before \packages\. 
       This can match the element directly, or be called when another template matches the same element and overrides this one. -->
  <xsl:template match="msbuild:Project/msbuild:ItemGroup/msbuild:Reference/msbuild:HintPath[contains(text(),'\packages\')]" name="UpdatePackagesHintPath">
    <xsl:call-template name="OutputHintPath">
      <xsl:with-param name="DllFile" select="concat('packages\', substring-after(., '\packages\'))" />
    </xsl:call-template>
  </xsl:template>

  <!-- Template to be called from a derived stylesheet matching on msbuild:Project/msbuild:ItemGroup/msbuild:Reference/msbuild:HintPath. 
       The parameters should be the names of the assemblies whose paths should be replaced by $ReferenceDllPath. If there are not enough
       parameters, update this stylesheet to add more. -->
  <xsl:template name="UpdateHintPath">
    <xsl:param name="ref_1" />
    <xsl:param name="ref_2" />
    <xsl:param name="ref_3" />
    <xsl:param name="ref_4" />
    <xsl:param name="ref_5" />
    <xsl:param name="ref_6" />
    <xsl:param name="ref_7" />
    <xsl:param name="ref_8" />
    <xsl:param name="ref_9" />
    <xsl:param name="ref_10" />

    <!-- Check whether the current element matches each referenced assembly name. 
         If none match, output the current element unaltered. -->
    <xsl:choose>
      <xsl:when test="$ref_1 != '' and self::node()[contains(text(),concat('\',$ref_1))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_1" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_2 != '' and self::node()[contains(text(),concat('\',$ref_2))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_2" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_3 != '' and self::node()[contains(text(),concat('\',$ref_3))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_3" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_4 != '' and self::node()[contains(text(),concat('\',$ref_4))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_4" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_5 != '' and self::node()[contains(text(),concat('\',$ref_5))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_5" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_6 != '' and self::node()[contains(text(),concat('\',$ref_6))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_6" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_7 != '' and self::node()[contains(text(),concat('\',$ref_7))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_7" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_8 != '' and self::node()[contains(text(),concat('\',$ref_8))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_8" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_9 != '' and self::node()[contains(text(),concat('\',$ref_9))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_9" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="$ref_10 != '' and self::node()[contains(text(),concat('\',$ref_10))]">
        <xsl:call-template name="OutputHintPath">
          <xsl:with-param name="DllFile" select="$ref_10" />
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="self::node()[contains(text(),'\packages\')]">
        <!-- When the UpdateHintPath template is called, it usually means UpdatePackagesHintPath has been overridden by another template
             later in the XSL matching the same HintPath element. So call it directly instead. -->
        <xsl:call-template name="UpdatePackagesHintPath" />
      </xsl:when>

      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Output an amended HintPath element using the path specified in $ReferenceDllPath and the file in $DllFile -->
  <xsl:template name="OutputHintPath">
    <xsl:param name="DllFile" />
    <!-- Output HintPath element as CDATA to avoid adding msbuild namespace -->
    <xsl:text disable-output-escaping="yes"><![CDATA[<HintPath>]]></xsl:text>
    <xsl:value-of select="$ReferenceDllPath"/>
    <xsl:value-of select="$DllFile"/>
    <xsl:text disable-output-escaping="yes"><![CDATA[</HintPath>]]></xsl:text>
  </xsl:template>

</xsl:stylesheet>
