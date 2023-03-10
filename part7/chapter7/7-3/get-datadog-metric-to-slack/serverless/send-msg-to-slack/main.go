package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/ssm"
	"github.com/slack-go/slack"

	"gopkg.in/yaml.v3"
)

const (
	AwsRegion      = "ap-northeast-2"
	TableName      = "datadog-metrics"
	ConfigFileName = "config.yml"
	ChannelId      = "" //user channel id
	TokenName      = "DATADOGBOT_SLACK_TOKEN"
)

var awsSession *session.Session
var slackToken string

type Response events.APIGatewayProxyResponse

type Blocks struct {
	Block []Block `json:"blocks"`
}

type Block struct {
	Type     string       `json:"type"`
	ImageUrl string       `json:"image_url"`
	Title    TitleElement `json:"title"`
	AltText  string       `json:"alt_text"`
}

type TitleElement struct {
	Type string `json:"type"`
	Text string `json:"text"`
}

type Metric struct {
	MetricName  string `yaml:"metric_name"`
	MetricQuery string `yaml:"metric_query"`
	GraphDef    string `yaml:"graph_def"`
	Title       string `yaml:"title"`
	Width       int64  `yaml:"width"`
	Height      int64  `yaml:"height"`
}

type DynamoData struct {
	MetricName string
	MetricUrl  string
	TimeStamp  int64
}

func getAwsSession() *session.Session {
	if awsSession == nil {
		awsSession = session.Must(session.NewSession(&aws.Config{Region: aws.String(AwsRegion)}))
	}
	return awsSession
}

func getConfig(fileName string) ([]Metric, error) {
	buf, err := ioutil.ReadFile(fileName)
	if err != nil {
		return nil, err
	}

	var metrics []Metric
	err = yaml.Unmarshal(buf, &metrics)
	if err != nil {
		log.Fatalf("Unmarshal: %v", err)
	}

	return metrics, nil
}

func getSlackTokenFromSSM(sess *session.Session) *string {
	ssmsvc := ssm.New(sess, aws.NewConfig().WithRegion(AwsRegion))
	param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(TokenName),
		WithDecryption: aws.Bool(true),
	})

	if err != nil {
		panic(err)
	}

	return param.Parameter.Value
}

func sendMessageToSlack(sess *session.Session, cfgs []Metric, urlData map[string]string) error {

	slackToken = *getSlackTokenFromSSM(sess)

	api := slack.New(slackToken)

	var msgBlocks []slack.Block

	for _, cfg := range cfgs {
		titleObject := slack.NewTextBlockObject("plain_text", cfg.Title, true, false)
		imageBlock := slack.NewImageBlock(urlData[cfg.MetricName], "", "", titleObject)
		msgBlocks = append(msgBlocks, imageBlock)
	}

	attachment := slack.Attachment{
		Color:  "default",
		Blocks: slack.Blocks{msgBlocks},
	}

	channelId, timestamp, slackErr := api.PostMessage(
		ChannelId,
		slack.MsgOptionText("", false),
		slack.MsgOptionAttachments(attachment),
		slack.MsgOptionAsUser(false),
	)

	if slackErr != nil {
		fmt.Printf("%s\n", slackErr)
		return slackErr
	}

	fmt.Printf("Message successfully sent to Channel %s at %s\n", channelId, timestamp)
	return nil
}

func getMetricUrlFromDynamo(sess *session.Session, cfgs []Metric) map[string]string {
	metricsInfo := make(map[string]string)
	svc := dynamodb.New(sess)

	for _, cfg := range cfgs {
		params := &dynamodb.GetItemInput{
			TableName: aws.String(TableName),
			Key: map[string]*dynamodb.AttributeValue{
				"MetricName": {
					S: aws.String(cfg.MetricName),
				},
			},
		}

		result, err := svc.GetItem(params)
		if err != nil {
			fmt.Println("GetItem ", err.Error())
			os.Exit(1)
		}

		data := DynamoData{}
		dynamodbattribute.UnmarshalMap(result.Item, &data)
		jsonStr, _ := json.Marshal(data)
		fmt.Println(string(jsonStr))
		metricsInfo[data.MetricName] = data.MetricUrl
	}
	return metricsInfo
}

// Handler is our lambda handler invoked by the `lambda.Start` function call
func Handler() (Response, error) {
	sess := getAwsSession()

	//Get config to config.yml
	cfgs, err := getConfig(ConfigFileName)

	//get image url from dynamodb
	urlData := getMetricUrlFromDynamo(sess, cfgs)

	//Set slack msg
	err = sendMessageToSlack(sess, cfgs, urlData)
	if err != nil {
		fmt.Println("Failed to Send Slack Msg ", err.Error())
		os.Exit(1)
	}

	resp := Response{
		StatusCode:      200,
		IsBase64Encoded: false,
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}

	return resp, nil
}

func main() {
	lambda.Start(Handler)
}
