azresult="{
  \"clientId\": \"80a270d5-0ee4-42f0-a8bd-9a3256c00ea5\",
  \"clientSecret\": \"4hsVVMi3se.uC.xYMh6ngjZH19XhuG2~Kn\",
  \"subscriptionId\": \"a6b5370b-0cd2-44b0-bcf4-7e7a3defef5c\",
  \"tenantId\": \"956e895f-5eaf-49bb-8627-4a6af61fd428\",
  \"activeDirectoryEndpointUrl\": \"https://login.microsoftonline.com\",
  \"resourceManagerEndpointUrl\": \"https://management.azure.com/\",
  \"activeDirectoryGraphResourceId\": \"https://graph.windows.net/\",
  \"sqlManagementEndpointUrl\": \"https://management.core.windows.net:8443/\",
  \"galleryEndpointUrl\": \"https://gallery.azure.com/\",
  \"managementEndpointUrl\": \"https://management.core.windows.net/\"
}"

echo "Hello $azresult"

echo $azresult | jq '.clientId,.clientSecret'  