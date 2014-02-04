:: Download test runner and run tests
call Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore Escc.EastSussexGovUK.AzureDeployment\Escc.EastSussexGovUK.AzureDeployment.sln
IF !ERRORLEVEL! NEQ 0 goto error

:: Test SeparateRepo.Tests
call Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore SeparateRepo.Tests\SeparateRepo.Tests.sln
IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureBuildLibrary SeparateRepo.Tests\SeparateRepo.Tests.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call packages\NUnit.Runners.2.6.3\tools\nunit-console SeparateRepo.Tests\SeparateRepo.Tests.csproj
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication1
call Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore WebApplication1\WebApplication1.sln
IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureBuildApplication WebApplication1\WebApplication1\WebApplication1.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureSync WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication2
call Escc.EastSussexGovUK.AzureDeployment\AzureBuildApplication WebApplication2\WebApplication2.csproj
IF !ERRORLEVEL! NEQ 0 goto error

call Escc.EastSussexGovUK.AzureDeployment\AzureSync WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

