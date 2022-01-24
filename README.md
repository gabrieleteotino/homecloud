# Homecloud bootstrap
Bootstrap resources and manual steps for my home cloud.

## Prerequisites

- Azure subscription
- Terraform
- az

### Terraform on linux with tfenv

Install **brew**.
Remember to execute the commands in the __Next steps__ section at the end of the script output.

```
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Wait for it
## Execute the next steps
```

Install **tfenv**

```
brew install tfenv
```

Install terraform

```
# Latest version
tfenv install

# Specific version
tfenv install 1.1.3
```

Create a file __.terraform-version__ so that tfenv automatically detects the version of terraform. [Documentation](https://github.com/tfutils/tfenv#terraform-version).


### Azure CLI

Follow the instructions on [Microsoft docs](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-linux?pivots=apt).

The fastest way is:

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

Authenticate and verify your subscription.

```
az login
az account list
```

Eventually set your default subscription if you have more than one linked to your account.