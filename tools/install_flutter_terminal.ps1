# Terminal-Installation für Flutter unter Windows
# PowerShell als Administrator starten.

winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.VisualStudioCode -e --source winget --accept-package-agreements --accept-source-agreements
winget install --id Microsoft.VisualStudio.2022.Community -e --source winget --accept-package-agreements --accept-source-agreements --override "--wait --passive --add Microsoft.VisualStudio.Workload.NativeDesktop --includeRecommended"

New-Item -ItemType Directory -Force "$env:USERPROFILE\develop"
Remove-Item -Recurse -Force "$env:USERPROFILE\develop\flutter" -ErrorAction SilentlyContinue

$env:Path += ";C:\Program Files\Git\cmd"
git clone https://github.com/flutter/flutter.git -b stable "$env:USERPROFILE\develop\flutter"

[Environment]::SetEnvironmentVariable(
  "Path",
  [Environment]::GetEnvironmentVariable("Path", "User") + ";C:\Program Files\Git\cmd;$env:USERPROFILE\develop\flutter\bin",
  "User"
)

$env:Path += ";$env:USERPROFILE\develop\flutter\bin"
flutter doctor -v
