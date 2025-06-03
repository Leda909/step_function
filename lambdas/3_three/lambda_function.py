import boto3
import os
import logging
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    bucket = os.environ['BUCKET_TWO']
    key = 'processed_data.txt'

    try:
        logger.info("Final Lambda started")

        # Random hibadobás 30% eséllyel
        if random.random() < 0.3:
            logger.error("Final Lambda: Random error triggered!")
            raise Exception("Final Lambda: Random error triggered!")

        obj = s3.get_object(Bucket=bucket, Key=key)
        data = obj['Body'].read().decode('utf-8')
        logger.info(f"Final Lambda received data: {data}")

        return {'status': 'forwarded'}

    except Exception as e:
        logger.error(f"Final Lambda failed: {e}", exc_info=True)
        return { 'status' : 500 , 'Body' : f"Final Lambda failed: {e}"}
