Escc.AzureDeployment
====================

This is a scripted deployment process for websites hosted on [Azure web apps](www.windowsazure.com) and deployed using git. We use it for [the East Sussex County Council website](https://www.eastsussex.gov.uk).

Each application on a large website has a separate git repository, but each Azure Website has a single git repository, so we can't deploy our website simply by deploying the original git repository. Instead we create a repository containing just a deployment script. We then push the repository to Azure, where it is deployed by [Kudu](https://github.com/projectkudu/kudu). By default Kudu deploys only the first project it finds, so we use a [custom deployment script](http://blog.amitapple.com/post/38419111245/azurewebsitecustomdeploymentpart3).

The deployment script downloads individual repositories from git, using git tags to ensure that each version of the deployment script will deploy a consistent version of each application, based on a specific tagged commit, every time it is run. 

Our custom deployment script:

* can [run unit tests before deployment](http://channel9.msdn.com/Shows/Windows-Azure-Friday/Custom-Web-Site-Deployment-Scripts-with-Kudu-with-David-Ebbo) using [NUnit](http://www.nunit.org/)
* manages dependencies using [NuGet package restore](http://docs.nuget.org/docs/reference/package-restore)
* signs assemblies using MSBuild and XSL to point to our strong name key
* manages secrets using [web.config transforms](http://msdn.microsoft.com/en-us/library/dd465326.aspx)
* deploys each project to a specific folder.


## How to configure and use Escc.AzureDeployment for a new website

Create a new git repository in a sibling folder of Escc.AzureDeployment, and run the following command to copy bootstrap code from this project into your new repository:

`..\Escc.AzureDeployment\UpdateDeploymentScript.cmd`

Create a file called `DeployOnAzure.cmd`, which will be the custom Kudu deployment script for your website. (See below for more on how to write `DeployOnAzure.cmd`.) When you're ready to test your script:

* Ensure you have committed your changes to your local repository.
* In the Azure portal for your web app, click "Set up deployment from source control" and select "Local Git repository". Note that your `wwwroot` folder should be empty when you do this, as any files there will be included in the repository.
* Set up the git URL for your Azure web app as a remote for your local repository using `git remote add <remote-name> <git-url>`
* Push your local repository to the remote using `git push <remote-name> master`. Kudu will then run your deployment script, and the Azure portal will show a deployment in progress.

Each time you update `DeployOnAzure.cmd`, for example to add a new application, commit your changes and  push your repository again to your remote on Azure.

If you ever need to update your script to use a newer version of `Escc.AzureDeployment`, you can just run `..\Escc.AzureDeployment\UpdateDeploymentScript.cmd` again from your repository.

## Writing a custom Kudu deployment script for Azure

When you push your changes to Azure, Kudu will run your `DeployOnAzure.cmd` script to build and deploy your website. You can use scripts from this project to perform common tasks.

### Download your application from git

	call "%ESCC_DEPLOYMENT_SCRIPTS%\GitDownload" <repository> <tag>
	IF !ERRORLEVEL! NEQ 0 goto error

This downloads an individual repository from git, referencing a git tag so that any given version of your deployment script will use the same specific tagged commit of your application every time it is run.

The `<repository>` parameter is not a full git repository URL, but the part that identifies a specific repository on your git server. This is combined with the `ESCC_GIT_URL_PREFIX` and `ESCC_GIT_URL_SUFFIX` environment variables to create a full repository URL. You can set environment variables in the app settings section of the Configure page for your web app in the Azure management portal, or directly in your deployment script. 

For example, to download this project from GitHub:

- `ESCC_GIT_URL_PREFIX` should be `https://github.com/east-sussex-county-council/`
- Your call to `GitDownload` would specify `Escc.AzureDeployment` as the repository
- `ESCC_GIT_URL_SUFFIX` should be `.git`

These would be combined into a git URL of `https://github.com/east-sussex-county-council/Escc.AzureDeployment.git`.

### Restore the NuGet packages for your application

You can restore NuGet packages by referencing either a `packages.config` file or a Visual Studio solution.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" <path-to-packages-file> <packages-filename> <packages-folder>
	IF !ERRORLEVEL! NEQ 0 goto error

* `<path-to-packages-file>` is the folder containing `packages.config` or the `.sln`. file. For example, `%DEPLOYMENT_SOURCE%\ExampleProject\`.
* `<packages-filename>` is either `packages.config` or the `.sln`. file.
* `<packages-folder>` is optional, and specifies the parent folder in which a `packages` folder should be created.

Unfortunately NuGet package restore is not the same as a NuGet install. [Package restore doesn't restore content files](http://jeffhandley.com/archive/2013/12/09/nuget-package-restore-misconceptions.aspx), and it doesn't apply the configuration transforms in a NuGet package either.

The workaround for restoring content files is to include a `.targets` file in a `build` folder inside your NuGet package. This is picked up by MSBuild when the project is built, and can be used to copy files from the `packages` folder into the project root just in time for the compilation process to use them.

This example `.targets` file copies the views from `ExampleMvcPackage` into the project root. Note that the version number of the NuGet package is specified here and must be kept up-to-date as the package version changes. Note also that the target name, `ExampleMvcPackage_CopyFiles`, must be unique to your package. If you add two NuGet packages to the same project which share the same target name, you'll get hard-to-debug errors where one target overrides another, acting on files which seem unconnected to it. 

	<?xml version="1.0" encoding="utf-8"?>
	<Project ToolsVersion="4.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
	  <ItemGroup>
	    <ExampleMvcPackage_Views Include="$(MSBuildProjectDirectory)\..\packages\ExampleMvcPackage.1.0.0\Content\Views\**\*.*"/>
	  </ItemGroup>
	
	  <Target Name="ExampleMvcPackage_CopyFiles" BeforeTargets="PrepareForBuild">
	    <Message Text="Copying ExampleMvcPackage files to Views" />
	    <Copy
	        SourceFiles="@(ExampleMvcPackage_Views)"
	        DestinationFiles="@(ExampleMvcPackage_Views->'.\Views\%(RecursiveDir)%(Filename)%(Extension)')"
	        />
	  </Target>
	</Project>

### Run tests

This project makes the NUnit test runner available in your Azure environment, by using NuGet to restore a solution that contains only the `NUnit.Runners.2.6.3` package. You can use the `RunTests` command to run your tests. If your tests fail, the build will stop at that point.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\RunTests" %DEPLOYMENT_SOURCE%\ExampleProject.Tests\ ExampleProject.Tests.csproj
	IF !ERRORLEVEL! NEQ 0 goto error

### Configuration settings

For each `web.config` file we include it in the Visual Studio project with a build action of Content, but exclude it from our git repository. Instead we commit a `web.example.config` file with a build action of None, and secrets removed. This file typically needs to be different in the live environment, so we upload a [web.config transform](http://msdn.microsoft.com/en-us/library/dd465326.aspx) on to a directory on Azure. 

We then put the path to that directory into a `DEPLOYMENT_TRANSFORMS` app setting on the Configure page in the management portal for the Azure Website, so that the Kudu deployment script can find it. When your build script runs it will make a copy of that directory tied to the specific commit of the build script. This makes the redeploy function in Azure websites work, because a specific deployment will always go back to a copy of the `DEPLOYMENT_TRANSFORMS` directory as it was at the time the script was originally run.

To transform the `web.example.config` at the root of the `ExampleProject` folder, put the `Web.Release.config` into an `ExampleProject` folder inside `DEPLOYMENT_TRANSFORMS`. You then need to add the `TransformConfigFromExample` command to your `DeployOnAzure.cmd` file, leaving off the `.config` part of the filename.

    call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfigFromExample" %DEPLOYMENT_SOURCE%\ExampleProject\web  %DEPLOYMENT_TRANSFORMS%\ExampleProject\%1.Release.config
	IF !ERRORLEVEL! NEQ 0 goto error

If no `web.example.config` file is present at the destination but there is a `web.config` (for example, installed by a NuGet package) then that file will be transformed by `Web.Release.config` instead.

You can also use a `TransformConfig` command to apply other transforms to an existing configuration file.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfig" %DEPLOYMENT_SOURCE%\ExampleProject\web.config %DEPLOYMENT_TRANSFORMS%\ExampleProject\my-custom-transform.config
	IF !ERRORLEVEL! NEQ 0 goto error

If your application runs in a separate IIS application scope below an [Umbraco](http://umbraco.com/) installation, you need to override or remove some of the settings inherited from Umbraco's `web.config`. You can do that with the `TransformConfigToWorkBelowUmbraco` command.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformConfigToWorkBelowUmbraco" %DEPLOYMENT_SOURCE%\ExampleProject\web.config
	IF !ERRORLEVEL! NEQ 0 goto error

Note that the paths for these commands aren't quoted, which means they can't contain spaces.

### Building your application

The following command will build your application by referencing the `.csproj` file and the folder where it is found. It includes a call to `TransformProjectFile`, which handles some of the potential problems below.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\BuildApplication" %DEPLOYMENT_SOURCE%\ExampleProject\ ExampleProject.csproj
	IF !ERRORLEVEL! NEQ 0 goto error

There are a number of reasons why your application may fail to build.

#### Strong named assemblies

We give some of our assemblies a strong name, but the path to the strong name key file needs to be different on Azure. We upload our key file to a directory on Azure and put the path into a `DEPLOYMENT_STRONG_NAME_KEY` app setting on the Configure page in the management portal for the Azure Website. `TransformProjectFile` runs automatically on build, and will update the strong name based on that setting.

#### Project references 

If you have project references within your solution, you need to organise your `DeployOnAzure.cmd` file in the order assemblies need to be built. Use `GitDownload` to download a dependent library and run `NuGetRestore` and `TransformProjectFile`  on the library before building the application that depends upon it.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\GitDownload" ExampleLibrary ExampleTag
	IF !ERRORLEVEL! NEQ 0 goto error

	call "%ESCC_DEPLOYMENT_SCRIPTS%\NugetRestore" %DEPLOYMENT_SOURCE%\ExampleLibrary\ packages.config
	IF !ERRORLEVEL! NEQ 0 goto error

	call "%ESCC_DEPLOYMENT_SCRIPTS%\TransformProjectFile" %DEPLOYMENT_SOURCE%\ExampleLibrary\ ExampleLibrary.csproj
	IF !ERRORLEVEL! NEQ 0 goto error

#### Direct references to DLLs

If you have a reference directly to a DLL that file is unlikely to be in your git repository. Make a NuGet package for the DLL and reference it that way. 

#### Changes to project files

If you need to alter your `.csproj` file to get it to build, create an XSLT file with the same name as your `.csproj` file, eg `MyApp.csproj.xslt`, and include it in your git repository. Here's an example:

    <?xml version="1.0" encoding="utf-8"?>
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
         xmlns="http://schemas.microsoft.com/developer/msbuild/2003"
         xmlns:msbuild="http://schemas.microsoft.com/developer/msbuild/2003">
        <xsl:output method="xml" indent="yes"/>

        <!-- TransformProjectFile.xslt is from Escc.AzureDeployment and will be copied into this folder at deploy time  -->
        <xsl:include href="TransformProjectFile.xslt"/>

		<!-- This xsl:template is just an example, not a requirement -->
        <xsl:template match="msbuild:Project/msbuild:ItemGroup/msbuild:Reference/msbuild:HintPath">
            <!-- Do something with the HintPath -->
        </xsl:template>
    </xsl:stylesheet>

This XSLT file will be used to update the `.csproj` project file before it is built.

#### Missing files

Any file which is part of your Visual Studio project but excluded from your git repository will cause a build error when the project is built on Azure. You can prevent this by setting its Build Action to None in the Properties panel in Visual Studio, or have the build script create the file before you build.

### Deploy your application to the web root

Use Kudu Sync to deploy your application.

	call "%ESCC_DEPLOYMENT_SCRIPTS%\Sync" ExampleSite
	IF !ERRORLEVEL! NEQ 0 goto error

The build action for each file in the Visual Studio project controls whether it will be copied to the web root. If the build action is set to Content it will be copied, whereas None means it will not. Any files which have a different build action (for example, `.cs` files are set to Compile) should be left alone. Check the Properties panel in Visual Studio for each file in your project to make sure it has the correct setting.

## Delete an obsolete application

Follow these steps to completely remove an application from the website:

1.	Remove references to the application from `DeployOnAzure.cmd`  and push your repository to your remote on Azure.
3.	Commit and push your changes to your master git repository.
4.	Use FTP to connect to Azure and delete the application folder.
5.	Delete any related resources such as databases and storage containers.
6.	On the Configure tab in the Azure Portal, remove any application settings, connection strings, virtual applications and directories associated with the application.
7.	Set up 301 redirects to replacement content if appropriate.
