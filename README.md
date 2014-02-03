Escc.EastSussexGovUK.AzureDeployment
====================================

The East Sussex County Council website is hosted on [Azure Websites](www.windowsazure.com) and deployed using git.

Each application on the website has a separate git repository, but each Azure Website has a single git repository, so we have to combine our projects into a single git repository for deployment. We do this using [subtree merging](http://typecastexception.com/post/2013/03/16/Managing-Nested-Libraries-Using-the-GIT-Subtree-Merge-Workflow.aspx).

We then push the repository to Azure, where it is deployed by [Kudu](https://github.com/projectkudu/kudu). By default Kudu deploys only the first project it finds, so we use a [custom deployment script](http://blog.amitapple.com/post/38419111245/azurewebsitecustomdeploymentpart3) to deploy each project to a specific folder.

Our custom deployment script [runs unit tests before deployment](http://channel9.msdn.com/Shows/Windows-Azure-Friday/Custom-Web-Site-Deployment-Scripts-with-Kudu-with-David-Ebbo) using [NUnit](http://www.nunit.org/) and manages dependencies using [NuGet package restore](http://docs.nuget.org/docs/reference/package-restore).

Set up your deployment repository
---------------------------------

Clone this repository and then, from a command line, run the following command:

`SetupDeploymentRepo <directory to create> <git base URL>`

`<directory-to-create>` must be a full path which does not exist yet and is not inside an existing git repository.

`<git base url>` is a URL such as `https://github.com/east-sussex-county-council/` to which we can add a project name followed by `.git` to get a full repository URL.

This will create a new git repository in `<directory to create>` which includes every application on the East Sussex County Council website. You can then set up the Azure Website as a remote for that repository and push to it.

Update your deployment repository
---------------------------------

Run `git pull` on this repository to ensure you have the latest deployment scripts. Then, open a command line at the root of your deployment repository and run the following command:

`<path to this repository>\UpdateAll <git base URL>`

or, if you're sure only one application has changed, you can run this command:

`<path to this repository>\AddOrUpdateApp <git base URL> <git repo name>`

You can then push the deployment repository to Azure.

Note that you can't run the script from the copy of `Escc.EastSussexGovUK.AzureDeployment` which exists inside your deployment repository, because the process involves switching to branches where those scripts are not available.

Deploy a new application
------------------------

If you've created a new application for the website, you need to modify `UpdateAll.cmd` and `AzureKuduApplications.cmd` to include your application repository.

Commit and push the updated scripts, then follow the steps under 'Update your deployment repository'.
   