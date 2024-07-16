# Street Illuminator

## Instructions
https://fabianfett.dev/getting-started-with-swift-aws-lambda-runtime

## Command to get zip for AWS Lambda
First...
```
docker run \
    --rm \
    --volume "$(pwd)/:/src" \
    --workdir "/src/" \
    swift:5.10.1-amazonlinux2 \
    swift build --product StreetIlluminator -c release -Xswiftc -static-stdlib 
```
then...
```
scripts/package.sh StreetIlluminator
```



## Test CURL to localhost
```
curl --header "Content-Type: application/json" \
  --request POST \
    --data '{"body": "{\"provider\": \"mapillary\", \"box\": {\"coordinate1\": {\"longitude\": 4.913801, \"latitude\": 52.373718331214945},\"coordinate2\": {\"longitude\": 4.917425, \"latitude\": 52.375034}},\"limit\":1000}"}' \
  http://127.0.0.1:7000/invoke
```

```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"body": "{\"box\": {\"coordinate1\": {\"longitude\": 4.88, \"latitude\": 52.39},\"coordinate2\": {\"longitude\": 4.89, \"latitude\": 52.40}},\"selfPaginate\": false,\"page\":1,\"limit\":10000000}"}' \
  http://127.0.0.1:7000/invoke
  ```
