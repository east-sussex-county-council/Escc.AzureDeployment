@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfigToWorkBelowUmbraco ^<folder name\configuration filename without extension^>
	echo.
	echo eg TransformConfigToWorkBelowUmbraco ExampleSite\web
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1.config to work below Umbraco
echo ------------------------------------------------------
echo.

if exist "%DEPLOYMENT_SOURCE%\%1.config" (
  %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig.xml" /p:TransformInputFile="%DEPLOYMENT_SOURCE%\%1.config" /p:TransformFile="%DEPLOYMENT_SOURCE%\Escc.AzureDeployment\Kudu\TransformConfigToWorkBelowUmbraco.xdt" /p:TransformOutputFile="%DEPLOYMENT_SOURCE%\%1.config"
)

:: Delete temp file created by transformation, because deleting it within the transformation fails due to file locking 
if exist "%DEPLOYMENT_SOURCE%\%1.config.temp.config" (
  del "%DEPLOYMENT_SOURCE%\%1.config.temp.config" 
)

:exit
exit /b %ERRORLEVEL%