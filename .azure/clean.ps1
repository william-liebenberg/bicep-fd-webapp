Get-ChildItem -Path .\bicep -Include *.json -File -Recurse | ForEach-Object { 
	Write-Host "Cleaning up $($_.FullName)" -ForegroundColor Red
	$_.Delete() 
}

Get-ChildItem -Path . -Include *.temp.json -File -Recurse | ForEach-Object { 
	Write-Host "Cleaning up $($_.FullName)" -ForegroundColor Red
	$_.Delete() 
}