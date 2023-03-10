package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"runtime"
	"time"

	"github.com/DataDog/datadog-api-client-go/v2/api/datadog"
	"github.com/DataDog/datadog-api-client-go/v2/api/datadogV1"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"
	"github.com/aws/aws-sdk-go/service/ssm"
	"gopkg.in/yaml.v3"
)

const (
	AwsRegion      = "ap-northeast-2"
	DD_API_KEY     = "DATADOG_API_KEY"
	DD_APP_KEY     = "DATADOG_APP_KEY"
	TableName      = "datadog-metrics"
	ConfigFileName = "config.yml"
)

var (
	awsSession    *session.Session
	datadogApiKey string
	datadogAppKey string
)

type Metric struct {
	MetricName  string `yaml:"metric_name"`
	MetricQuery string `yaml:"metric_query"`
	GraphDef    string `yaml:"graph_def"`
	Title       string `yaml:"title"`
	Width       int64  `yaml:"width"`
	Height      int64  `yaml:"height"`
}

// Create struct to hold info about new item
type Item struct {
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

func getKeyFromSSM(sess *session.Session, key string) *string {
	ssmsvc := ssm.New(sess, aws.NewConfig().WithRegion(AwsRegion))
	param, err := ssmsvc.GetParameter(&ssm.GetParameterInput{
		Name:           aws.String(key),
		WithDecryption: aws.Bool(true),
	})

	if err != nil {
		panic(err)
	}

	return param.Parameter.Value
}

func getDatadogSnapshotUrl(ctx context.Context, apiClient *datadog.APIClient, cfg Metric) string {
	api := datadogV1.NewSnapshotsApi(apiClient)
	graphDefinition := ""
	if len(cfg.GraphDef) > 0 {
		graphDefinition = readJson(cfg.GraphDef)
	}

	resp, r, err := api.GetGraphSnapshot(ctx, time.Now().Add(-30*time.Minute).Unix(), time.Now().Unix(), *datadogV1.NewGetGraphSnapshotOptionalParameters().WithGraphDef(graphDefinition).WithMetricQuery(cfg.MetricQuery).WithTitle(cfg.Title).WithHeight(cfg.Height).WithWidth(cfg.Width))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error when calling `SnapshotsApi.GetGraphSnapshot`: %v\n", err)
		fmt.Fprintf(os.Stderr, "Full HTTP response: %v\n", r)
	}

	responseContent, _ := json.Marshal(resp)
	var data map[string]string

	if err := json.Unmarshal([]byte(responseContent), &data); err != nil {
		panic(err)
	}

	return data["snapshot_url"]
}

func readJson(fileName string) string {
	data, err := os.Open(fileName)
	if err != nil {
		panic(err)
	}
	byteValue, err := ioutil.ReadAll(data)
	if err != nil {
		panic(err)
	}
	var test string
	json.Unmarshal(byteValue, &test)
	return string(byteValue)
}

func insertIntoDB(sess *session.Session, cfg Metric, url string) error {
	svc := dynamodb.New(sess)

	item := Item{
		MetricName: cfg.MetricName,
		MetricUrl:  url,
		TimeStamp:  time.Now().Unix(),
	}

	av, err := dynamodbattribute.MarshalMap(item)
	if err != nil {
		log.Fatalf("Got error marshalling new item: %s", err)
		return err
	}

	input := &dynamodb.PutItemInput{
		Item:      av,
		TableName: aws.String(TableName),
	}

	_, err = svc.PutItem(input)
	if err != nil {
		log.Fatalf("Got error calling PutItem: %s", err)
		return err
	}
	return nil
}

// Handler is our lambda handler invoked by the `lambda.Start` function call
func Handler() {
	sess := getAwsSession()
	cfgs, err := getConfig(ConfigFileName)
	if err != nil {
		panic(err)
	}

	datadogApiKey := getKeyFromSSM(sess, DD_API_KEY)
	datadogAppKey := getKeyFromSSM(sess, DD_APP_KEY)
	os.Setenv("DD_API_KEY", *datadogApiKey)
	os.Setenv("DD_APP_KEY", *datadogAppKey)

	ctx := datadog.NewDefaultContext(context.Background())
	configuration := datadog.NewConfiguration()
	apiClient := datadog.NewAPIClient(configuration)

	for _, cfg := range cfgs {
		url := getDatadogSnapshotUrl(ctx, apiClient, cfg)
		//insert into dynamo
		fmt.Println(url)
		err := insertIntoDB(sess, cfg, url)
		if err != nil {
			panic(err)
		}
	}
}

func CallTest() {
	Handler()
}

func main() {
	if runtime.GOOS == "darwin" {
		CallTest()
		return
	}
	lambda.Start(Handler)
}
