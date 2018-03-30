# This module acts as a "fake" endpoint for catching the authorization code that comes back with the Reply URL
# We 'control' the browser used for login, thus we can sniff the URL at the end of authentication, and parse the CODE
# We can detect the end of the login process because we compare the URL to the Reply URL used for authentication

Add-Type -AssemblyName System.Web
$outputAuth = ".\Code.txt"
$outputError = ".\Error.txt"

function LoginBrowser
{
    param
    (
        [Parameter(HelpMessage='Authorization URL')]
        [ValidateNotNull()]
        [string]$authorizationUrl,
        
        [Parameter(HelpMessage='Redirect URI')]
        [ValidateNotNull()]
        [uri]$redirectUri
    )

	# Create an Internet Explorer Window for the Login Experience
    $ie = New-Object -ComObject InternetExplorer.Application
    $ie.Width = 600
    $ie.Height = 500
    $ie.AddressBar = $false
    $ie.ToolBar = $false
    $ie.StatusBar = $false
    $ie.visible = $true
    $ie.navigate($authorzationUrl)

    while ($ie.Busy) {} 

    :loop while($true)
    {   
		# Grab URL in IE Window
        $urls = (New-Object -ComObject Shell.Application).Windows() | Where-Object {($_.LocationUrl -match "(^https?://.+)|(^ftp://)") -and ($_.HWND -eq $ie.HWND)} | Where-Object {$_.LocationUrl}

        foreach ($a in $urls)
        {
			# If URL is in the form we expect, with the Reply URL as the domain, and the code in the URL, grab the code
            if (($a.LocationUrl).StartsWith($redirectUri.ToString()+"?code="))
            {
                $code = ($a.LocationUrl)
                ($code = $code -replace (".*code=") -replace ("&.*")) | Out-File $outputAuth
                break loop
            }
			# If we catch an error, output the error information
			elseif (($a.LocationUrl).StartsWith($redirectUri.ToString()+"?error="))
            {
                $error = [System.Web.HttpUtility]::UrlDecode(($a.LocationUrl) -replace (".*error="))
                $error | Out-File $outputError
                break loop
            }
        }
    }

	# Return the Auth Code
    return $code
}
