import boto3
import os
import json
import logging
from random import randint
from botocore.exceptions import ClientError

# Logger beállítása INFO szintre
logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    try:
        logger.info("Lambda function started")

        s3 = boto3.client('s3')
        random_object_name = randint(0, 5)
        random_screen_time_object = s3.get_object(
            Bucket = os.environ['BUCKET_ONE'],
            Key=f"uploads/{random_object_name}.json",
        )

        screen_time = json.loads(random_screen_time_object["Body"].read().decode("utf-8"))

        logger.info(f"App name: {screen_time["app_name"]}")
        logger.info(f"Screen time: {screen_time["screen_time_min"]}")

        return {
            "statusCode" : 200,
            "body" : json.dumps(f"Screen time file {random_object_name} data processed ok.")
        }
    except ClientError:
        logger.error(f"Screen time file {random_object_name} does not exist.")
        return {
            "statusCode" : 404,
            "body" : json.dumps(f"File {random_object_name} does not exist.")
        }
