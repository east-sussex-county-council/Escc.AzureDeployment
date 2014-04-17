Escc.AzureDeployment
====================

This is a scripted deployment process for websites hosted on [Azure Websites](www.windowsazure.com) and deployed using git. We use it for [the East Sussex County Council website](https://www.eastsussex.gov.uk).

Each application on a large website has a separate git repository, but each Azure Website has a single git repository, so we have to combine our projects into a single git repository for deployment. We do this using [subtree merging](http://typecastexception.com/post/2013/03/16/Managing-Nested-Libraries-Using-the-GIT-Subtree-Merge-Workflow.aspx).

We then push the repository to Azure, where it is deployed by [Kudu](https://github.com/projectkudu/kudu). By default Kudu deploys only the first project it finds, so we use a [custom deployment script](http://blog.amitapple.com/post/38419111245/azurewebsitecustomdeploymentpart3) to deploy each project to a specific folder.

Our custom deployment script:

* [runs unit tests before deployment](http://channel9.msdn.com/Shows/Windows-Azure-Friday/Custom-Web-Site-Deployment-Scripts-with-Kudu-with-David-Ebbo) using [NUnit](http://www.nunit.org/)
* manages dependencies using [NuGet package restore](http://docs.nuget.org/docs/reference/package-restore)
* signs assemblies using MSBuild and XSL to point to our strong name key
* manages secrets using [web.config transforms](http://msdn.microsoft.com/en-us/library/dd465326.aspx)
* encrypts `appSettings` and `connectionStrings` in `web.config` using [aspnet_regiis](http://msdn.microsoft.com/en-us/library/ff647398.aspx).

Combine multiple applications into a single git repository
---------------------------------------------------------- 

### Set up Escc.AzureDeployment for a new website

Create a new git repository in a sibling folder of Escc.AzureDeployment. Copy the contents of the `ExampleSite` folder from this project and customise them for your site. (See 'Configure deployment on Azure using Kudu' below for more on how to write `DeployOnAzure.cmd`.) Push the repository to source control so that the deployment scripts can update it from there.

Next, set up your deployment repository as described below.

### Set up your deployment repository

Clone this repository, then open a command line in a new, empty directory where you want to create the deployment repository:

`<path to this repository>\SetupDeploymentRepo <git base URL>` `<site scripts folder>`

`<git base url>` is a URL such as `https://github.com/east-sussex-county-council/` to which we can add a project name to get a full repository URL.

`<site scripts folder>` is the name of the sibling folder of this repository containing the scripts for the site to set up (see above).

This will create a new git repository which includes every application from all the separate repositories which make up the website. You can then set up the Azure Website as a remote for that repository and push to it.

### Update your deployment repository

Open a command line at the root of your deployment repository and run the following command:

`<path to this repository>\UpdateAll <git base URL>`

or, if you're sure only one application has changed, you can run this command:

`<path to this repository>\AddOrUpdateApp <git base URL> <git repo name>`

You can then push the deployment repository to Azure.

Note that you can't run the script from the copy of `Escc.AzureDeployment` which exists inside your deployment repository, because the process involves switching to branches where those scripts are not available.

#### A shortcut

You can make it easier to update your repository by creating a batch file somewhere in your path with the following line. Replace `<path to this repository>`, `<git base URL>` and `<site scripts folder>` with the correct values for your environment.

`@<path to this repository>\UpdateAll <git base URL>` `<site scripts folder>`

You can then simply type `UpdateAll` in the root directory of your deployment repository.


### Deploy a new application

If you've created a new application for the website, you need to modify `UpdateDeploymentRepo.cmd` and `DeployOnAzure.cmd` to include your application repository.

Commit and push the updated scripts, then follow the steps under 'Update your deployment repository'.

### Delete an obsolete application

Follow these steps to completely remove an application from the website:

1.	Remove references to the application from `DeployOnAzure.cmd` in this repository, and move it from the 'Add or update' to the 'Delete' section of `UpdateDeploymentRepo.cmd`. Commit and push your changes.
2.	Update your deployment repository using `UpdateAll` as described in 'Update your deployment repository' above.
3.	Use FTP to connect to Azure and delete the application folder.
4.	Delete any related resources such as databases and storage containers.
5.	On the Configure tab in the Azure Portal, remove any application settings, connection strings, virtual applications and directories associated with the application.
6.	Set up 301 redirects to replacement content if appropriate.

## Configure deployment on Azure using Kudu

When you push your changes to Azure, Kudu will run your `DeployOnAzure.cmd` script to build and deploy your website. 

### Run tests

Use Nuget to add the `NUnit.Runners.2.6.3` package to your solution, or create a solution just for your tests and add it there. In your copy of `DeployOnAzure.cmd` use the `NugetRestore` command on the solution to install the test runner in the Azure environment, then use the `RunTests` command to run your tests. Examples of both commands are in  `ExampleSite\DeployOnAzure.cmd`. If your tests fail, the build will stop at that point.

### Strong named assemblies

We give some of our assemblies a strong name, but the path to the strong name key file needs to be different on Azure. We upload our key file to a directory on Azure and put the path into a `DEPLOYMENT_STRONG_NAME_KEY` app setting on the Configure page in the management portal for the Azure Website. The Kudu deployment script will find and apply it automatically from there.

### References which don't use NuGet

If you have project references within your solution, you need to organise your `DeployOnAzure.cmd` file in the order assemblies need to be built. For example, build a dependent library before building the application that depends upon it.

If you have a reference directly to a DLL that file is unlikely to be in your git repository. Instead,  upload the file to a directory on Azure and put the path into a `DEPLOYMENT_TRANSFORMS` app setting on the Configure page in the management portal for the Azure Website. Then, create an XSLT file with the same name as your `.csproj` file, eg `MyApp.csproj.xslt` and include it in your git repository. Here's an example:

    <?xml version="1.0" encoding="utf-8"?>
    <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
         xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl"
         xmlns="http://schemas.microsoft.com/developer/msbuild/2003"
         xmlns:msbuild="http://schemas.microsoft.com/developer/msbuild/2003">
        <xsl:output method="xml" indent="yes"/>

        <!-- TransformProjectFile.xslt is from Escc.AzureDeployment and will be copied into this folder at deploy time  -->
        <xsl:include href="TransformProjectFile.xslt"/>

        <xsl:template match="msbuild:Project/msbuild:ItemGroup/msbuild:Reference/msbuild:HintPath">
            <xsl:call-template name="UpdateHintPath">
                <xsl:with-param name="ref_1" select="'Example1.dll'" />
                <xsl:with-param name="ref_2" select="'Example2.dll'" />
            </xsl:call-template>
        </xsl:template>
    </xsl:stylesheet>

This XSLT file will be run against the `.csproj` project file before it is built, changing the path for the referenced DLLs to the path in your `DEPLOYMENT_TRANSFORMS` app setting. 

You can add any other XSLT changes you want to make to the project file in here too.

### Files excluded from your git repository

Any files which are part of your Visual Studio project but excluded from your git repository (`web.config` for example) should have their Build Action set to None to avoid a build error when the project is built on Azure.

### Configuration settings

For each `web.config` file we exclude it from our git repository, and instead commit a `web.example.config` file with secrets removed. This file typically needs to be different in the live environment, so we upload a [web.config transform](http://msdn.microsoft.com/en-us/library/dd465326.aspx) on to a directory on Azure. 

We then put the path to that directory into a `DEPLOYMENT_TRANSFORMS` app setting on the Configure page in the management portal for the Azure Website, so that the Kudu deployment script can find it.

The folder structure mimics the repository folder structure, so to transform the `web.example.config` at the root of the `ExampleSite` folder, put the `Web.Release.config` into an `ExampleSite` folder inside `DEPLOYMENT_TRANSFORMS`. You then need to add the `TransformWebConfig` command to your `DeployOnAzure.cmd` file.

 