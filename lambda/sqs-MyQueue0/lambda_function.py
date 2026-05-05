import json

def lambda_handler(event, context):
    print("Received event:")
    print(json.dumps(event, indent=2))

    print("\nBody (parsed):")

    # Step 1: parse SQS body string
    body = json.loads(event["Records"][0]["body"])

    # Step 2: parse SNS "Message" if it's JSON (optional)
    try:
        body["Message"] = json.loads(body["Message"])
    except (json.JSONDecodeError, TypeError):
        pass

    print(json.dumps(body, indent=2))
