az deployment sub create --name myrsg --location eastus --template-file resourceGroup.bicep
az deployment group create --name ubuntu --resource-group BicepRsg --template-file virtualMachine.bicep