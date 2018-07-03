exports.handler = (event, context, callback) => Promise.resolve(event)
  .then(() => {
    console.log(JSON.stringify(event));

    // const response = {
    //   "statusCode": 200,
    //   "headers": {
    //   },
    //   "body": "hi",
    //   "isBase64Encoded": false
    // };
    // callback(null, response);

    const response = {
      "statusCode": 302,
      "headers": {
        "Location": event['queryStringParameters']['o']
      },
      "body": null,
      "isBase64Encoded": false
    };
    callback(null, response);
  })
  .catch(callback);
