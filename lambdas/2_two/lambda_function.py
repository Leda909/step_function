import boto3
import os
import logging
import random

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    s3 = boto3.client('s3')
    source_bucket = os.environ['BUCKET_ONE']
    target_bucket = os.environ['BUCKET_TWO']
    key = 'data.txt'
    new_key = 'processed_data.txt'

    try:
        logger.info("Second Lambda started processing")

        # Random hibadobás 30% eséllyel
        if random.random() < 0.3:
            logger.error("Second Lambda: Random processing error triggered!")
            raise Exception("Second Lambda: Random processing error triggered!")

        obj = s3.get_object(Bucket=source_bucket, Key=key)
        data = obj['Body'].read()

        # Egyszerű transzformáció nagybetussé
        transformed_data = data.upper()

        s3.put_object(Bucket=target_bucket, Key=new_key, Body=transformed_data)
        logger.info(f"Second Lambda: Successfully processed and uploaded to {target_bucket}/{new_key}")
        return {'status': 'processed', 'bucket': target_bucket, 'key': new_key}

    except Exception as e:
        logger.error(f"Second Lambda failed: {e}", exc_info=True)
        return { 'status' : 500 , 'Body' : f"Second Lambda failed: {e}" }


