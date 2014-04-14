@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: BuildLibrary ^<relative path to .csproj file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Building %1
echo ------------------------------------------------------
echo.

if not exist "%1.xslt" (
  %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xml" /p:ProjectFile=%1 /p:TransformFile="%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" /p:StrongNamePath="%DEPLOYMENT_STRONG_NAME_KEY%"
)

if exist "%1.xslt" (
  for %%A in (%1) do (
     set PROJECT_FOLDER=%%~dpA
  )
  echo copy "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" %PROJECT_FOLDER%
  copy "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xslt" %PROJECT_FOLDER%
 
  %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile.xml" /p:ProjectFile=%1 /p:TransformFile="%1.xslt" /p:ReferenceDllPath="%DEPLOYMENT_TRANSFORMS%" /p:StrongNamePath="%DEPLOYMENT_STRONG_NAME_KEY%"
)

IF /I "%IN_PLACE_DEPLOYMENT%" NEQ "1" (
  %MSBUILD_PATH% %1 /nologo /verbosity:m /t:Build /p:_PackageTempDir="%DEPLOYMENT_TEMP%";AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %SCM_BUILD_ARGS%
) ELSE (
  %MSBUILD_PATH% %1 /nologo /verbosity:m /t:Build /p:AutoParameterizationWebConfigConnectionStrings=false;Configuration=Release /p:SolutionDir="%DEPLOYMENT_SOURCE%\.\\" %SCM_BUILD_ARGS%
)

:exit
exit /b %ERRORLEVEL%