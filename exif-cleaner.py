import boto3
import io
import os
import logging
from PIL import Image

# set up logging to see logs in CloudWatch
logger = logging.getLogger()
logger.setLevel(logging.INFO)

#  connect to S3
s3_client = boto3.client('s3')

# define specific output bucket
OUTPUT_BUCKET = "aws-exif-scrubber-output"

def handler(event, context):
    # aws lambda handler
    # triggered by S3 object area 

    # get bucket and file name from event trigger 
    for record in event['Records']:
        input_bucket = record['s3']['bucket']['name']
        key = record['s3']['object']['key']

        logger.info(f"Process file: {key} from bucket: {input_bucket}")
        
        try:
            # download img from s3 into memory
            response = s3_client.get_object(Bucket=input_bucket, Key=key)
            image_content = response['Body'].read()

            # open img with pillow
            image = Image.open(io.BytesIO(image_content))

            # scrub exif data
            buffer = io.BytesIO()

            # keep the orginal format
            img_format = image.format if image.format else 'JPEG'
            image.save(buffer, format=img_format, quality=95)
            buffer.seek(0)

            filename = os.path.basename(key)

            s3_client.put_object(
                Bucket=OUTPUT_BUCKET,
                Key=filename,
                Body=buffer,
                ContentType=response['ContentType']
            )

            logger.info(f"Cleaned image saved to {OUTPUT_BUCKET}/{filename}")
            return {'statusCode': 200, 'body': "Success"}
        
        except Exception as e:
            logger.error(f"Error processing image: {str(e)}")
            raise e