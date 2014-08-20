@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: RunTests ^<relative path to project folder^> ^<.csproj file^>
	goto exit
)

if "%2"=="" (
	echo Usage: RunTests ^<relative path to project folder^> ^<.csproj file^>
	goto exit
)

call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %1 packages.config ..\packages
IF !ERRORLEVEL! NEQ 0 goto exit

call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildLibrary" %1 %2
IF !ERRORLEVEL! NEQ 0 goto exit

echo.
echo ------------------------------------------------------
echo Running tests for %1
echo ------------------------------------------------------
echo.

call "%DEPLOYMENT_SOURCE%\Escc.AzureDeployment\packages\NUnit.Runners.2.6.3\tools\nunit-console" %1%2 /config=Release /framework=net-4.5

:exit
exit /b %ERRORLEVEL%