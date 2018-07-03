exports.handler = (event, context, callback) => Promise.resolve(event)
  .then(() => {
    const response = {
      "statusCode": 302,
      "headers": {
        "Location": event['queryStringParameters']['o']
      },
      "isBase64Encoded": false
    };
    callback(null, response);
  })
  .catch(callback);
