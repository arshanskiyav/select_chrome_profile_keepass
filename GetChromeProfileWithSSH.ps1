# cmd://powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\usr\GetChromeProfileWithSSH.ps1" -URL "{BASE}"
# cmd://powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\usr\GetChromeProfileWithSSH.ps1" -URL "{BASE}" -TroughTunnel -User {USERNAME} -Pwd {PASSWORD}
# sshl://1.1.1.1:56778/127.0.0.1:9443/127.0.0.1:443
# $URL = / $SSHHost - ssh host / $LocalURL - client address / $DestURL - server address 
Param(
    [Parameter(Mandatory=$true)]
	[string]$URL,
	[switch]$TroughTunnel,
	[string]$SSHHost,
	[string]$User,
    [string]$Pwd,
	[string]$DestURL,
    [string]$LocalURL
)
function GetParam($NameParam,$IndexNumberInURL,$URLarr){
    if (Invoke-Expression "!`$$NameParam"){
        $substr=$URLarr[$IndexNumberInURL]
    } else {
        $substr=Invoke-Expression "`$$NameParam"
    }
    return New-Object PSObject -Property @{port=$substr.split(":")[1];address=$substr.Split(":")[0]}
}
if ($TroughTunnel){
	$URLarr=$URL.Split("/")[2..$URL.Split("/").Length]

	$AddressesPorts=New-Object PSObject -Property @{
		SSHHost=GetParam "SSHHost" 0 $URLarr
		LocalURL=GetParam "LocalURL" 1 $URLarr
		DestURL=GetParam "DestURL" 2 $URLarr
	}	
	
	# If you want to use plink, you need to manually apply session start on the window.
	Start-Process -FilePath putty.exe -ArgumentList "-ssh `"$User@$($AddressesPorts.SSHHost.address)`" -pw `"$Pwd`" -P `"$($AddressesPorts.SSHHost.port)`" -N -L `"$($AddressesPorts.LocalURL.address):$($AddressesPorts.LocalURL.port):$($AddressesPorts.DestURL.address):$($AddressesPorts.DestURL.port)`"" -WindowStyle Minimized
	
	Write-host ("putty.exe  `"$User@$($AddressesPorts.SSHHost.address)`" -pw `"**********`" -P `"$($AddressesPorts.SSHHost.port)`" -L `"$($AddressesPorts.LocalURL.address):$($AddressesPorts.LocalURL.port):$($AddressesPorts.DestURL.address):$($AddressesPorts.DestURL.port)`"")
	
	sleep 5
	if ( -not (Test-NetConnection $AddressesPorts.LocalURL.address -Port $AddressesPorts.LocalURL.port -InformationLevel Quiet)){
		Write-Host ("Service is unavailable")
		pause
		exit
	} else {
		$URL="https://$($AddressesPorts.LocalURL.address):$($AddressesPorts.LocalURL.port)"
		write-host($URL)
	}
}

$LocalState="$env:LOCALAPPDATA\Google\Chrome\User Data\Local State"
$PathToChrome="\Google\Chrome\Application\chrome.exe"

if (-not (Test-Path $LocalState)) {
    Write-Host("File $LocalState not found")
    Pause
    Exit
}

$FullPathToChrome = switch($true) {
    {Test-Path -Path $env:LOCALAPPDATA$PathToChrome} {Write-Output $env:LOCALAPPDATA$PathToChrome}
    {Test-Path -Path $env:ProgramFiles$PathToChrome} {Write-Output $env:ProgramFiles$PathToChrome}
    {Test-Path -Path ${env:ProgramFiles(x86)}$PathToChrome} {Write-Output ${env:ProgramFiles(x86)}$PathToChrome}
    default {
        Write-host ("Chrome path not found")
        Pause
        exit
    }
}

$number=0 # number of profiles 
$Source=$(Get-Content -Raw $LocalState -Encoding UTF8 | ConvertFrom-Json)[0].Profile.info_cache
$arrayNameProfile=$source | Get-Member | Where MemberType -match "NoteProperty" | foreach {
    New-Object PSObject -Property @{
        NumberPrivate=100+$number
		Number=$number++
        AppDataProfileName=$_.Name
        BrowserProfileName=$($source."$($_.Name)").name
    }
}
$arrayNameProfile|Out-Host
    
$inputValue = 0
do {
    $inputValid = [int]::TryParse((Read-Host 'Please enter profile number'), [ref]$inputValue)
    if ( -not $inputValid ){
        Write-Host("Your input was not an integer...")
        continue
    }
	if (($inputValue-100) -ge 0){
		$inputValue=$inputValue-100
		$Private="--incognito"
	} else {
		$Private=""
	}
    if ($inputValue -le $arrayNameProfile.Count-1){
        $selectProfile=$($arrayNameProfile[$inputValue].AppDataProfileName)
        Write-Host("$FullPathToChrome $URL --profile-directory=""$selectProfile""")
        start $FullPathToChrome "$URL --profile-directory=""$selectProfile"" $Private"
    } else {
        Write-Host("Your input is greater than the number of rows in the array...")
        $inputValid=$false
    }
} while (-not $inputValid)
