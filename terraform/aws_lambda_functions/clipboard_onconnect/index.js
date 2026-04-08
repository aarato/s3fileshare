const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, PutCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const ddb = DynamoDBDocumentClient.from(client);

exports.lambda_handler = async event => {
  const putParams = {
    TableName: process.env.TABLE_NAME,
    Item: {
      connectionId: event.requestContext.connectionId
    }
  };

  try {
    console.log("BEFORE WRITE CONN TO DB:", event.requestContext.connectionId);
    await ddb.send(new PutCommand(putParams));
    console.log("AFTER WRITE CONN TO DB:", event.requestContext.connectionId);
  } catch (err) {
    console.log("MY CONNECT ERROR", err);
    return { statusCode: 500, body: 'Failed to connect: ' + JSON.stringify(err) };
  }
  return { statusCode: 200, body: 'Connected.' };
};
