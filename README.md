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
swift build --product StreetIlluminator -c release -Xswiftc -static-stdlib \
```
then...
```
scripts/package.sh StreetIlluminator
```



## Test CURL to localhost
```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"coordinate1": {"longitude": 4.910801, "latitude": 52.373718331214945}, "coordinate2": {"longitude": 4.917425, "latitude": 52.375034}}' \
  http://127.0.0.1:7000/invoke
```

```
curl --header "Content-Type: application/json" \
  --request POST \
  --data '{"body": "{\"box\": {\"coordinate1\": {\"longitude\": 4.664532, \"latitude\": 52.747660},\"coordinate2\": {\"longitude\": 5.164188, \"latitude\": 51.991564}},\"selfPaginate\": false,\"page\":2,\"limit\":10000000}"}' \
  http://127.0.0.1:7000/invoke
  ```
