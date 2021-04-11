var AWS = require('aws-sdk');
// Set the region 
AWS.config.update({region: 'us-east-2'});

// Create the DynamoDB service object
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});

exports.handler = async (event, context, callback) => {
  
    //TODO: if cluster contains trade entities, should this implicitly trigger a request to trade?
    //answer to this request could contain number of approved trades... but what about other client?
    
    if(!(event.queryStringParameters.surfaceName && event.queryStringParameters.x && event.queryStringParameters.y && event.queryStringParameters.content))
    {
      const response = {
        statusCode: 400,
        body: JSON.stringify('request malformed'),
      };
      return response;
    }

    console.log("set cluster: ", event.queryStringParameters.surfaceName, event.queryStringParameters.x, event.queryStringParameters.y);

    var params = {
      TableName: 'FactorioWEPClusters',
      Item: {
        'ClusterID' : {S: event.queryStringParameters.surfaceName + ":" + event.queryStringParameters.x + ":" + event.queryStringParameters.y},
        'Content' : {S: event.queryStringParameters.content}
      }
    };
    
    var returnCode = 500;
    
    // Call DynamoDB to add the item to the table
    try {
      var result = ddb.putItem(params).promise();
      await(result);
      console.log("Success", result);
      returnCode = 200;
    } catch (err) {
      console.log("Error", err);
    }

    const response = {
        statusCode: returnCode,
        body: JSON.stringify('success'),
    };
    return response;
};
