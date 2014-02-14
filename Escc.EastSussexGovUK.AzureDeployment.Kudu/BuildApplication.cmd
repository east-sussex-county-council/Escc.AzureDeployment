@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: BuildApplication ^<relative path to .csproj file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Building %1
echo ------------------------------------------------------
echo.

%MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\TransformStrongName.xml" /p:ProjectFile=%1 /p:TransformFile="%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\TransformStrongName.xslt" /p:StrongNamePath="%STRONG_NAME_PATH%"

IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  %MSBUILD_PATH% %1 /nologo /verbosity:m /t:Build /t:pipelinePreDeployCopyAllFilesToOneFolder /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %SCM_BUILD_ARGS%
) ELSE (
  %MSBUILD_PATH% %1 /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %SCM_BUILD_ARGS%
)

:exit
exit /b %ERRORLEVEL%