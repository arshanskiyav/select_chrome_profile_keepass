# Select Chrome profile Keepass
If you use Keepass, you should know that URLs will open in the last chrome window, regardless of the profile are you using. This script offers you choice.

<img width="685" height="417" alt="image" src="https://github.com/user-attachments/assets/fadf255c-7e0c-48fb-bba5-a74bdbe6c061" />


There are two scripts:
- regular version
- version with the ability to connect to an SSH tunnel before opening the URL

For install use KeePass settings:

<img width="1447" height="625" alt="2026-02-01_22-55-41" src="https://github.com/user-attachments/assets/ed910336-71b5-4dc0-bc8a-cd7f56bf76d0" />


To connect the regular version, you need to use this line:
```
cmd://powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\usr\GetChromeProfile.ps1" -URL "{BASE}"
```

To connect the extra version, you need use this line:
```
cmd://powershell.exe -NoProfile -ExecutionPolicy Bypass -File "C:\usr\GetChromeProfile.ps1" -URL "{BASE}" -TroughTunnel -User {USERNAME} -Pwd {PASSWORD}
```
And associte it with scheme `sshl`. To construct a URL,  use the folowing construction:
```
sshl://1.1.1.1:56778/127.0.0.1:9443/127.0.0.1:443
```
$URL = / $SSHHost - ssh host / $LocalURL - client address / $DestURL - server address 
