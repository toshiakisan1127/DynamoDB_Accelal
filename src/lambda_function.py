import pytz
import logging
import json

from datetime import datetime

logger = logging.getLogger('lambda_logger')
logger.setLevel(logging.INFO)


def lambda_handler(event: dict, context):
    logger.info('function = %s, version = %s, request_id = %s',
                context.function_name, context.function_version, context.aws_request_id)
    logger.info('event = %s', event)
    UTC = pytz.timezone('UTC')
    now = datetime.now(UTC)
    timestamp = now.timestamp()
    return build_response(200, timestamp)


def build_response(code: int, timestamp):
    responseBody = {"time": timestamp}
    return {
        'isBase64Encoded': False,
        'statusCode': code,
        'headers': {},
        'body': json.dumps(responseBody)
    }
