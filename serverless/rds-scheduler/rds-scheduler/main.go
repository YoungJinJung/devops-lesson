package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/rds"
)
const (
	AwsRegion = "ap-northeast-2"
)
type Response events.APIGatewayProxyResponse
var awsSeesion *session.Session
var DBList = []string{"test"}
func getAwsSession() *session.Session {
	if awsSeesion == nil {
		awsSeesion = session.Must(session.NewSession(&aws.Config{Region: aws.String(AwsRegion)}))
	}
	return awsSeesion
}

func stopRDS(session *session.Session) error {
	svc := rds.New(session)
	for _, db := range DBList {
		input := &rds.StopDBInstanceInput{
			DBInstanceIdentifier: aws.String(db),
		}
		
		_, err := svc.StopDBInstance(input)
		
		if err != nil {
			return err
		}
	}

	return nil
}

func Handler() (Response, error) {
	//get aws seesion
	session :=  getAwsSession()

	//stop rds
	err := stopRDS(session)

	//if err exist, then print and return code 500
	if err != nil {
		return Response{StatusCode: 500}, err
	}

	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Headers: map[string]string{
			"Content-Type":           "application/json",
			"X-MyCompany-Func-Reply": "hello-handler",
		},
	}

	return resp, nil
}

func main() {
	lambda.Start(Handler)
}
