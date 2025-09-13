import json
import logging
import os
from datetime import datetime

# Configure logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    """
    Lambda function handler for sample one
    
    Args:
        event: AWS Lambda event object
        context: AWS Lambda context object
        
    Returns:
        dict: Response with status code and body
    """
    
    logger.info(f"Received event: {json.dumps(event)}")
    
    # Get environment variables
    function_name = context.function_name
    function_version = context.function_version
    environment = os.environ.get('ENVIRONMENT', 'dev')
    custom_message = os.environ.get('CUSTOM_MESSAGE', 'Hello from Lambda Sample One!')
    
    try:
        # Process the event
        response_body = {
            'message': custom_message,
            'function_name': function_name,
            'function_version': function_version,
            'environment': environment,
            'timestamp': datetime.utcnow().isoformat(),
            'event_received': event,
            'request_id': context.aws_request_id
        }
        
        logger.info(f"Processing completed successfully")
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps(response_body, indent=2)
        }
        
    except Exception as e:
        logger.error(f"Error processing request: {str(e)}")
        
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e),
                'request_id': context.aws_request_id
            })
        }
