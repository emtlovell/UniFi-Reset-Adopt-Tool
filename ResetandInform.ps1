$CSVPath = ".\IP.csv" #Path to CSV with UniFi IPs
$PLinkPath = ".\plink.exe" #Path to Plink for SSH Connection
$Wait = 15 #Seconds to Wait for SSH to start after AP Comes back online


$SSHUser = Read-Host -Prompt 'User to SSH Into Unifi AP before Reset '#Ask for SSH User
$SSHPass = Read-Host -Prompt 'Password to SSH Into Unifi AP before Reset '#Ask for SSH Pass
$InformIP = Read-Host -Prompt 'IP Address or FQDN for Inform, Just the IP or FQDN i.e. 1.2.3.4 or controller.unifi.com'#Ask for Inform IP
$InformURL = "http://${InformIP}:8080/inform" #Url to Set for Inform


Import-Csv -Path $CSVPath | ForEach-Object { #Import CSV
Write-Host "Resetting $($_.IP) to Factory" -ForegroundColor Green #Write that unit will be reset
 echo y| plink -v $($_.IP) -l $SSHUser -pw $SSHPass "syswrapper.sh restore-default" #Connect using plink to run SSH command to reset
}
Import-Csv -Path $CSVPath | ForEach-Object { #Import CSV
Write-Host "Waiting for $($_.IP) to come alive" -ForegroundColor Green  #Let user know we are waiting for ping to return
do {$ping = test-connection -comp $($_.IP) -Quiet} until ($ping) #Wait Until Ping Returns
Write-Host "$($_.IP) is Alive Waiting $Wait Second for SSH to start" -ForegroundColor Green #Let user know we are waiting for SSH to start
Start-Sleep -s $Wait #Sleep script 
echo y| plink -v $($_.IP) -l ubnt -pw ubnt "mca-cli-op set-inform $InformURL" #Use Plink to connect and set inform
}

