# Load MSAL
Add-Type -Path "..\MSAL\Microsoft.Identity.Client.dll"

# Load our Login Browser Function
Import-Module ./LoginBrowser.psm1

# Output Token and Response from Microsoft Graph
$accessToken = ".\Token.txt"
$output = ".\Output.json"

# Application and Tenant Configuration
$clientId = "bfa0f990-6350-4750-8d0c-42d6a3cd49ea"
$login = "https://login.microsoftonline.com/"
$tenantId = "common"
$redirectUri = "https://shawntabrizi.com/"

# Create Client Credential Using App Key
$secret = New-Object Microsoft.Identity.Client.ClientCredential("imbOKALAP7]nhzaS2868$)(")

# Create Client Credential Using Certificate
#$certFile = "<PFXFilePath>"
#$certFilePassword = "<CertPassword>"
#$secret = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate -ArgumentList $certFile,$certFilePassword

# Define the resources and scopes you want to call
$scopes = New-Object System.Collections.ObjectModel.Collection["string"]
$scopes.Add("https://graph.microsoft.com/user.read")

# Get an Access Token with MSAL
$app = New-Object Microsoft.Identity.Client.ConfidentialClientApplication($clientId, ($login + $tenantId), $redirectUri, $secret)
$authenticationResult = $app.AcquireTokenAsync($scopes).GetAwaiter().GetResult()

($token = $authenticationResult.AccessToken) | Out-File $accessToken

# Call the Microsoft Graph
$headers = @{ 
    "Authorization" = ("Bearer {0}" -f $token);
    "Content-Type" = "application/json";
}

# Output response as a JSON file
Invoke-RestMethod -Method Get -Uri ("https://graph.microsoft.com/v1.0/me" -f $resourceId) -Headers $headers -OutFile $output