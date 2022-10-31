# terraform test

Terraform test is the experimental testing framework that has been built in to Terarform since 0.15.0. As it is experiemntal, functionality, commands etc will likely change.

As this framework is experimental, there is some functionality missing that you may find in alternative solutions such as `Terratest`.

## overview

`terraform test` command will run all tests defined within the `tests` directory. Each child directory of `tests`, is to include a set of `.tf` files that define the tests to be run.

The following tests have been defined for this storage module:

## test types

Tests are defined in blocks of HCL known as `test assertions`. These define either an `equals` or a `check`. A basic `equals` example would be that you create an Azure Sorage Container named `logs`, where the `Equals` test defines a `want` and a `got` value.

The `Got` value defines what you got. So, typically this would be to return the names of containers that are created.

The `want` value states what you want the value to be (in this case that the created container = `logs`).

A `check` test can be used to perform a more through check against say a URL. If you create an Azure App Service for example, a Check can be used to check that the piublic URL returns the expected data.


## Tests Defiend for this Module

### default

### private-endpoint

### shares




