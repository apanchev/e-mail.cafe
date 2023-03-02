#/usr/bin/python3

import boto3, os

def lambda_handler(event, context):
  try:
    print(context)
    print(event)
    print(event['Records'][0]['ses']['mail']['messageId'])
    msgId = event['Records'][0]['ses']['mail']['messageId']
  except Exception as err:
    print("ERROR while trying to get message ID ...")
    print(f"Unexpected {err=}, {type(err)=}")
    raise

  try:
    print(event['Records'][0]['ses']['mail']['destination'][0])
    raw_dest = event['Records'][0]['ses']['mail']['destination'][0]
    dest = raw_dest.partition('@')[0]
  except Exception as err:
    print("ERROR while trying to get destination ...")
    print(f"Unexpected {err=}, {type(err)=}")
    raise

  try:
    BUCKET_NAME = os.environ['BUCKET_NAME']
    SOURCE_PATH = os.environ['SES_OBJECT_KEY_PREFIX'] + msgId
    print(f"{BUCKET_NAME} - {SOURCE_PATH}")

    s3 = boto3.resource("s3")
    s3.Object(BUCKET_NAME, f"inbox/{dest}/{msgId}").copy_from(CopySource=f"{BUCKET_NAME}/{SOURCE_PATH}")
    s3.Object(BUCKET_NAME, SOURCE_PATH).delete()
  except Exception as err:
    print("ERROR while trying to move file in S3 ...")
    print(f"Unexpected {err=}, {type(err)=}")
    raise

  return 200