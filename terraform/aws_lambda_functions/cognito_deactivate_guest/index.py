import boto3



def lambda_handler(event,context) :

    print(event)
    if event["userName"] == "guest" :
        client = boto3.client('cognito-idp')
        response = client.admin_disable_user(
            Username=event["userName"],
            UserPoolId=event["userPoolId"]
        )
    return(event)    


