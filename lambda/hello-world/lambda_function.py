import json

def lambda_handler(event, context):
    print(context)

    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!'),
        'event': json.dumps(event),
    }

