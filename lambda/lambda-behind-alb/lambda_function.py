import json
import base64

def lambda_handler(event, context):
    print(context)

    body = event.get('body')

    if event.get('isBase64Encoded'):
        body = base64.b64decode(body).decode('utf-8')

    body = json.loads(body)

    username = body.get('username')
    password = body.get('password')

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Hello from Lambda!",
            "username": username,
            "password": password,
        })
    }
