# terraform-azurerm-storageaccount
Terraform module to create a storage account with a Private Endpoint


# Getting Started
## Create a Storage Account with a Private Endpoint in Azure

This Terraform module deploys a new Storage Account in Azure.

The module will create a single blob container with a private endpoint to provide more control over network access to the blob containers.

## Usage
```hcl
resource "azurerm_resource_group" "test" {
  name     = "resources"
  location = "West Europe"
}

module "storageaccount" {
  source  = "gitrepo/storageaccount/azurerm"
  version = "0.0.8"

  sa_resource_group_name      = azurerm_resource_group.test.name
  storage_account_name        = "sstorageaccountname"
  pe_vnet_resource_group_name = "privateendpoint-vnet-resourcegroup"
  pe_subnet_name              = "privateendpoint-subnet-name"
  pe_vnet_name                = "privateendpoint-vnet-name"
  private_blob_dns_zone_id    = "/subscriptions/xxxxxxxxuuuuuuuuu/resourceGroups/dnszoneResourceGroup/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
  private_blob_dns_zone_name  = "privatelink.blob.core.windows.net"
  tags = { Terraform = true,
    environment = "DEV"
  }
}
```

## Test

### Configurations

- [Configure Terraform for Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/terraform-install-configure)

We provide 2 ways to build, run, and test the module on a local development machine.  [Native (Mac/Linux)](#native-maclinux) or [Docker](#docker).

### Native (Mac/Linux)

#### Prerequisites

- [Ruby **(~> 2.3)**](https://www.ruby-lang.org/en/downloads/)
- [Bundler **(~> 1.15)**](https://bundler.io/)
- [Terraform **(~> 0.11.7)**](https://www.terraform.io/downloads.html)
- [Golang **(~> 1.10.3)**](https://golang.org/dl/)

#### Environment setup

We provide simple script to quickly set up module development environment:

```sh
$ curl -sSL https://raw.githubusercontent.com/Azure/terramodtest/master/tool/env_setup.sh | sudo bash
```

#### Run test

Then simply run it in local shell:

```sh
$ cd $GOPATH/src/{directory_name}/
$ bundle install
$ rake build
$ rake full
```

### Docker

We provide a Dockerfile to build a new image based `FROM` the `microsoft/terraform-test` Docker hub image which adds additional tools / packages specific for this module (see Custom Image section).  Alternatively use only the `microsoft/terraform-test` Docker hub image [by using these instructions](https://github.com/Azure/terraform-test).

#### Prerequisites

- [Docker](https://www.docker.com/community-edition#/download)

#### Custom Image

This builds the custom image:

```sh
$ docker build --build-arg BUILD_ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID --build-arg BUILD_ARM_CLIENT_ID=$ARM_CLIENT_ID --build-arg BUILD_ARM_CLIENT_SECRET=$ARM_CLIENT_SECRET --build-arg BUILD_ARM_TENANT_ID=$ARM_TENANT_ID -t azure-network .
```

This runs the build and unit tests:

```sh
$ docker run --rm azure-network /bin/bash -c "bundle install && rake build"
```

This runs the end to end tests:

```sh
$ docker run --rm azure-network /bin/bash -c "bundle install && rake e2e"
```

This runs the full tests:

```sh
$ docker run --rm azure-network /bin/bash -c "bundle install && rake full"
```

## Authors

Originally created by [Eugene Chuvyrov](http://github.com/echuvyrov)

## License

[MIT](LICENSE)


