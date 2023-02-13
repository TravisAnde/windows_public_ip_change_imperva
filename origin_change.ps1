# Set to run on start via scheduled task for Windows servers


$file = 'C:\CurrentImpervaIp.txt'

if (-not(Test-Path -Path $file -PathType Leaf)) {
  try {
    $null = New-Item -ItemType File -Path $file -Force -ErrorAction Stop
    $Temp = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    echo $Temp | Out-File -FilePath C:\CurrentImpervaIp.txt
    Write-Host "The file [$file] has been created."
    $setFile = 0
  }
  catch {
    throw $_.Exception.Message
  }
}

else {
  Write-Warning "Imperva txt file exists. Comparing to current public IP.."
  $setFile = 1
}
Start-Sleep -s 3


$pubIpCurrent = Get-Content -Path C:\CurrentImpervaIp.txt

$pubIpTemp = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content


if (($pubIpTemp -eq $pubIpCurrent) -and ($setFile -eq 1)) {

  try {
    Write-Warning "$($pubIpCurrent) is already set as orgin .. Exiting ..."
  }
  catch {
    throw $_.Exception.Message
  }
}

else {

  $pubIpCurrent = $pubIpTemp

  # Site Id goes here
  $SiteID = '<Site ID>'
  $ApiUrl = "https://my.imperva.com/api/prov/v1/sites/configure?site_id=$SiteID&param=site_ip&value=$pubIpCurrent"
    
  # API Details go here, Encoding needed.
  $Headers = @{  
       
    "x-API-Id"  = '<API Id>'
    "x-API-Key" = '<API Key>'
   
  }

  Write-Warning "Changing origin server to $($pubIpCurrent)"
  Start-Sleep -s 10
  Invoke-RestMethod -Method Post -Headers $Headers -Uri $ApiUrl -ContentType "application/json"
  Write-Host "Origin server address changed .."
  echo $pubIpCurrent | Out-File -FilePath C:\CurrentImpervaIp.txt
  Exit

}
