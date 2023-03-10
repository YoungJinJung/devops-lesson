.PHONY: build clean deploy

build:
	env GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o bin/get-datadog-metric-to-dynamo get-datadog-metric-to-dynamo/main.go
	env GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o bin/send-msg-to-slack send-msg-to-slack/main.go


clean:
	rm -rf ./bin

deploy: clean build
	sls deploy --verbose -s dev
