import boto3
import time

def lambda_handler(event,context) :
    
    client = boto3.client('cognito-idp')
    userpoolid = event["userpoolid"]
    username = event["username"]
    password = event["password"]

    # userpoolid = 'us-east-2_fdsf1Ss3'

    response = client.list_users(
        UserPoolId= userpoolid,
        Filter = "username = \"%s\"" % username
    )

    if response["Users"] :
        message = "User %s already exists!" % username
    else:
        response = client.admin_create_user(
            UserPoolId=userpoolid,
            Username = username,
            UserAttributes=[
                {
                    'Name': 'email',
                    'Value': 'ucipass@gmail.com'
                },
            ],
            TemporaryPassword= password,
            ForceAliasCreation=False,
            MessageAction='SUPPRESS',
        )

        while not client.list_users( UserPoolId=userpoolid, Filter = "username = \"%s\"" % username ) :
            time.sleep(1)
            print("waiting for user to get created!")

        response = client.admin_set_user_password(
            UserPoolId= userpoolid,
            Username= username,
            Password= password,
            Permanent=True
        )    
        message = "User %s is created." % username
    print(message)
    return(message)
