@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: BuildLibrary ^<relative path to project folder^> ^<.csproj file^>
	goto exit
)

if "%2"=="" (
	echo Usage: BuildLibrary ^<relative path to project folder^> ^<.csproj file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Building %1%2
echo ------------------------------------------------------
echo.

if not exist "%1%2.xslt" (
  %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xml" /p:ProjectFile="%1%2" /p:TransformFile="%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" /p:StrongNamePath=%DEPLOYMENT_STRONG_NAME_KEY%
)

if exist "%1%2.xslt" (
  echo copy "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" "%1"
  copy "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" "%1"
 
  %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xml" /p:ProjectFile="%1%2" /p:TransformFile="%1%2.xslt" /p:ReferenceDllPath=%DEPLOYMENT_TRANSFORMS% /p:StrongNamePath=%DEPLOYMENT_STRONG_NAME_KEY%
)

IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  %MSBUILD_PATH% "%1%2" /nologo /verbosity:m /t:Build /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %SCM_BUILD_ARGS%
) ELSE (
  %MSBUILD_PATH% "%1%2" /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %SCM_BUILD_ARGS%
)

:exit
exit /b %ERRORLEVEL%