@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: NugetRestore ^<relative path to .sln file or folder containing packages.config file^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Restoring NuGet packages for %1
echo ------------------------------------------------------
echo.

IF /I "%1" NEQ "" (

  :: When the solution file is elsewhere, restore from packages.config next to the .csproj by specifying the folder
  if exist "%1\packages.config" (
      call "%NUGET_EXE%" restore "%1\packages.config" -OutputDirectory "%1\packages" -NonInteractive
      goto exit
  ) 
  
  if not exist "%1\packages.config" (
      :: Otherwise assume parameter was a solution file, useful when the solution file is in the same folder as the project file being built.
      :: Syntax like if /I "%NUGET_RESTORE_FROM:~-4%"==".sln" to check value was invalid on Kudu.
      call "%NUGET_EXE%" restore %1 -NonInteractive
      goto exit
  )

)

:exit
exit /b %ERRORLEVEL%