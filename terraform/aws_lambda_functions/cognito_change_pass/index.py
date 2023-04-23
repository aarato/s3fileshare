import boto3
from botocore.exceptions import ClientError
import time

#
# CHANGE CONGNITO USER PASSWORD
# e.g userpoolid = 'us-east-2_fdsf1Ss3'
#

def lambda_handler(event,context) :
    
    try:
        client = boto3.client('cognito-idp')
        body = event['body']
        userpoolid = body["userpoolid"]
        username = body["username"]
        password = body["password"]

        response = client.list_users(
            UserPoolId= userpoolid,
            Filter = "username = \"%s\"" % username
        )

        if response["Users"] :
            passmsg = client.admin_set_user_password(
                UserPoolId=userpoolid,
                Username=username,
                Password=password,
                Permanent=True 
            )
            message = "Password is chganged for user %s !" % username
        else:
            message = "User %s does NOT exists!" % username

    except ClientError as e:
        message = 'Error changing password: {}'.format(e)
        print('Error changing password: {}'.format(e))

    print(message)
    return(message)
