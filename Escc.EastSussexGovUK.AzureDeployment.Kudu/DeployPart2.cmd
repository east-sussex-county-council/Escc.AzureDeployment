:: Test SeparateRepo.Tests

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\NugetRestore" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\RunTests" "%DEPLOYMENT_SOURCE%\SeparateRepo.Tests\SeparateRepo.Tests.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication1

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\NugetRestore" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1.sln"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\BuildApplication" "%DEPLOYMENT_SOURCE%\WebApplication1\WebApplication1\WebApplication1.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\Sync" WebApplication1
IF !ERRORLEVEL! NEQ 0 goto error

:: Build and sync WebApplication2

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\BuildApplication" "%DEPLOYMENT_SOURCE%\WebApplication2\WebApplication2.csproj"
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\Sync" WebApplication2
IF !ERRORLEVEL! NEQ 0 goto error

call "%ESCC_DEPLOYMENT_SCRIPTS%\Escc.EastSussexGovUK.AzureDeployment.Kudu\TransformConfig WebApplication2
  IF !ERRORLEVEL! NEQ 0 goto error
)
