:: Download test runner and run tests
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore" "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Escc.EastSussexGovUK.AzureDeployment.sln"
IF !ERRORLEVEL! NEQ 0 goto error

:: Test SeparateRepo.Tests
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureBuildLibrary" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureRunTests" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj" /config=Release /framework=net-4.5
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication1
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureNugetRestore" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureBuildApplication" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1\WebApplication1.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureSync" WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication2
call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureBuildApplication" "%DEPLOYMENT_SOURCE%\WebApplication2\WebApplication2.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureSync" WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

if exist "%DEPLOYMENT_SOURCE%\WebApplication2\web.config.example" (
  call "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\AzureBuildLibrary" "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\Escc.EastSussexGovUK.AzureDeployment.csproj"
  IF !ERRORLEVEL! NEQ 0 goto error

  copy "%DEPLOYMENT_SOURCE%\WebApplication2\web.config.example" "%DEPLOYMENT_SOURCE%\WebApplication2\web.config"
  "%DEPLOYMENT_SOURCE%\Escc.EastSussexGovUK.AzureDeployment\bin\Release\Escc.EastSussexGovUK.AzureDeployment.exe" "%DEPLOYMENT_SOURCE%\WebApplication2\web.config"
  copy "%DEPLOYMENT_SOURCE%\WebApplication2\web.config" "%DEPLOYMENT_TARGET%\WebApplication2\web.config"
  del "%DEPLOYMENT_SOURCE%\WebApplication2\web.config"
)
IF !ERRORLEVEL! NEQ 0 goto error

