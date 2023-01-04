var vmPrefix = 'vm'
var nameOfTheServer = 'ansible'
var osDisk = 'ubuntu'
param vmAdminUsername string 
var vnetAddressPrefix = '192.168.0.0/16'
var subnetAddressPrefix = ['192.168.1.0/24','192.168.2.0/24']
var Env = 'Dev'
param nicCard string = 'mynic'
param virtualNetworkName string = 'vnet'

@allowed([
  'sshPublicKey'
  'password'
])
param authenticationType string = 'password'

@secure()
param vmAdminPasswordOrKey string 

var linuxConfiguration = {
  disablePasswordAuthentication: true
  ssh: {
    publicKeys: [
      {
        path: '/home/${vmAdminUsername}/.ssh/authorized_keys'
        keyData: vmAdminPasswordOrKey
      }
    ]
  }
  provisionVMAgent: true
}

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2019-11-01' = {
  name: 'bicep-${virtualNetworkName}-dev'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: '${Env}-Subnet-1'
        properties: {
          addressPrefix: subnetAddressPrefix[0]
        }
      }
      {
        name: '${Env}-Subnet-2'
        properties: {
          addressPrefix: subnetAddressPrefix[1]
        }
      }
    ]
  }
}

@description('public ip allocation')
resource publicIPAddress 'Microsoft.Network/publicIPAddresses@2019-11-01' = {
  name: 'mypip'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

@description('nic card creation')
resource networkInterface 'Microsoft.Network/networkInterfaces@2020-11-01' = {
  name: nicCard
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'nicip'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: virtualNetwork.properties.subnets[0].id
          }
          publicIPAddress: {
            id: publicIPAddress.id
          }
        }
      }
    ]
  }
}

resource networkSecurityGroup 'Microsoft.Network/networkSecurityGroups@2019-11-01' = {
  name: 'mynsg'
  location: resourceGroup().location
  properties: {
    securityRules: [
      {
        name: 'nsgRule_1'
        properties: {
          description: 'Ssh-Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'nsgRule_2'
        properties: {
          description: 'Ssh-Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '22'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Outbound'
        }
      }
      {
        name: 'nsgRule_3'
        properties: {
          description: 'Http-Inbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 101
          direction: 'Inbound'
        }
      }
      {
        name: 'nsgRule_4'
        properties: {
          description: 'Http-Outbound'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '8080'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 103
          direction: 'Outbound'
        }
      }
    ]
  }
}

@description('ubuntu vm creation')
resource ubuntuVM 'Microsoft.Compute/virtualMachines@2020-12-01' = {
  name: '${vmPrefix}-${nameOfTheServer}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B1s'
    }
    osProfile: {
      computerName: 'ubuntuvm'
      adminUsername: vmAdminUsername
      adminPassword: vmAdminPasswordOrKey
      linuxConfiguration: ((authenticationType == 'password') ? null : linuxConfiguration)
    }
    storageProfile: {
      imageReference: {
        publisher: 'Canonical'
        offer: 'UbuntuServer'
        sku: '18.04-LTS'
        version: 'latest'
      }
      osDisk: {
        name: osDisk
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
  }
}

