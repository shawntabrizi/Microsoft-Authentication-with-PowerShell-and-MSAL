# Load MSAL
Add-Type -Path "..\MSAL\Microsoft.Identity.Client.dll"

# Output Token and Response from Microsoft Graph
$accessToken = ".\Token.txt"
$output = ".\Output.json"

# Application and Tenant Configuration
$clientId = "9c2a5a68-fc82-462b-8e38-fae1316c6688"
$login = "https://login.microsoftonline.com/"
$tenantId = "common"
$resourceId = "https://graph.microsoft.com"
$redirectUri = New-Object system.uri("https://login.microsoftonline.com/common/oauth2/nativeclient")
$scopes = New-Object System.Collections.ObjectModel.Collection["string"]
$scopes.Add("user.read")

# Get an Access Token with MSAL
$app = New-Object Microsoft.Identity.Client.PublicClientApplication($clientId, ($login + $tenantId))
$authenticationResult = $app.AcquireTokenAsync($scopes).GetAwaiter().GetResult()

($token = $authenticationResult.AccessToken) | Out-File $accessToken

# Call the Microsoft Graph
$headers = @{ 
    "Authorization" = ("Bearer {0}" -f $token);
    "Content-Type" = "application/json";
}

# Output response as a JSON file
Invoke-RestMethod -Method Get -Uri ("{0}/v1.0/me" -f $resourceId) -Headers $headers -OutFile $output