'''
This function send Application Load Balancer logs to CloudWatch Logs. So you can use CloudWatch tools, like Insight or custom metrics.
By default, ALB log its access in gz file in S3, and there is no way yo send the log directly to a Log Group / Log Stream.
This lambda function is triggered on S3 "PUT" action (when ALB write its log file). It then download the file localy, unzip it, sort it, and stream it to a CloudWatch log groups.
Installation
Activate ALB logs, and indicate the S3 bucket and the prefix for the log files. Enable, on the bucket, the deletion of old log files
(because log files will be now in Cloudwatch, it is not necessary to keep them in S3).
Install the Lambda function on the region of your S3 bucket. Grant permission of this function to read the S3 and to create Log group and stream :
  s3:GetObject
  logs:CreateLogStream
  logs:CreateLogGroup
  logs:DescribeLogStreams
  logs:PutLogEvents
Lambda settings :
  Runtime : Python 3.7
  Environment variables :
    "CloudWatch_LogGroup" : name of your CloudWatch Log Groups (like "/appli/production/cdn"). It will be created if not exists. On this group, a stream is created by day.
    "InputFormat" : must be "alb" (in the future (TODO), this Lambda will also support other AWS log format like CloudFront)
    "OutputFormat" : indicate log format in CloudWatch Logs
        "alb" : same format as alb (see https://docs.aws.amazon.com/fr_fr/athena/latest/ug/application-load-balancer-logs.html)
        "json" : full ALB log in JSON
        "jsonsimplified" : only import info
  Memory : depending of the log files, at least 384MB is enough to handle 20.000 lines of log on each request.
  Timeout : 1mn
  
Add a trigger ("ObjectCreated:Put") on the S3 where GZipped log files are sent by ALB. They are send every 5mn.
Monitoring : monitor Lambda execution code, memory and error. If the lambda cant handle a full log file, you may have incomplete log in CloudWatch. Retriggering the
action will result in duplicate log lines in CloudWatch.
What you can do with the ALB log in CloudWatch logs :
- count number of request blocked by waf
- track the IP of your client
'''
import json
import pprint
import boto3
import urllib.parse
import tempfile
import os
import subprocess
import gzip
import datetime
import logging
import re
from botocore.exceptions import ClientError



def createLogGroupAndStream(loggroup, logstream):
    print("Working with CloudWatch Logs group " + loggroup + " and stream "+logstream)
    try:
        GLOBAL_CWL.create_log_group(
            logGroupName=loggroup
        )
    except ClientError as e:
        if e.response['Error']['Code'] != 'ResourceAlreadyExistsException':
            raise
    
    try:
        GLOBAL_CWL.create_log_stream(
            logGroupName=loggroup,
            logStreamName=logstream
        )
    except ClientError as e:
        if e.response['Error']['Code'] != 'ResourceAlreadyExistsException':
            raise

    return True


# GLOBAL SECTION
# initialized when a cold start occur
GLOBAL_S3 = boto3.resource('s3')
GLOBAL_CWL = boto3.client('logs')


def streamlines(line, number):
    # Ignore line start with #
    if (line.startswith('#') == False):
        fields = line.split("\t")
        print(fields[0])
    #print(number," ")
    return

def streamevents(events, sequenceToken,loggroup, logstream):
    kwargs = {
        'logGroupName':loggroup,
        'logStreamName':logstream,
        'logEvents':events,
    }
    if (sequenceToken != None):
        kwargs.update({'sequenceToken': sequenceToken})
    return GLOBAL_CWL.put_log_events(**kwargs)

def alb_read_and_convert(number, line, outputformat):
    #fields = line.strip().split(" ")
    fields = re.compile(r'([^ ]*) ([^ ]*) ([^ ]*) ([^ ]*):([0-9]*) ([^ ]*)[:-]([0-9]*) ([-.0-9]*) ([-.0-9]*) ([-.0-9]*) (|[-0-9]*) (-|[-0-9]*) ([-0-9]*) ([-0-9]*) \"([^ ]*) ([^ ]*) (- |[^ ]*)\" \"([^\"]*)\" ([A-Z0-9-]+) ([A-Za-z0-9.-]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\" \"([^\"]*)\" ([-.0-9]*) ([^ ]*) \"([^\"]*)\" \"([^\"]*)\"($| \"[^ ]*\")(.*)').findall(line)[0]
    timestamp = 1000*(datetime.datetime.strptime(fields[1], '%Y-%m-%dT%H:%M:%S.%fZ').timestamp()) # todo : find a more efficient way to convert date/time in log file (string) to a timestamp (int)
    if (outputformat == '' or outputformat == 'alb'):
        lineout = line
    elif (outputformat == 'json'):
        lineout = json.dumps({
            # See https://docs.aws.amazon.com/fr_fr/elasticloadbalancing/latest/application/load-balancer-access-logs.html#log-processing-tools 
            # and https://docs.aws.amazon.com/fr_fr/athena/latest/ug/application-load-balancer-logs.html
            'type'                    : fields[0],
            'time'                    : fields[1],
            'elb'                     : fields[2],
            'client_ip'               : fields[3],
            'client_port'             : int(fields[4]),
            'target_ip'               : fields[5],
            'target_port'             : int(fields[6]),
            'request_processing_time' : float(fields[7]),
            'target_processing_time'  : float(fields[8]),
            'response_processing_time' : float(fields[9]),
            'elb_status_code'         : fields[10],
            'target_status_code'      : fields[11],
            'received_bytes'          : int(fields[12]),
            'sent_bytes'              : int(fields[13]),
            'request_verb'            : fields[14],
            'request_url'             : fields[15],
            'request_proto'           : fields[16],
            'user_agent'              : fields[17],
            'ssl_cipher'              : fields[18],
            'ssl_protocol'            : fields[19],
            'target_group_arn'        : fields[20],
            'trace_id'                : fields[21],
            'domain_name'             : fields[22],
            'chosen_cert_arn'         : fields[23],
            'matched_rule_priority'   : fields[24],
            'request_creation_time'   : fields[25],
            'actions_executed'        : fields[26],
            'redirect_url'            : fields[27],
            'lambda_error_reason'     : fields[28],
            'new_field'               : fields[29]

        })
    elif (outputformat == 'jsonsimplified'):
        lineout = json.dumps({
            'time' : fields[1],
            'client_ip' : fields[3],
            'target' : fields[5]+':'+fields[6],
            'sent_bytes' : int(fields[13]),
            'request_verb' : fields[14],
            'request_url' : fields[15],
            'request_proto' : fields[16],
            'elb_status_code' : fields[10],
            'received_bytes' : int(fields[12]),
            'request_processing_time' : float(fields[7]),
            'target_processing_time'  : float(fields[8]),
            'response_processing_time' : float(fields[9]),
            'user_agent'              : fields[17],
            'request_creation_time'   : fields[25],
            'actions_executed'        : fields[26]
        })
    else:
        lineout = "Unkown output format "+outputformat+" . raw = "+line
    return int(timestamp),lineout
    
def lambda_handler(event, context):
    print(event)
    
    s3info = event['Records'][0]['s3']
    s3bucket = s3info['bucket']['name']
    s3objectkey = urllib.parse.unquote(s3info['object']['key'])
    s3objectsize = s3info['object']['size']
    
    now = datetime.datetime.now()
    loggroup = os.environ.get('CloudWatch_LogGroup', '')
    inputformat = os.environ.get('InputFormat', '')
    outputformat = os.environ.get('OutputFormat', '')
    if (loggroup == ''):
        raise ValueError("You must define the CloudWatch_LogGroup env var with a CloudWatch Logs group name")
    if (inputformat == '' or outputformat == ''):
        logging.warning("Env var InputFormat or OutputFormat not defined, log stream will not be converted before sending to CloudWatch Logs") 
    logstream = now.strftime("%Y-%m-%d") 
    createLogGroupAndStream(loggroup, logstream)
    
    localfile_fd, localfile_unzipped = tempfile.mkstemp()
    os.close(localfile_fd)
    localfile_gzipped = localfile_unzipped+".gz"
    print(" Bucket : " + s3bucket)
    print("    key : " + s3objectkey)
    print("   size : " + str(s3objectsize))
    print("  local : " + localfile_unzipped)
    
    # Copy S3 to local
    try:
        GLOBAL_S3.Bucket(s3bucket).download_file(s3objectkey, localfile_gzipped)
    except botocore.exceptions.ClientError as e:
        if e.response['Error']['Code'] == "404":
            print("The object does not exist.")
        else:
            raise
    # Gunzip local file
    print(subprocess.check_output(['gunzip', '-f', localfile_gzipped])) #  gzip command create .gz file
    print("Unzipped file :")
    print(subprocess.check_output(['ls','-la', localfile_unzipped])) #  gzip command create .gz file
    if (inputformat == 'cloudfront'):
        print("Removing comment line")
        print(subprocess.check_output(['sed', '-i', '/^#/ d', localfile_unzipped])) #  Remove line with comment ()
    print("Sorting file")
    if (inputformat == 'alb') :
        # ALB format must be sorted on col2 (datetime)
        print(subprocess.check_output(['sort', '-k2', '-o', localfile_unzipped,  localfile_unzipped]))
    elif (inputformat == 'cloudfront'):
        # Cloudfront format must be sorted on col 2 and 3 (date and time)
        print(subprocess.check_output(['sort', '-k2,3', '-o', localfile_unzipped,  localfile_unzipped]))
    
    print("Get next sequence token")
    response = GLOBAL_CWL.describe_log_streams(
        logGroupName=loggroup,
        logStreamNamePrefix=logstream,
        orderBy='LogStreamName'
    )
    nextToken = response['logStreams'][0].get('uploadSequenceToken', None)
    
    # Read event line by line, create a buffer, send the buffer every 500 log
    events = []
    f = open(localfile_unzipped, 'rt')
    i = 0
    for line in f:
        i = i + 1
        if (inputformat == 'alb'):
            timestamp, message = alb_read_and_convert(i, line, outputformat)
        else:
            message = "LAMBDA ERROR : input format " + inputformat + " is unkown !"
            timestamp = 1000 * time.time()
        if (timestamp == 0 or message == None):
            logging.warning("This line is invalid : " + line)
        else:
            ev = {'timestamp' : timestamp, 'message' : message}
            events.append(ev)
            if (i == 1):
                print("First event : ")
                print(line)
            if (i % 500 == 0): # a higher value may result of a buffer overflow from Boto3 because you cant send more than 1MB of events in one call
                print("Send events " + str(i))
                response = streamevents(events, nextToken, loggroup, logstream)
                nextToken = response['nextSequenceToken']
                events = []
    streamevents(events, nextToken, loggroup, logstream)

    print("Last event : ")
    print(line)
            
    print(str(i) + " events sent to CloudWatch Logs")
        
    if os.path.exists(localfile_unzipped):
        os.remove(localfile_unzipped)
    if os.path.exists(localfile_gzipped):
        os.remove(localfile_gzipped)

    return True
