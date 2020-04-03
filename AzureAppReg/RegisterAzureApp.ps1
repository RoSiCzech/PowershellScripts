
# Script will create new app registration, grants necessary permision for AX authentication.
# When script finishes, you must manualy go to Azure portal, find your app registration and manualy grant CONSENT!!
# ##################################### RoSiCzech 2.4.2020 #####################################

$appName = "SomeName" # <-- insert your appname
$appURI = "SomeNameURI" # <-- Insert App URI (must be unique in your Tenant)
$ReplyUrl = "https://YourOriginalAXURL.com" # <-- insert you AX Demo URL

# Create new app registration
New-AzureADApplication -DisplayName $appName -IdentifierUris $appURI  -ReplyUrls $ReplyUrl

$MyAppObjectID = (Get-AzureADApplication | Where-Object { $_.DisplayName -eq $appName } ).ObjectId
$MyAppAppID = (Get-AzureADApplication | Where-Object { $_.DisplayName -eq $appName } ).AppID
Write-Host ("Use this ID when editing IIS config files (this is SPN): " + $MyAppAppID) -ForegroundColor Green

# Get IDs for Microsoft Graph API
$GraphObojecID = (Get-AzureADServicePrincipal  | Where-Object { $_.DisplayName -eq 'Microsoft Graph' } ).ObjectId
$GraphAppID = (Get-AzureADServicePrincipal  | Where-Object { $_.DisplayName -eq 'Microsoft Graph' } ).AppID

# set variables (IDs) for requiered permissions
$msGraph = Get-AzureADServicePrincipal -ObjectId $GraphObojecID
$acc1ID = ($msGraph.Oauth2Permissions | Where-Object { $_.Value -eq 'Directory.AccessAsUser.All' }).Id
$acc2ID = ($msGraph.Oauth2Permissions | Where-Object { $_.Value -eq 'User.Read' }).Id
$acc3ID = ($msGraph.Oauth2Permissions | Where-Object { $_.Value -eq 'User.Read.All' }).Id

# Grants permission to Microsoft Graph API
$req = New-Object -TypeName "Microsoft.Open.AzureAD.Model.RequiredResourceAccess"
$acc1 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $acc1ID,"Scope" # Directory.AccessAsUser.All
$acc2 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $acc2ID,"Scope" # User.Read
$acc3 = New-Object -TypeName "Microsoft.Open.AzureAD.Model.ResourceAccess" -ArgumentList $acc3ID,"Scope" # User.Read.All

$req.ResourceAccess = $acc1,$acc2,$acc3
$req.ResourceAppId = $GraphAppID # AppID of Microsoft Graph
Set-AzureADApplication -ObjectId $MyAppObjectID -RequiredResourceAccess $req # Obejct ID of my application (SomeName)

