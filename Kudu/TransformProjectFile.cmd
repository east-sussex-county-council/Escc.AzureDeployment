@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: TransformProjectFile ^<relative path to project folder^> ^<.csproj file^>
	goto exit
)

if "%2"=="" (
	echo Usage: TransformProjectFile ^<relative path to project folder^> ^<.csproj file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1%2
echo ------------------------------------------------------
echo.

if not exist "%1%2.xslt" (
  "%MSBUILD_PATH%" "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xml" /p:ProjectFile="%1%2" /p:TransformFile="%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" /p:StrongNamePath=%DEPLOYMENT_STRONG_NAME_KEY%
)

if exist "%1%2.xslt" (
  echo copy "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" "%1"
  copy "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" "%1"
 
  "%MSBUILD_PATH%" "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xml" /p:ProjectFile="%1%2" /p:TransformFile="%1%2.xslt" /p:ReferenceDllPath=%DEPLOYMENT_TRANSFORMS%\ /p:StrongNamePath=%DEPLOYMENT_STRONG_NAME_KEY%
)

:exit
exit /b %ERRORLEVEL%