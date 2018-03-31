# Load MSAL
Add-Type -Path "..\MSAL\Microsoft.Identity.Client.dll"

# Load our Login Browser Function
Import-Module ./LoginBrowser.psm1

# Output Token and Response from Microsoft Graph
$accessToken = ".\Token.txt"
$output = ".\Output.json"

# Application and Tenant Configuration
$clientId = "<AppIdGUID>"
$login = "https://login.microsoftonline.com/"
$tenantId = "common"
$redirectUri = New-Object system.uri("<redirectURI>")

# Create Client Credential Using App Key
$secret = New-Object Microsoft.Identity.Client.ClientCredential("<secret>")

# Define the resources and scopes you want to call
$scopes = New-Object System.Collections.ObjectModel.Collection["string"]
$scopes.Add("https://graph.microsoft.com/user.read")

# Get an Access Token with MSAL
$app = New-Object Microsoft.Identity.Client.ConfidentialClientApplication($clientId, ($login + $tenantId), $redirectUri, $secret, $null, $null)
$authorzationUrl = $app.GetAuthorizationRequestUrlAsync($scopes, $null, $null).GetAwaiter().GetResult()
$code = LoginBrowser $authorzationUrl $redirectUri
$authenticationResult = $app.AcquireTokenByAuthorizationCodeAsync($code, $scopes).GetAwaiter().GetResult()

($token = $authenticationResult.AccessToken) | Out-File $accessToken

# Call the Microsoft Graph
$headers = @{ 
    "Authorization" = ("Bearer {0}" -f $token);
    "Content-Type" = "application/json";
}

# Output response as a JSON file
Invoke-RestMethod -Method Get -Uri ("https://graph.microsoft.com/v1.0/me" -f $resourceId) -Headers $headers -OutFile $output