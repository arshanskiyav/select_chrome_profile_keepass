# cmd://powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\usr\GetChromeProfile.ps1" -URL "{BASE}"
Param(
    [string]$URL
)
 
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
