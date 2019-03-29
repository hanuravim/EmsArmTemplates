# Deploy the Resource Group & Storage Account
$deploy = New-AzureRmDeployment -Location SouthCentralUS -TemplateParameterFile .\deploy_Network_Common.parameters.json -TemplateFile .\deploy_Customer.json -Verbose

# Retrieve the Storage Account details
$resourceGroup = $deploy.Outputs.Values.value[0]
$storageAccountName = $deploy.Outputs.Values.value[1]
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $storageAccountName).Value[0]

# Deploy the Azure File Share
$storageContext = New-AzureStorageContext $storageAccountName $storageAccountKey
$share = New-AzureStorageShare logs -Context $storageContext
