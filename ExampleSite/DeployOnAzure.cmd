:: -----------------------------------------------
:: Build, test and configure applications on Azure
:: -----------------------------------------------
::
:: To restore dependencies from Nuget:
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" "%DEPLOYMENT_SOURCE%\ExampleProject\ExampleProject.sln"
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::
:: To run unit tests with NUnit:
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\RunTests" "%DEPLOYMENT_SOURCE%\ExampleProject.Tests\ExampleProject.Tests.csproj"
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::
:: To build and sync an application, and merge in its Azure configuration settings:
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile" %DEPLOYMENT_SOURCE%\ExampleLibrary\ ExampleLibrary.csproj
::     IF !ERRORLEVEL! NEQ 0 goto error

::     call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\ExampleProject\ ExampleProject.csproj
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" ExampleProject
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::     call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformWebConfig" ExampleProject
::     IF !ERRORLEVEL! NEQ 0 goto error
::
::
:: To encrypt web.config sections other that appSettings and connectionStrings, which are done by TransformWebConfig:
::
::     aspnet_regiis -pef myConfigSection ""%DEPLOYMENT_TARGET%\ExampleProject"
::
:: -----------------------------------------------


:: Test SeparateRepo.Tests

call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\RunTests" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication1

call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1\ WebApplication1.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication2

call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\WebApplication2\ WebApplication2.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformWebConfig" WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error
