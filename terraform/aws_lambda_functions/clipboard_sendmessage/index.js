const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, ScanCommand, DeleteCommand } = require('@aws-sdk/lib-dynamodb');
const { ApiGatewayManagementApiClient, PostToConnectionCommand } = require('@aws-sdk/client-apigatewaymanagementapi');

const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION });
const ddb = DynamoDBDocumentClient.from(dynamoClient);

const { TABLE_NAME } = process.env;

exports.lambda_handler = async event => {
  let connectionData;

  try {
    connectionData = await ddb.send(new ScanCommand({ TableName: TABLE_NAME, ProjectionExpression: 'connectionId' }));
  } catch (e) {
    console.log("MY SENDMESSAGE ERROR", e);
    return { statusCode: 500, body: e.stack };
  }

  const apigwManagementApi = new ApiGatewayManagementApiClient({
    endpoint: 'https://' + event.requestContext.domainName + '/' + event.requestContext.stage
  });

  const postData = JSON.parse(event.body).data;

  const postCalls = connectionData.Items.map(async ({ connectionId }) => {
    try {
      await apigwManagementApi.send(new PostToConnectionCommand({ ConnectionId: connectionId, Data: postData }));
    } catch (e) {
      if (e.$metadata?.httpStatusCode === 410) {
        console.log(`Found stale connection, deleting ${connectionId}`);
        await ddb.send(new DeleteCommand({ TableName: TABLE_NAME, Key: { connectionId } }));
      } else {
        console.log("MY SENDMESSAGE ERROR", e);
        throw e;
      }
    }
  });

  try {
    await Promise.all(postCalls);
  } catch (e) {
    console.log("MY SENDMESSAGE ERROR", e);
    return { statusCode: 500, body: e.stack };
  }

  return { statusCode: 200, body: 'Data sent.' };
};
