:: Download test runner and run tests
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\NugetRestore" "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Escc.EastSussexGovUK.AzureDeployment.sln"
IF !ERRORLEVEL! NEQ 0 goto error

:: Test SeparateRepo.Tests
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\NugetRestore" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\BuildLibrary" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\RunTests" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication1
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\NugetRestore" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\BuildApplication" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1\WebApplication1.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\Sync" WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication2
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\BuildApplication" "%DEPLOYMENT_SOURCE%\WebApplication2\WebApplication2.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\Sync" WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

if exist "%DEPLOYMENT_SOURCE%\WebApplication2\web.config.example" (
  call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Kudu\BuildLibrary" "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Escc.EastSussexGovUK.AzureDeployment.ConfigTransform\Escc.EastSussexGovUK.AzureDeployment.ConfigTransform.csproj"
  IF !ERRORLEVEL! NEQ 0 goto error

  "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Escc.EastSussexGovUK.AzureDeployment.ConfigTransform\bin\Release\Escc.EastSussexGovUK.AzureDeployment.ConfigTransform.exe" "%DEPLOYMENT_SOURCE%\WebApplication2\web.config.example" "%DEPLOYMENT_TARGET%\WebApplication2\web.config"
  IF !ERRORLEVEL! NEQ 0 goto error
)

