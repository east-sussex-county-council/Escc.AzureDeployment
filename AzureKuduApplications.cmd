
:: 2. Build and sync WebApplication1
call %ESCC_DEPLOYMENT_SCRIPTS%AzureNugetRestore WebApplication1\WebApplication1.sln
IF !ERRORLEVEL! NEQ 0 goto error

REM Run tests
REM packages\NUnit.Runners.2.6.3\tools\nunit-console nunit.tests\nunit.tests.csproj
REM IF !ERRORLEVEL! NEQ 0 goto error


call %ESCC_DEPLOYMENT_SCRIPTS%AzureBuildLibrary SeparateRepo\SeparateRepoProjectDependency.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call %ESCC_DEPLOYMENT_SCRIPTS%AzureBuildApplication WebApplication1\WebApplication1\WebApplication1.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call %ESCC_DEPLOYMENT_SCRIPTS%AzureSync WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. Build and sync WebApplication2
call %ESCC_DEPLOYMENT_SCRIPTS%AzureBuildApplication WebApplication2\WebApplication2.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call %ESCC_DEPLOYMENT_SCRIPTS%AzureSync WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

