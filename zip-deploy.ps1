Param(
    [Parameter(Mandatory = $false)]
    [string]$resourceGroupName="AzFdPrivLinkDemo",
	[Parameter(Mandatory = $false)]
    [string]$storageAccountName="azfdprivlinkdev",
	[Parameter(Mandatory = $false)]
    [string]$containerName="webapp"
)

$workingDirectory=$PSScriptRoot
$appfolder="$($workingDirectory)/publish/app"
$zipfolder="$($workingDirectory)/publish/zip"

$timestamp=Get-Date -Format "yyyyMMddHHmmss"
$filename="$($timestamp).zip"
$packageUrl="https://$($storageAccountName).blob.core.windows.net/$($containerName)/$($filename)"

# BUILD & PUBLISH
Write-Host "Publishing application into $($appfolder)" -ForegroundColor Green
dotnet publish ./src/blazorapp/Server/blazorapp.Server.csproj -c Release -o $appfolder

# ZIP IT!
Write-Host "Zipping application into $($filename)" -ForegroundColor Green

if(!(Test-Path $zipfolder))
{
	New-Item -ItemType Directory -Force -Path $zipfolder | Out-Null
}

# Get-ChildItem -Path $appfolder -Recurse | Compress-Archive -DestinationPath "$($zipfolder)/$($filename)" -Force | Out-Null
Compress-Archive -Path $appfolder\* -DestinationPath "$($zipfolder)/$($filename)" -Force

# DEPLOY IT
Write-Host "Uploading $($filename) to blob storage" -ForegroundColor Green

# Using account key
# - but you can also assign yourself the Storage Blob Data Contributor role to the storage account in Access Control (IAM)
# - remember to then change to `--auth-mode login`
$accountKey=az storage account keys list -g $resourceGroupName -n $storageAccountName --query '[0].{value:value}' --output tsv

# note: setting socket timeout to 20000 -- seems like there is a recent bug introduced where 20 is interpreted as milliseconds instead of seconds
$upload=az storage blob upload `
	--account-name $storageAccountName `
	--account-key "$($accountKey)" `
	--container-name webapp `
	--file "$($zipfolder)/$($filename)" `
	--name $filename `
	--socket-timeout 20000 `
	--auth-mode key

if ($lastexitcode -ne 0) {
	Write-Host $upload -ForegroundColor Red
	Write-Error $_
	exit 1;
}

Write-Host "Pointing AppService to run from package $($packageUrl)" -ForegroundColor Green
$appSettings=az webapp config appsettings set `
	-g AzFdPrivLinkDemo `
	-n azfdprivlink-dev-meyaxwasizpp6 `
	--settings "WEBSITE_RUN_FROM_PACKAGE=$($packageUrl)"

if ($lastexitcode -ne 0) {
	Write-Host $appSettings -ForegroundColor Red
	Write-Error $_
	exit 1;
}