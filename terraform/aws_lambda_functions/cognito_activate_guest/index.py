import boto3
from botocore.exceptions import ClientError
import time
import os


#
# CHANGE CONGNITO USER PASSWORD
# e.g userpoolid = 'us-east-2_fdsf1Ss3'
#

def lambda_handler(event,context) :

    userpoolid = os.getenv('USER_POOL_ID')
    username   = "guest"
    bucket     = event['Records'][0]["s3"]["bucket"]["name"]
    key        = event['Records'][0]["s3"]["object"]["key"]
    print(key)
    # Create an S3 client
    s3 = boto3.client('s3')

    # Use the S3 client to get the object from the bucket
    response = s3.get_object(Bucket=bucket, Key=key)

    # read the contents of the object
    password = response['Body'].read().decode('utf-8')
    if not password.isnumeric():
        print("The password string is not a number! Exiting...")
        return

    if key !="files/guestpin.txt" :
        print("File created:", key)
        return

    try:
        client = boto3.client('cognito-idp')

        response = client.list_users(
            UserPoolId= userpoolid,
            Filter = "username = \"%s\"" % username
        )

        if response["Users"] :

            response = client.admin_enable_user(
                UserPoolId=userpoolid,
                Username=username
            )

            passmsg = client.admin_set_user_password(
                UserPoolId=userpoolid,
                Username=username,
                Password=password,
                Permanent=True 
            )
            message = "Password is chganged for user %s !" % username
        else:
            message = "User %s does NOT exists!" % username
            return
        

    except ClientError as e:
        message = 'Error changing password: {}'.format(e)
        print('Error changing password: {}'.format(e))

    print(message)
    return(message)    


