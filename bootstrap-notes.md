In the console, create a service principal with the role Owner:

```
az ad sp create-for-rbac -n "SVservicePrincipal" --role Owner --create-cert
```

Login with the service principal

```
az logout
az login --service-principal --username "a448d6fc-f8b7-4847-9bf7-93f56bc7451f" --password 'C:\\Users\\svir\\tmpnow6fl5e.pem' --tenant "80e51828-6b27-4102-9478-a14375194b20"
```


Add script to repo root login-principal.sh