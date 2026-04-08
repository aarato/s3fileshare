import json
import boto3
import os
from botocore.exceptions import ClientError


def lambda_handler(event, context):
    try:
        body = json.loads(event.get('body') or '{}')
    except json.JSONDecodeError:
        return resp(400, {'error': 'Invalid request body'})

    username = (body.get('username') or '').strip()
    password = (body.get('password') or '').strip()

    if not username or not password:
        return resp(400, {'error': 'username and password are required'})

    client = boto3.client('cognito-idp', region_name=os.environ['REGION'])

    try:
        result = client.initiate_auth(
            AuthFlow='USER_PASSWORD_AUTH',
            AuthParameters={
                'USERNAME': username,
                'PASSWORD': password,
            },
            ClientId=os.environ['COGNITO_CLIENT_ID']
        )
        auth = result['AuthenticationResult']
        return resp(200, {
            'idToken':      auth['IdToken'],
            'accessToken':  auth['AccessToken'],
            'refreshToken': auth['RefreshToken'],
            'expiresIn':    auth['ExpiresIn'],
        })
    except ClientError as e:
        code = e.response['Error']['Code']
        if code in ('NotAuthorizedException', 'UserNotFoundException'):
            return resp(401, {'error': 'Invalid username or password'})
        print(f"Cognito error: {e}")
        return resp(500, {'error': 'Authentication failed'})


def resp(status_code, body):
    return {
        'statusCode': status_code,
        'headers': {'Content-Type': 'application/json'},
        'body': json.dumps(body),
    }
