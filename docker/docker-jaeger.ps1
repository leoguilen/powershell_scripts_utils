$image = "jaegertracing/all-in-one"
$containerName = "jaeger"

$attempts = 0
$maxAttempts = 3
$startSuccess = $false
 
do {
    docker ps -a -f name=$containerName -q | ForEach-Object {
        "Stopping $containerName container"
        docker stop $_ | Out-Null
        docker rm $_ | Out-Null
    }
 
    # https://hub.docker.com/r/jaegertracing/all-in-one
    docker run -d --name $containerName -e COLLECTOR_ZIPKIN_HOST_PORT=:9411 -p 5775:5775/udp -p 6831:6831/udp -p 6832:6832/udp -p 5778:5778 -p 16686:16686 -p 14268:14268 -p 14250:14250 -p 9411:9411 $image
 
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