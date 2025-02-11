@description('The name of the container registry to create. This must be globally unique.')
param acrName string

@description('The name of the SKU to use when creating the container registry.')
param skuName string = 'Basic'

@description('The location into which the Azure resources should be deployed.')
param location string  = resourceGroup().location

@description('The name of the container image to create.')
param containerImageName string = 'adf/shir'

@description('The tag of the container image to create.')
param containerImageTag string

@description ('The URL of the Git repository containing the Dockerfile to build the container image.')
param dockerfileSourceGitRepository string = 'https://github.com/Azure/Azure-Data-Factory-Integration-Runtime-in-Windows-Container.git'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: skuName
  }
  /*
  properties: {
    adminUserEnabled: true
  }
  */
}

// Build the container image.
resource buildTask 'Microsoft.ContainerRegistry/registries/taskRuns@2019-06-01-preview' = {
  parent: containerRegistry
  name: 'buildTask'
  properties: {
    runRequest: {
      type: 'DockerBuildRequest'
      dockerFilePath: 'Dockerfile'
      sourceLocation: dockerfileSourceGitRepository
      imageNames: [
        '${containerImageName}:${containerImageTag}'
      ]
      platform: {
        os: 'Windows'
        architecture: 'amd64'
      }
    }
  }
}

output containerRegistryName string = containerRegistry.name
output containerImageName string = containerImageName
output containerImageTag string = containerImageTag
