const AWS = require('aws-sdk');

const ddb = new AWS.DynamoDB.DocumentClient({ apiVersion: '2012-08-10', region: process.env.AWS_REGION });

exports.lambda_handler = async event => {
  const putParams = {
    TableName: process.env.TABLE_NAME,
    Item: {
      connectionId: event.requestContext.connectionId
    }
  };

  try {
    console.log("BEFORE WRITE CONN TO DB:",event.requestContext.connectionId)
    await ddb.put(putParams).promise();
    console.log("AFTER WRITE CONN TO DB:",event.requestContext.connectionId)
  } catch (err) {
    console.log("MY CONNECT ERROR",err)
    return { statusCode: 500, body: 'Failed to connect: ' + JSON.stringify(err) };
  }
  return { statusCode: 200, body: 'Connected.' };
};
