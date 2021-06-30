$image = "sonarqube"
$containerName = "sonarqube"

$attempts = 0
$maxAttempts = 3
$startSuccess = $false
 
do {
    docker ps -a -f name=$containerName -q | ForEach-Object {
        "Stopping $containerName container"
        docker stop $_ | Out-Null
        docker rm $_ | Out-Null
    }
 
    # https://hub.docker.com/_/sonarqube
    docker run -d --hostname local-sonarqube  --name $containerName -p 9000:9000 $image
    
    if ($?) {
        $startSuccess = $true
        break;
    }
 
    $attempts = $attempts + 1
 
    "Waiting on $image docker run success, attempts: $attempts of $maxAttempts"
    Start-Sleep 1
} while ($attempts -lt $maxAttempts)
 
if (!$startSuccess) {
    throw "Failed to start $image container."
}