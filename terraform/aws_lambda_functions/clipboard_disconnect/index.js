const { DynamoDBClient } = require('@aws-sdk/client-dynamodb');
const { DynamoDBDocumentClient, DeleteCommand } = require('@aws-sdk/lib-dynamodb');

const client = new DynamoDBClient({ region: process.env.AWS_REGION });
const ddb = DynamoDBDocumentClient.from(client);

exports.lambda_handler = async event => {
  const deleteParams = {
    TableName: process.env.TABLE_NAME,
    Key: {
      connectionId: event.requestContext.connectionId
    }
  };

  try {
    console.log("BEFORE DELETE CONN FROM DB:", event.requestContext.connectionId);
    await ddb.send(new DeleteCommand(deleteParams));
    console.log("AFTER DELETE CONN FROM DB:", event.requestContext.connectionId);
  } catch (err) {
    console.log("MY DISCONNECT ERROR", err);
    return { statusCode: 500, body: 'Failed to disconnect: ' + JSON.stringify(err) };
  }

  return { statusCode: 200, body: 'Disconnected.' };
};
