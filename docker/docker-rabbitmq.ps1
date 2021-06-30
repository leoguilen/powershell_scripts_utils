$image = "rabbitmq"
$containerName = "rabbitmq"

$attempts = 0
$maxAttempts = 3
$startSuccess = $false
 
do {
    docker ps -a -f name=$containerName -q | ForEach-Object {
        "Stopping $containerName container"
        docker stop $_ | Out-Null
        docker rm $_ | Out-Null
    }
 
    # https://hub.docker.com/_/rabbitmq
    $imageTag = "$($image):3-management"
    docker run -d --hostname local-rabbit --name $containerName -p 5672:5672 -p 15672:15672 $imageTag
 
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