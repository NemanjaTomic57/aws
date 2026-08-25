import json

def lambda_handler(event, context):
    print(event)

    headers = event['headers']
    queryStringParameters = event['queryStringParameters']
    pathParameters = event['pathParameters']
    stageVariables = event['stageVariables']

    if (headers['authorization'] == "abvfiurwahgoiewb98213891723" and queryStringParameters['name'] == "NemanjaTomic" and stageVariables['Version'] == "latest"):
        response = generateAllow('me', event['methodArn'])
        print('authorized')
        return response
    else:
        print('unauthorized')
        response = generateDeny('me', event['methodArn'])
        return response

def generatePolicy(principleId, effect, resource):
    authResponse = {}
    authResponse['principalId'] = principleId
    if (effect and resource):
        policyDocument = {}
        policyDocument['Version'] = '2012-10-17'
        policyDocument['Statement'] = []
        statementOne = {}
        statementOne['Action'] = 'execute-api:Invoke'
        statementOne['Effect'] = effect
        statementOne['Resource'] = resource
        policyDocument['Statement'] = [statementOne]
        authResponse['policyDocument'] = policyDocument

    authResponse['context'] = {
        "stringKey": "stringVal",
        "numberKey": 123,
        "booleanKey": True,
        "property": "Hello, World!"
    }

    return authResponse

def generateAllow(principleId, resource):
    return generatePolicy(principleId, 'Allow', resource)

def generateDeny(principleId, resource):
    return generatePolicy(principleId, 'Deny', resource)
