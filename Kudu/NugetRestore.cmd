@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: NugetRestore ^<relative path to .sln file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Restoring NuGet packages for %1
echo ------------------------------------------------------
echo.

IF /I "%1" NEQ "" (
  call "%NUGET_EXE%" restore %1
)

:exit
exit /b %ERRORLEVEL%