param(
    [string] $BlobAccount = (property BlobAccount 'emsdstgemsarm001'),
    [string] $BlobContainer = (property BlobContainer 'dev'),
    [string] $BlobSubscription = (property BlobSubscription '114-GAV-CU-EMS-DEVQA' ),
    [string] $LibPath = "$BuildRoot\EmsArmTemplates\Public\lib",

    [string] $TemplateName,
    [string] $TemplateParameterFile = (property TemplateParameterFile 'deploy.parameters.json'),
    [string] $DeployLocation = (property DeployLocation 'eastus'),
    [string] $DeploySubscription = (property DeploySubscription '114-GAV-CU-EMS-DEVQA' ),
    [string] $ArtifactsBranch = (property ArtifactsBranch 'master'),
    [string] $ArtifactsLocation = (property ArtifactsLocation "https://$BlobAccount.blob.core.windows.net/$ArtifactsBranch/")
)

Task UnitTest {
    $locationSave = $env:ArtifactsLocation
    try {
        $env:ArtifactsLocation = $ArtifactsLocation.ToLower()
        Push-Location "$BuildRoot/Tests"
        $coverageFiles = Get-ChildItem "$BuildRoot/EmsArmTemplates/Public" -File -Filter '*.ps1' | Select-Object -ExpandProperty FullName
        $result = Invoke-Pester -Tag "Unit" -PassThru -OutputFormat NUnitXml -OutputFile "$BuildRoot/Tests/UnitTestResults.xml" `
            -CodeCoverage $coverageFiles -CodeCoverageOutputFile "$BuildRoot/Tests/CodeCoverage.xml" -Verbose

        if ( $result.FailedCount ) {
            Write-Build Red "There were $($result.FailedCount) unit test failures."
        }
    }
    finally {
        $env:ArtifactsLocation = $locationSave
        Pop-Location
    }
}

Task IntegrationTest {
    $locationSave = $env:ArtifactsLocation
    try {
        $env:ArtifactsLocation = $ArtifactsLocation.ToLower()
        Push-Location "$BuildRoot/Tests"
        $result = Invoke-Pester -Tag 'Integration' -PassThru -OutputFormat NUnitXml -OutputFile "$BuildRoot/Tests/IntegrationTestResults.xml" -Verbose
        if ( $result.FailedCount ) {
            Write-Build Red "There were $($result.FailedCount) integration test failures."
        }
    }
    finally {
        $env:ArtifactsLocation = $locationSave
        Pop-Location
    }
}

Task BuildZips {
    $dscDirs = Get-ChildItem $LibPath -Directory -Recurse | Where Name -eq 'DSC'
    foreach ( $dir in $dscDirs ) {
        $configs = Get-ChildItem $dir.FullName -Filter "*.ps1"
        foreach ( $config in $configs ) {
            $zipOutput = "$($config.FullName).zip"
            $relative = $config.FullName.Replace( "$LibPath\", '' )
            Write-Build Yellow "Zipping $relative..."
            if ( Get-Command 'Publish-AzVMDscConfiguration' -ErrorAction SilentlyContinue ) {
                Publish-AzVMDscConfiguration $config.FullName -OutputArchivePath $zipOutput -Force -ErrorAction Stop
            }
            else {
                Publish-AzureRMVMDscConfiguration $config.FullName -OutputArchivePath $zipOutput -Force -ErrorAction Stop
            }
        }
    }
}

Task PublishToBlob {
    Import-Module "$BuildRoot\EmsArmTemplates"
    if ( Get-Command Get-AzContext -ErrorAction SilentlyContinue ) {
        if ( -not ( Get-AzContext ) ) {
            throw "An Az login context is required to publish to blob."
        }
    }
    else {
        if ( -not ( Get-AzureRMContext ) ) {
            throw "An AzureRM login context is required to publish to blob."
        }
    }

    if ( $BlobSubscription ) {
        Select-EmsArmAzSubscription $BlobSubscription
    }

    Copy-EmsDirectoryToAzureBlob -StorageAccountName $BlobAccount -ContainerName $BlobContainer -SourceDirectory $LibPath -CreateContainer -Verbose
}

Task DeployTemplate {
    if ( -not $TemplateName ) {
        throw "The name of a template must be specified in order to deploy."
    }

    # Is the name a file in the root library dir?
    $test = "$LibPath\$TemplateName.json"
    if ( Test-Path $test ) {
        $templateDir = $LibPath
        $templateFile = $test
    }
    else {
        $templateDir = Join-Path $LibPath $TemplateName
        $templateFile = Join-Path $templateDir 'deploy.json'
    }

    if ( -not ( Test-Path $templateFile ) ) {
        throw "Could not locate a template file from the given name '$TemplateName'"
    }

    # If this is a full path we want to use it, if it's only a file name we want to find it in the template's directory.
    if ( -not ( Test-Path $TemplateParameterFile ) ) {
        $parameterPath = Join-Path $templateDir $TemplateParameterFile
        if ( -not ( Test-Path $parameterPath ) ) {
            throw "Expected to find the template parameter file at $parameterPath but it does not exist."
        }
        $TemplateParameterFile = $parameterPath
    }

    $deployArgs = @{
        Name                  = ((Get-Date -Format s).Replace(':', '-'))
        TemplateFile          = $templateFile
        TemplateParameterFile = $TemplateParameterFile
        Location              = $DeployLocation
    }

    Write-Build Yellow "Deploying $templateFile using parameters $TemplateParameterFile..."

    $hasArtifactsBranch = ((Get-Content $templateFile -Raw | ConvertFrom-Json).parameters._artifactsBranch -ne $null)
    if ( $hasArtifactsBranch ) {
        $deployArgs.Add( '_artifactsBranch', $ArtifactsBranch.ToLower() )
    }

    if ( $DeploySubscription ) {
        Import-Module "$BuildRoot\EmsArmTemplates"
        Select-EmsArmAzSubscription $DeploySubscription
    }

    if ( Get-Command 'New-AzDeployment' -ErrorAction SilentlyContinue ) {
        New-AzDeployment @deployArgs -Verbose
    }
    else {
        New-AzureRMDeployment @deployArgs -Verbose
    }
}