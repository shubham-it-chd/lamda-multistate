import json
import logging
import os
import boto3
from datetime import datetime
from typing import Dict, Any

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function handler for sample two
    
    This function demonstrates more advanced features including:
    - AWS SDK usage
    - Error handling
    - Custom environment variables
    
    Args:
        event: AWS Lambda event object
        context: AWS Lambda context object
        
    Returns:
        dict: Response with status code and body
    """
    
    logger.info(f"Lambda Sample Two invoked with event: {json.dumps(event)}")
    
    # Get environment variables
    function_name = context.function_name
    function_version = context.function_version
    environment = os.environ.get('ENVIRONMENT', 'dev')
    custom_message = os.environ.get('CUSTOM_MESSAGE', 'Hello from Lambda Sample Two!')
    aws_region = os.environ.get('AWS_REGION', 'us-east-1')
    
    try:
        # Initialize AWS clients
        lambda_client = boto3.client('lambda')
        
        # Get account information
        sts_client = boto3.client('sts')
        account_info = sts_client.get_caller_identity()
        
        # Process different event types
        event_type = event.get('eventType', 'default')
        processed_data = process_event(event, event_type)
        
        response_body = {
            'message': custom_message,
            'function_name': function_name,
            'function_version': function_version,
            'environment': environment,
            'aws_region': aws_region,
            'account_id': account_info.get('Account'),
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'processed_data': processed_data,
            'request_id': context.aws_request_id,
            'remaining_time_ms': context.get_remaining_time_in_millis()
        }
        
        logger.info(f"Processing completed successfully for event type: {event_type}")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'X-Function-Name': function_name,
                'X-Request-ID': context.aws_request_id
            },
            'body': json.dumps(response_body, indent=2)
        }
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}", exc_info=True)
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e),
                'function_name': function_name,
                'request_id': context.aws_request_id,
                'timestamp': datetime.utcnow().isoformat()
            })
        }

def process_event(event: Dict[str, Any], event_type: str) -> Dict[str, Any]:
    """
    Process different types of events
    
    Args:
        event: The event data
        event_type: Type of event to process
        
    Returns:
        dict: Processed event data
    """
    
    if event_type == 'api_gateway':
        return {
            'method': event.get('httpMethod', 'Unknown'),
            'path': event.get('path', 'Unknown'),
            'query_params': event.get('queryStringParameters', {}),
            'headers': len(event.get('headers', {}))
        }
    elif event_type == 'sqs':
        return {
            'records_count': len(event.get('Records', [])),
            'message_ids': [record.get('messageId') for record in event.get('Records', [])]
        }
    elif event_type == 's3':
        return {
            'records_count': len(event.get('Records', [])),
            'buckets': list(set([
                record.get('s3', {}).get('bucket', {}).get('name') 
                for record in event.get('Records', [])
            ]))
        }
    else:
        return {
            'event_size': len(str(event)),
            'top_level_keys': list(event.keys()),
            'processed_as': 'default'
        }
