import boto3
import os

TABLE_NAME = os.environ.get("TABLE_NAME", None)
Table      = boto3.resource("dynamodb").Table(TABLE_NAME)

def handler(_1, _2) -> dict:
  id = "id"
  Table.put_item(Item={"id": id}) # => Test Dynamo-Permissions
  Table.get_item(Key ={"id": id})
  Table.delete_item(Key={"id": id})
  return {
    "body":       "Hello World!",
    "statusCode": 200,
  }
