
:: 2. Build and sync WebApplication1
call Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore WebApplication1\WebApplication1.sln
IF !ERRORLEVEL! NEQ 0 goto error

REM Run tests
REM packages\NUnit.Runners.2.6.3\tools\nunit-console nunit.tests\nunit.tests.csproj
REM IF !ERRORLEVEL! NEQ 0 goto error


REM call Escc.EastSussexGovUK.AzureDeployment\AzureBuildLibrary SeparateRepo\SeparateRepoProjectDependency.csproj
REM IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureBuildApplication WebApplication1\WebApplication1\WebApplication1.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureSync WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: 2. Build and sync WebApplication2
call Escc.EastSussexGovUK.AzureDeployment\AzureBuildApplication WebApplication2\WebApplication2.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureSync WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

