# Secrets backup and restore

The scripts *download-keyvault-secrets.sh* and *upload-keyvault-secrets.sh* can be used to backup/restore to/from the current folder all the secrets in keyvault.

The procedure is really simple: only the value of the secret is saved. All the other properties (e.g. Expiration date) of a secret are lost.