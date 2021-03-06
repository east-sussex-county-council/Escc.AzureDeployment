:: -----------------------------------------------
:: Build, test and configure applications on Azure
:: -----------------------------------------------
::
:: To restore Nuget dependencies from a solution file:
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %DEPLOYMENT_SOURCE%\ExampleProject\ ExampleProject.sln
::     IF !ERRORLEVEL! NEQ 0 goto error
:: 
:: or, to restore packages for a single project:
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %DEPLOYMENT_SOURCE%\ExampleProject\ packages.config
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::
:: To run unit tests with NUnit:
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\RunTests" %DEPLOYMENT_SOURCE%\ExampleProject.Tests\ ExampleProject.Tests.csproj
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::
:: To download, build and sync an application, and merge in its Azure configuration settings:
::
::    call "%ESCC_DEPLOYMENT_SCRIPTS%\GitDownload" WebApplication1 v1.0.0
::    IF !ERRORLEVEL! NEQ 0 goto error

::     call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile" %DEPLOYMENT_SOURCE%\ExampleLibrary\ ExampleLibrary.csproj
::     IF !ERRORLEVEL! NEQ 0 goto error

::     call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfigFromExample" ExampleProject\web
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\ExampleProject\ ExampleProject.csproj
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" ExampleProject
::     IF !ERRORLEVEL! NEQ 0 goto error
::
:: -----------------------------------------------


:: Test SeparateRepo.Tests

call "%ESCC_DEPLOYMENT_SCRIPTS%\GitDownload" SeparateRepo.Tests v1.0.0
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.sln
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\RunTests" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication1

call "%ESCC_DEPLOYMENT_SCRIPTS%\GitDownload" WebApplication1 v1.0.0
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1\ WebApplication1.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication2

call "%ESCC_DEPLOYMENT_SCRIPTS%\GitDownload" WebApplication2 v1.0.0
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\WebApplication2\ WebApplication2.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfigFromExample" WebApplication2\web
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error
