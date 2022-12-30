.PHONY: build clean deploy

build:
	env GOARCH=amd64 GOOS=linux go build -ldflags="-s -w" -o bin/rds-scheduler rds-scheduler/main.go

clean:
	rm -rf ./bin

deploy: clean build
	sls deploy --verbose
