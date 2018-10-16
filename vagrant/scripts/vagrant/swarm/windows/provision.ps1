Write-Host "*********************************************************************"
Write-Host "Install Scoop"
Write-Host "*********************************************************************"

Set-ExecutionPolicy RemoteSigned -scope Process -force
Set-ExecutionPolicy RemoteSigned -scope CurrentUser -force
Get-ExecutionPolicy -List
iex ((New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh'))


Write-Host "*********************************************************************"
Write-Host "Install GitBash"
Write-Host "*********************************************************************"
#choco install -Y git -params "/GitAndUnixToolsOnPath"
scoop install git

Write-Host "*********************************************************************"
Write-Host "Install Scoop Extras"
Write-Host "*********************************************************************"

scoop bucket add extras
scoop install wget
scoop install sudo
scoop install openssh
scoop install netcat

#scoop install vscode
#scoop install firefox

Write-Host "*********************************************************************"
Write-Host "Install Chocolatery"
Write-Host "*********************************************************************"

iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
#powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" <NUL
#
choco install -Y 7zip
choco install -Y notepadplusplus

Write-Host "*********************************************************************"
Write-Host "Install NPM"
Write-Host "*********************************************************************"

#https://nodejs.org/dist/v6.11.2/node-v6.11.2-x64.msi
#powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://nodejs.org/dist/v6.11.2/node-v6.11.2-x64.msi'))" <NUL
scoop install nodejs

Write-Host "*********************************************************************"
Write-Host " Install NuGet"
Write-Host "*********************************************************************"

# $sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
# $targetNugetExe = "$rootPath\nuget.exe"
# Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
# Set-Alias nuget $targetNugetExe -Scope Global -Verbose
scoop install nuget


Write-Host "*********************************************************************"
Write-Host " Install PowerShellGet"
Write-Host "*********************************************************************"
git clone https://github.com/PowerShell/PowerShellGet
cd PowerShellGet
Import-Module PowerShellGet
cd ..

Write-Host "*********************************************************************"
Write-Host " Windows Update"
Write-Host "*********************************************************************"
#Install-Module -Name PSWindowsUpdate -RequiredVersion 1.5.2.2 -All
#Get-WUInstall –MicrosoftUpdate –AcceptAll –AutoReboot


Write-Host "*********************************************************************"
Write-Host " Install Docker"
Write-Host "*********************************************************************"
Write-Host "Open swarm ports"
#https://success.docker.com/Architecture/Docker_Reference_Architecture%3A_Securing_Docker_EE_and_Security_Best_Practices

New-NetFirewallRule -Protocol TCP -LocalPort 2376 -Direction Inbound -Action Allow -DisplayName "Docker engine 2"
New-NetFirewallRule -Protocol TCP -LocalPort 7946 -Direction Inbound -Action Allow -DisplayName "Docker swarm-mode node communication TCP"
New-NetFirewallRule -Protocol UDP -LocalPort 7946 -Direction Inbound -Action Allow -DisplayName "Docker swarm-mode node communication UDP"

New-NetFirewallRule -Protocol TCP -LocalPort 4789 -Direction Inbound -Action Allow -DisplayName "Docker swarm-mode overlay network TCP"
New-NetFirewallRule -Protocol UDP -LocalPort 4789 -Direction Inbound -Action Allow -DisplayName "Docker swarm-mode overlay network UDP"

#Additinals
New-NetFirewallRule -Protocol TCP -LocalPort 2375 -Direction Inbound -Action Allow -DisplayName "Docker engine"
New-NetFirewallRule -Protocol TCP -LocalPort 2377 -Direction Inbound -Action Allow -DisplayName "Docker swarm-mode cluster management TCP"
New-NetFirewallRule -Protocol TCP -LocalPort 4243 -Direction Inbound -Action Allow -DisplayName "Docker swarm API"

Write-Host "*********************************************************************"
Write-Host "Configuration required for Docker Inside Docker calls"
Write-Host "*********************************************************************"
#
# https://i-py.com/2016/docker-introspection-api-windows/
#  
#  docker -H npipe:////./pipe/docker_engine info
#  docker -H tcp://0.0.0.0:2375 ps
#  docker -H localhost:2375 ps
#  docker -H tcp://10.0.1.7:2375 info --> ERROR: 
#       error during connect: Get http://10.0.1.6:2375/v1.30/info: dial tcp 10.0.1.6:2375: connectex: No connection could be made because the target machine actively refused it.
#
#  FROM cntainer:
#
#  docker -H 172.28.240.1:2375 info     --> gateway IP
#
Stop-Service docker
dockerd --unregister-service
dockerd -H npipe:// -H 0.0.0.0:2375 --register-service
#dockerd -H npipe:// -H 0.0.0.0:2377 --register-service
Start-Service docker

Write-Host "*********************************************************************"
Write-Host "Installing docker compose"
Write-Host "*********************************************************************"
Invoke-WebRequest "https://github.com/docker/compose/releases/download/1.15.0/docker-compose-Windows-x86_64.exe" -UseBasicParsing -OutFile $Env:ProgramFiles\docker\docker-compose.exe


Write-Host "*********************************************************************"
Write-Host " Configure SWARM"
Write-Host "*********************************************************************"

#
# Get-ChildItem Env:
#
$HOSTNAME=$Env:ComputerName

Write-Host "HOSTNAME: $HOSTNAME"

#
# TODO: use vm_role property instead servername
#

if ( "$HOSTNAME".Contains('master') -Or "$HOSTNAME".Contains('manager') ) {
    
    Write-Host "*********************************************************************"
    Write-Host "Configure Docker and Init Swarm"
    Write-Host "*********************************************************************"
    #sudo docker swarm init --advertise-addr $(hostname -i) | awk '/--token/ {print $5}' > /home/mvm/swarm-token
    #docker swarm init --advertise-addr=<HOSTIPADDRESS> --listen-addr <HOSTIPADDRESS>:2377
    $MYIP=$((get-netadapter | get-netipaddress | ? addressfamily -eq 'IPv4').ipaddress[0])
    docker swarm init --advertise-addr=$MYIP --listen-addr ${MYIP}:2377

    Write-Host "*********************************************************************"
    Write-Host "Pull Master Name"
    Write-Host "*********************************************************************"
    $line=(Select-String fqdn C:\Scripts\provision.properties -ca|Select -exp line)
    $master=($line.Split(":").Trim()|Select -Index 1)

    # #Add Label
    New-Item -Type File c:\ProgramData\docker\config\daemon.json
    Add-Content 'c:\programdata\docker\config\daemon.json' '{ "labels": ["node.type=manager", "node.os=windows"], "insecure-registries" : ["${master}:5000"] }'
    Restart-Service docker
    
   
    
}

if ( "$HOSTNAME".Contains('worker') -Or "$HOSTNAME".Contains('node') ) {
    Write-Host "*********************************************************************"
    Write-Host "Pull Master Name"
    Write-Host "*********************************************************************"
    $line=(Select-String master_name C:\Scripts\provision.properties -ca|Select -exp line)
    $master=($line.Split(":").Trim()|Select -Index 1)

    Write-Host "*********************************************************************"
    Write-Host "Deamon Config"
    Write-Host "*********************************************************************"
    New-Item -Type File c:\ProgramData\docker\config\daemon.json
    Add-Content 'c:\programdata\docker\config\daemon.json' '{ "labels": ["node.type=worker", "node.os=windows"], , "insecure-registries" : ["${master}:5000"] }'
    #Add-Content 'c:\programdata\docker\config\daemon.json' '{ "labels": ["node.type=worker", "node.os=windows"], "hosts": ["tcp://0.0.0.0:2375", "npipe://"] }'
    #Add-Content 'c:\programdata\docker\config\daemon.json' '{ "labels": ["node.type=worker", "node.os=windows"], "hosts":["tcp://0.0.0.0:2377", “npipe:////./pipe/win_engine"] }'
    
    Restart-Service docker

    Write-Host "*********************************************************************"
    Write-Host "Join SWARM"
    Write-Host "*********************************************************************"
    $join_swarm=$(docker -H tcp://${master}:4243 swarm join-token worker|Select-String docker|Select -exp line)

    Write-Host "SWARM TOKEN:  ${join_swarm}"
    #Write-Host "${join_swarm}" > C:\Scripts\join-swarm.ps1
    #echo $join_swarm|iex
    #C:\Scripts\join-swarm.ps1
    Invoke-Expression ${join_swarm}
}
