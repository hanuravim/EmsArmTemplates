# Deploy the Resource Group & Storage Account
$deploy = New-AzureRmDeployment -Name StorageAccount -Location eastus -TemplateParameterFile .\deploy_Customer_parameters.json -TemplateFile .\deploy_Customer.json -Verbose

# Retrieve the Storage Account details
$resourceGroup = $deploy.Outputs.Values.value[0]
$storageAccountName = $deploy.Outputs.Values.value[1]
$storageAccountKey = (Get-AzureRmStorageAccountKey -ResourceGroupName $resourceGroup -AccountName $storageAccountName).Value[0]

# Deploy the Azure File Share
$AzureFileShareName = @('emsadi','emsuser','emscollections')
$storageContext = New-AzureStorageContext $storageAccountName $storageAccountKey
foreach($azrfile in $AzureFileShareName){
$share = New-AzureStorageShare $azrfile -Context $storageContext
}
