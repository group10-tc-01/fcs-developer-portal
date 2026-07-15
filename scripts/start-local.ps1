$ErrorActionPreference = 'Stop'

Get-Content "$PSScriptRoot\..\.env" | ForEach-Object {
  if ($_ -match '^([^=]+)=(.*)$') {
    Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
  }
}

corepack enable
yarn start --config app-config.yaml --config app-config.local.yaml
