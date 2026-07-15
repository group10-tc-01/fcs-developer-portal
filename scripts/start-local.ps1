$ErrorActionPreference = 'Stop'

Get-Content "$PSScriptRoot\..\.env" | ForEach-Object {
  if ($_ -match '^([^=]+)=(.*)$') {
    Set-Item -Path "Env:$($matches[1])" -Value $matches[2]
  }
}

if (Get-Command yarn -ErrorAction SilentlyContinue) {
  yarn start --config ../../app-config.yaml --config ../../app-config.local.yaml
} else {
  node .yarn/releases/yarn-4.13.0.cjs start --config ../../app-config.yaml --config ../../app-config.local.yaml
}
