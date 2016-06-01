# Deploy_Demo.ps1
# Tested using Microsoft Azure PowerShell 1.4.0
#######################################################

Param(
    # The Subscription ID of the Azure Subscription you want to use.
    [string] [Parameter(Mandatory=$true)] $subscriptionId,
    
    # The Resource Group Name you want to deploy your resources in
    [string] $resourceGrpName = 'TM-Demo'
)

Set-StrictMode -Version 3

# The Resource Group and deployment storage account Location
$resourceGrpLoc = "West US"

$artifactStagingDir = ".\TM-Demo-Solution"
$artifactStagingDir = [System.IO.Path]::Combine($PSScriptRoot, $artifactStagingDir)
New-Item $artifactStagingDir -ItemType Directory -Force

# Sign-in to your Azure Subscription
Login-AzureRmAccount -SubscriptionId $subscriptionId -ErrorAction Stop

# Create a unique name for a storage account to be used only for deployment
do {
    $deployStgAcctName = [Guid]::NewGuid().ToString()
    $deployStgAcctName = $deployStgAcctName.Replace("-", "").Substring(0, 23)
    $isAvail = Get-AzureRmStorageAccountNameAvailability `
        -Name $deployStgAcctName | Select-Object -ExpandProperty NameAvailable
} while (!$isAvail)

# Create the deplpoyment storage account in it's own resource group 
$deployStgAcctRGName = $resourceGrpName + "-Deploy"
New-AzureRmResourceGroup -Name $deployStgAcctRGName -Location $resourceGrpLoc -Verbose -Force -ErrorAction Stop
New-AzureRmStorageAccount -ResourceGroupName $deployStgAcctRGName `
    -Type Standard_LRS `
    -Location $resourceGrpLoc `
    -Name $deployStgAcctName `
    -Verbose

# Create the resource group for the SAP deployment
New-AzureRmResourceGroup -Name $resourceGrpName -Location $resourceGrpLoc -Verbose -Force -ErrorAction Stop

# Deploy the resources for the SAP deployment
$deployResourcesScriptPath = ".\TM-Demo-Solution\TM-Demo\Scripts\Deploy-AzureResourceGroup.ps1"
$deployResourcesScriptPath = [System.IO.Path]::Combine($PSScriptRoot, $deployResourcesScriptPath)
& $deployResourcesScriptPath `
	-ResourceGroupLocation $resourceGrpLoc `
    -ResourceGroupName $resourceGrpName `
    -UploadArtifacts `
    -StorageAccountName $deployStgAcctName `
    -ArtifactStagingDirectory $artifactStagingDir

# If running in the console (not the ISE), wait for input before closing.
if ($Host.Name -eq "ConsoleHost")
{
    Write-Host "Press any key to continue..."
    $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp") > $null
}
