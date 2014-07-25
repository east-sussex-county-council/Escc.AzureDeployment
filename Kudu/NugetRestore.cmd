@if "%SCM_TRACE_LEVEL%" NEQ "4" @echo off

if "%1"=="" (
	echo Usage: NugetRestore ^<relative path to folder containing packages.config or .sln file^> ^<optional .sln filename^>
	goto exit
)

echo.
echo ------------------------------------------------------
echo Restoring NuGet packages for %1
echo ------------------------------------------------------
echo.

IF /I "%1" NEQ "" (

  :: Copy a custom nuget.config if present, to allow a custom package source to be specified
  if exist "%DEPLOYMENT_TRANSFORMS%nuget.config" (
      copy "%DEPLOYMENT_TRANSFORMS%nuget.config" %1
  )

  if "%2"=="" (
    :: When the solution file is one level higher, restore from packages.config next to the .csproj by specifying the folder
    if exist "%1\packages.config" (
        call "%NUGET_EXE%" restore "%1\packages.config" -OutputDirectory "%1\..\packages" -NonInteractive
        goto exit
    ) 
  )  
  
  IF /I "%2" NEQ "" (
      :: Otherwise second parameter should be a solution file, useful when the solution file is in the same folder as the project file being built.
      :: Syntax like if /I "%NUGET_RESTORE_FROM:~-4%"==".sln" to check value was invalid on Kudu.
      call "%NUGET_EXE%" restore %1%2 -NonInteractive
      goto exit
  )

)

:exit
exit /b %ERRORLEVEL%