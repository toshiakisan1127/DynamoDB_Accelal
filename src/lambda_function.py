from functools import wraps
from operator import imod
import time
import pytz
import logging
import json
import boto3
import os

from datetime import datetime
from aws_xray_sdk.core import patch_all
import amazondax

logger = logging.getLogger('lambda_logger')
logger.setLevel(logging.INFO)
patch_all()

DAX_URL = os.getenv("DAX_URL")


def stop_watch(func):
    @wraps(func)
    def wrapper(*args, **kargs):
        start = time.time()
        result = func(*args, **kargs)
        elapsed_time = time.time() - start
        print(f"{func.__name__}は{elapsed_time}秒かかりました")
        return result
    return wrapper


@stop_watch
def lambda_handler(event: dict, context):
    logger.info('function = %s, version = %s, request_id = %s',
                context.function_name, context.function_version, context.aws_request_id)
    logger.info('event = %s', event)

    dynamodb_client = DynamodbClient()
    table_name = "dax_test_table"
    UTC = pytz.timezone('UTC')
    now = datetime.now(UTC)
    timestamp = now.timestamp()

    # N回put
    N = 5
    for i in range(N):
        item = {
            "user_id": str(i),
            "test": "hoge"
        }
        try:
            dynamodb_client.put_item(table_name=table_name, item=item)
        except Exception as e:
            logger.error("dynamodbへのput操作でエラーが発生しました。: {}".format(e))
            return ApiGatewayResponse.build_response(500, timestamp)
        logger.info("put item : {}".format(item))

    # N回getをM回くりかえす
    M = 2
    for _ in range(M):
        for i in range(N):
            key = {
                "UserId": {"S": str(i)}
            }
            try:
                item = dynamodb_client.get_item(table_name=table_name, key=key)
            except Exception as e:
                logger.error("dynamodbへのget操作でエラーが発生しました。: {}".format(e))
                return ApiGatewayResponse.build_response(500, timestamp)
            logger.info("get item : {}".format(item))

    # N回消す
    for i in range(N):
        key = {
            "UserId": {"S": str(i)}
        }
        try:
            deleted_item = dynamodb_client.delete_item(
                table_name=table_name,
                key=key
            )
        except Exception as e:
            logger.error("dynamodbへのdelete操作でエラーが発生しました。: {}".format(e))
            return ApiGatewayResponse.build_response(500, timestamp)
        logger.info("deleted item : {}".format(deleted_item))

    return ApiGatewayResponse.build_response(200, timestamp)


class DynamodbClient:

    def __init__(self):
        # self.client = boto3.client("dynamodb")
        self.client = amazondax.AmazonDaxClient(endpoint_url=DAX_URL)

    def put_item(self, table_name: str, item: dict):
        dynamodb_item = self._dict_to_dynamodb_item_for_dax_test_table(item)
        self.client.put_item(
            TableName=table_name,
            Item=dynamodb_item
        )
        return None

    def get_item(self, table_name: str, key: dict):
        item = self.client.get_item(
            TableName=table_name,
            Key=key
        )
        return item

    def delete_item(self, table_name: str, key: dict):
        return self.client.delete_item(
            TableName=table_name,
            Key=key
        )

    def _dict_to_dynamodb_item_for_dax_test_table(self, item: dict):
        return {
            "UserId": {"S": item["user_id"]},
            "test": {"S": item["test"]}
        }


class ApiGatewayResponse:

    @staticmethod
    def build_response(code: int, timestamp):
        responseBody = {"time": timestamp}
        return {
            'isBase64Encoded': False,
            'statusCode': code,
            'headers': {},
            'body': json.dumps(responseBody)
        }
