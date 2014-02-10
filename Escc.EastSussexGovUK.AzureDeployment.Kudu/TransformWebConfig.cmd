@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if String.Empty%1==String.Empty (
	echo Usage: TransformConfig ^<folder name^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Transforming %1\web.config.example
echo ------------------------------------------------------
echo.

if exist "%DEPLOYMENT_SOURCE%\%1\web.config.example" (                                 
  %MSBUILD_PATH% "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\TransformWebConfig.xml" /p:TransformInputFile="%DEPLOYMENT_SOURCE%\%1\web.config.example" /p:TransformFile="%DEPLOYMENT_CONFIG_TRANSFORMS%\%1\Web.config.Release" /p:TransformOutputFile="%DEPLOYMENT_TARGET%\%1\web.config"
)

:exit
exit /b %ERRORLEVEL%