# EmsArmTemplates

This project contains the Azure ARM templates for EMS, as well as supporting infrastructure for testing and deploying the templates.

## Repository

This repository uses our standard powershell module strucutre, but isn't currently built or published to a PS gallery feed. It is intended to be used by cloning the repository or via pipelines in Azure DevOps.

* ARM templates can be found under the `EmsArmTemplates/Public/lib` directory.
* Powershell functionality to help build, test, or deploy the templates can be found in the `EmsArmTemplates/Public` directory.
* Tests for the module and generalized tests for the templates can be found under the `Tests` directory.
* An [Invoke-Build](https://github.com/nightroman/Invoke-Build) script is provided in the root with tasks for building, testing, publishing, and deploying templates, most of which are also exposed as VS code tasks.

## Templates

Templates are organized under `EmsArmTemplates/Public/lib`. They are are grouped by directory where each directory is a deployable chunk, and the following files are expected:

| File | Description |
| ---- | ----------- |
| deploy.json | The ARM template |
| deploy.parameters.json | A default ARM parameter file suitable for unit testing |

In addition, the templates can optionally contain the following sub directories and content types:

| Directory | Description |
| --------- | ----------- |
| linkedTemplates | Contains inner [linked](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates) templates for the primary ARM template. These are json files |
| DSC | Contains DSC configurations that are used in the template deployment. These are ps1 files |
| Scripts | Contains powershell scripts that are used in the template deployment. These are ps1 files |
| Tests | Contains Pester tests to run against the deployed template. These are ps1 files |

In order to simplify deployments we also provide a pair of templates in the root of the `lib` directory which orchestrate all of the individual templates to accomplish a certain goal:

* `common.json`: This template deploys all of the "common" resources that are shared amongst all tenants in a region. Deploying this template is the equivalent of setting up an entirely new region (or a different environment within an existing region). Examples include Tableau, a shared Redis cache, Active Directory, DFS shares, etc.
* `tenant.json`: This template deploys all of the "tenant" resources that are used by a single customer (this applies to both external customers like American Airlines and internal customers like GE Engine Services). Examples include an EMS manager VM, an EMS worker scale set, a tenant specific key-vault, etc.

In production we will only ever end up deploying these two `root` templates.

Each of the inner templates should abide by the following rules:
* The `deploy.json` file should create its own resource group if it needs one.
  * This allows it to be usable by `New-AzDeployment` as opposed to `New-AzResourceGroupDeployment`. All of the naming logic is part of the ARM templates so we don't want to have to create resource groups using powershell before deploying. For example, see the first resource in [this](https://dev.azure.com/flight-analytics/_git/EmsArmTemplates?path=%2FEmsArmTemplates%2FPublic%2Flib%2FEmsWorker%2Fdeploy.json&version=GBmaster) template (the one with the type `Microsoft.Resources/resourceGroups`).
  * It's easy to tell if this is *not* the case by searching for uses of the `resourceGroup()` function in the template. It should not be used in templates that are fed into `New-AzDeployment`.
* The template should remain individually deployable and testable. It might depend on other resources being available first, but we always need to allow someone to make edits and test deployments assuming the other resources are set up and correct.

## Parameters

The standard parlance for ARM template parameters is a JSON file that list the inputs for a deployment, so we make use of that in a couple of different ways.

Each inner template has a `deploy.parameters.json` file next to it which will be used for unit and deployment testing, and which can be copied and modified for one-off manual testing.

Each deployment we perform using a `root` ARM template should end up in source control in the [EmsArmDeployments](https://dev.azure.com/flight-analytics/EmsArmTemplates/_git/EmsArmDeployments?path=%2FREADME.md&version=GBmaster) repository. These are versioned separately to harden security in the event that someone accidentally includes a password (which should **NOT** be the case, but mistakes happen). See the README for that repository to get an idea of how it is organized and how to use it.

## Pipeline

The [azure-pipelines.yml](azure-pipelines.yml) file in the root of the repository defines the CI/CD pipeline for these templates. The build pipeline follows these rough steps:

* Zip DSC configurations in the DSC sub directories for each template.
* Mirror all content under `lib` to the [emsdstgemsarm001](https://portal.azure.com/#@gecompany.onmicrosoft.com/resource/subscriptions/5ab998b9-76f4-4e8f-9a05-0145759db801/resourceGroups/GAV-EMS-DEV-SRD-EUS-01/providers/Microsoft.Storage/storageAccounts/emsdstgemsarm001/containersList) blob storage account. Each branch of the repository is mirrored to a separate container. This step is necessary to update linked templates and DSC configurations for testing purposes.
* Run unit tests under `Tests` and report the results

## Tests

Currently the following tests are run for any template tha thas a `deploy.json` file:

* Validate that the `deploy.json` file is valid JSON
* Validate that a `deploy.parameters.json` file exists and is valid JSON
* Run `Test-AzDeployment` on the deployment file using the default parameters file

The following additional tests are run on the repository:

* Tests for powershell cmdlets in `EmsArmTemplates\Public`
* `PSScriptAnalyzer` checking for any powershell scripts or DSC in the module or used as part of a template

The folowwing tests are planned for the future:

* *TODO* Run a test deployment of `common.json` and `tenant.json` whenever templates in the master branch change.
* *TODO* Add smoke tests witten using `Pester` for each individual deployment and run them all when we do the integration test on master.
* *TODO* Make sure smoke tests can be used when a new region is deployed for the first time, or can be run ad-hoc after deployment to suss out issues.

## Deploying

While developing, and when performing QA on a template after its completion, there will be many cases where you want to manually deploy a template to test the functionality. Some VS code tasks are present in this repository to help, but short of locating files and selecting subscriptions the action that the deployment task performs is fairly simple:

```powershell
# Find the deploy.json file to deploy
$template = ...

# Find the parameters json file to use with the deployment
$parameters = ...

# Select the correct subscription
Select-AzSubscription "f5f66e56-3def-487a-a79a-246f79a23875"

# Run the deployment
New-AzDeployment -TemplateFile $template -TemplateParametersFile $parameters -Verbose
```

If you press F1 and select `Tasks: Run Tasks` in Visual Studio Code, a `Deploy Template` option should show up in the dropdown. It takes the following inputs:

| Parameter | Description |
| ---- | ----------- |
| Name | The name of the ARM template inside the `lib` directory. For example if I wanted to deploy the AD template, I would use the input `AD` |
| Parameter File | The template parameter file to use. By default this will search for a file with this name in the template's directory, so for example if I copied `deploy.parameters.json` in the template directory to `deploy.parameters.1.json`, the input would be `deploy.parameters.1.json` |
| Artifact Branch | The branch of the EmsArmTemplates repository to use for inner artifacts (`linkedTemplates`, `DSC`, `Scripts`, etc.). This maps onto a container name in [emsdstgemsarm001](https://portal.azure.com/#@gecompany.onmicrosoft.com/resource/subscriptions/5ab998b9-76f4-4e8f-9a05-0145759db801/resourceGroups/GAV-EMS-DEV-SRD-EUS-01/providers/Microsoft.Storage/storageAccounts/emsdstgemsarm001/containersList) |
| Subscription | The subscription to deploy the template to. The dropdown list in VS code is hard coded in the `.vscode\tasks.json` file if it needs to be updated |

## Release

A release pipeline doesn't currently exist, but it needs to be created. I think the idea here is that we want a release pipeline in Azure Devops that mirrors the `master` blob store to a `release` blob store. Then we need to update the default `_artifactsBranch` parameter on all of the templates to point to release instead of master.

*TODO*: Once we gain some confidence, we should build a release piepline that uses both `EmsArmTemplates` and `EmsArmDeployments` as artifacts, and re-applies all of the parameter files + templates.