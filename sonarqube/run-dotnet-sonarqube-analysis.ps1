[CmdletBinding()]

PARAM ( 
    [string]$ProjectKey = $(throw "ProjectKey is required."),
    [string]$SonarLogin = $(throw "SonarLogin is required.")
)

$ErrorActionPreference = 'Stop'
$SonarHostUrl = "http://localhost:9000"

try {
    dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover
    dotnet build-server shutdown
    dotnet sonarscanner begin /k:$ProjectKey /d:sonar.host.url=$SonarHostUrl /d:sonar.login=$SonarLogin /d:sonar.cs.opencover.reportsPaths=**.Test/coverage.opencover.xml /d:sonar.coverage.exclusions=”**Test*.cs”
    dotnet build
    dotnet sonarscanner end /d:sonar.login=$SonarLogin
}
catch {
    Write-Host "Message: [$($_.Exception.Message)"] -ForegroundColor Red -BackgroundColor
}