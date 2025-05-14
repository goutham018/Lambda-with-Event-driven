import json
import boto3

# Initialize the EventBridge client
eventbridge_client = boto3.client('events')

# Event bus name
eventbus_name = 'my-event-bus'

def lambda_handler(event, context):
    print("Received event:", json.dumps(event))
    
    # Support both direct test and API Gateway
    if 'body' in event:
        # If invoked from API Gateway, 'body' is a JSON string
        body = json.loads(event['body'])
    else:
        # If invoked directly, assume it's already a dict
        body = event

    # Extract client details
    client_name = body['client-name']
    client_number = body['client-number']
    client_type = body['client-type']
    
    # Define the event detail
    event_detail = {
        'client-name': client_name,
        'client-number': client_number,
        'client-type': client_type
    }

    # Send to EventBridge
    response = eventbridge_client.put_events(
        Entries=[
            {
                'Source': 'lambda-client',
                'DetailType': 'client-details',
                'Detail': json.dumps(event_detail),
                'EventBusName': eventbus_name
            }
        ]
    )

    print("Event sent to EventBridge:", response)

    return {
        'statusCode': 200,
        'body': json.dumps('Event sent successfully to EventBridge!')
    }
