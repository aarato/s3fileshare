const AWS = require('aws-sdk');

const ddb = new AWS.DynamoDB.DocumentClient({ apiVersion: '2012-08-10', region: process.env.AWS_REGION });

exports.lambda_handler = async event => {
  const deleteParams = {
    TableName: process.env.TABLE_NAME,
    Key: {
      connectionId: event.requestContext.connectionId
    }
  };

  try {
    console.log("BEFORE WRITE CONN TO DB:",event.requestContext.connectionId)
    await ddb.delete(deleteParams).promise();
    console.log("AFTER WRITE CONN TO DB:",event.requestContext.connectionId)
  } catch (err) {
    console.log("MY DISCONNECT ERROR",err)
    return { statusCode: 500, body: 'Failed to disconnect: ' + JSON.stringify(err) };
  }

  return { statusCode: 200, body: 'Disconnected.' };
};
