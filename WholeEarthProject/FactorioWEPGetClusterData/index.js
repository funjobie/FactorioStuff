var AWS = require('aws-sdk');
AWS.config.update({region: 'us-east-2'});
var ddb = new AWS.DynamoDB({apiVersion: '2012-08-10'});
var lambda = new AWS.Lambda({apiVersion: '2015-03-31'});
var Jimp = require('jimp');
var globalMercator = require('global-mercator')

exports.handler = async (event) => {
    
    //TODO:
    //input: ClusterID(surface+x+y)
    //if cluster doesn't exist in DB, generate (e.g. from 1:10 natural earth world model) and store in db
    //output: content from DB
    
    if(!(typeof event.queryStringParameters.surfaceName != "undefined" && typeof event.queryStringParameters.x != "undefined"&& typeof event.queryStringParameters.y != "undefined"))
    {
      const response = {
        statusCode: 400,
        body: JSON.stringify('request malformed'),
      };
      return response;
    }
    console.log('Request parameters: surface:', event.queryStringParameters.surfaceName, " x:", event.queryStringParameters.x, " y:", event.queryStringParameters.y);

    var zoom_level = 2; //for testing; later go for 17
    if(event.queryStringParameters.y < 0)
    {
      const response = {
        statusCode: 400,
        body: JSON.stringify('negative y is not allowed'),
      };
      return response;
    }
    y = event.queryStringParameters.y;
    var num_chunks = Math.pow(2, zoom_level) * 8; //in Web_Mercator_projection there are 256 pixels for an image, in factorio there are 32 tiles per chunk, so multiply by 8. also zoom is a subdivision (e.g. zoom=0 is 2^0 image, zoom=4 is 2^4 images);
    x = event.queryStringParameters.x % num_chunks;
    console.log('wrapped parameters: surface:', event.queryStringParameters.surfaceName, " x:", x, " y:", y);
    
    var cachedAnswer = await GetAnswerFromCache(event.queryStringParameters.surfaceName, x, y);
    if(cachedAnswer.good)
    {
      const response = {
        statusCode: 200,
        body: cachedAnswer.body,
      };
      return response;
    }
    
    //Cluster doesn't exist yet - generate a new one
    var generatedClusterAnswer = await CreateNewCluster(event.queryStringParameters.surfaceName, x, y, zoom_level);
    if(generatedClusterAnswer.good)
    {
      //at this point its clear that the answer is fine - but result should be persisted regardless to answer next request faster
      const response = {
        statusCode: 200,
        body: generatedClusterAnswer.body,
      };
      
      //Delegate to already existing "set cluster" lambda. this could also be done via SNS. Currently implemented synchron, but asynchron would be fine too.
      event.queryStringParameters.content = generatedClusterAnswer.body;
      event.queryStringParameters.x = x;
      event.queryStringParameters.y = y;
      try{
        await(lambda.invoke({
          FunctionName: 'FactorioWEPSetClusterData',
          Payload: JSON.stringify(event, null, 2)
        }).promise());
        console.log("cached cluster successfully");
      } catch (error) {
        console.log("received error when caching cluster creation result");
        console.log(error);
        return response;
      }  
      
      return response;
    }
    else
    {
      console.log("error creating new cluster");
      const response = {
        statusCode: 500,
        body: ''
      };
      return response;
    }
};

async function GetAnswerFromCache(surfaceName, x, y) {

    var result = {
      good: false,
      body: ''
    };

    var params = {
      TableName: 'FactorioWEPClusters',
      Key: {
        'ClusterID' : {S: surfaceName + ":" + x + ":" + y}
      }
      //,ProjectionExpression: 'ATTRIBUTE_NAME' to query only one property of the DynamoDB
    };
        
    // Call DynamoDB to get the item from the table
    try {
      var getItemResult = await ddb.getItem(params).promise();
      if (typeof getItemResult.Item != "undefined")
      {
          result.good = true;
          result.body = getItemResult.Item.Content.S;
          console.log("item found in cache: ", result.body);
      }
      else
      {
        console.log("cluster not found in cache");
      }
    } catch (err) {
      console.log("Error", err);
    }
    
    return result;
}

async function CreateNewCluster(surfaceName, chunk_x, chunk_y, zoom_level) {

    var result = {
      good: false,
      body: ''
    };

    //TODO: correct calculation of pixel to check

    //TODO: currently using https://en.wikipedia.org/wiki/Equirectangular_projection projection
    //because the natural earth is using this format so its a straight translation.
    //possibly another system could be more appealing
    //https://en.wikipedia.org/wiki/Web_Mercator_projection
    //could be used which would make the map more recognizable for users coming from e.g. google maps
    //https://www.maptiler.com/google-maps-coordinates-tile-bounds-projection/
    //zoom level 17:  	1.194328566 meters per pixel(factorio tile tile)
    //https://github.com/DenisCarriere/global-mercator
    //https://www.maptiler.com/google-maps-coordinates-tile-bounds-projection/
    
    var factorio_cluster_size = 32;
    var worldImagePixels_x = 21600;
    var worldImagePixels_y = 10800;
    var worldImageSubdivision_x = 100;
    var worldImageSubdivision_y = 100;
    
    var tiles = [];
    var subImgMap = {};
    
    var s3 = new AWS.S3({});
    
    for (in_chunk_x = 0; in_chunk_x < factorio_cluster_size; ++in_chunk_x)
    {
      for (in_chunk_y = 0; in_chunk_y < factorio_cluster_size; ++in_chunk_y)
      {
        var pixel_x = chunk_x * factorio_cluster_size + in_chunk_x;
        var pixel_y = chunk_y * factorio_cluster_size + in_chunk_y;
        var meters = globalMercator.pixelsToMeters([pixel_x, pixel_y, zoom_level]);
        var lnglat = globalMercator.metersToLngLat(meters);
        
        //TODO fix
        var natural_earth_x = Math.floor(worldImagePixels_x * (lnglat[0] + 180.0) / 360.0);
        var natural_earth_y = Math.floor(worldImagePixels_y * (lnglat[1] + 90.0) / 180.0);
        var pixelX = natural_earth_x % worldImageSubdivision_x;
        var pixelY = natural_earth_y % worldImageSubdivision_y;
        var subImgX = natural_earth_x - pixelX;
        var subImgY = natural_earth_y - pixelY;
        
        
        var fileName = 'world-model/divided-parts/' + subImgX + '/' + subImgY + '.png';
        
        if(typeof subImgMap[fileName] == "undefined")
        {
            console.log('Trying to download file', fileName);
            //TODO rename bucket
            var params = {
              Bucket: 'factorio-world',
              Key: fileName,
            }
            try {
              var imageFile = await s3.getObject(params).promise();
              var image = await Jimp.read(imageFile.Body);
              subImgMap[fileName] = image;
              } catch (error) {
              console.log(error);
              return result;
            }  
        };
        var hex = subImgMap[fileName].getPixelColor(pixelX, pixelY); // returns the colour of that pixel e.g. 0xFFFFFFFF
        var rgba = Jimp.intToRGBA(hex); // e.g. converts 0xFFFFFFFF to {r: 255, g: 255, b: 255, a:255} 
        
        var nearestTile = GetNearestTileName(rgba.r, rgba.g, rgba.b);
        tiles.push(nearestTile);
      }
    }
    
    var encodedTiles = EncodeTiles(tiles);
    
    result.good = true;
    result.body = encodedTiles; //TODO proper list of tiles and entities in this cluster
    return result;
}

function GetNearestTileName(r, g, b) {
    //FactorioWorld uses these nearest color values for conversion:
    //https://github.com/TheOddler/FactorioWorld/blob/master/MapGenerator/convert.py
    //consider including alien biomes too
    var tiles = {
      "deepwater": {r: 89, g: 140, b: 182},
      //"deepwater-green": {r: 24, g: 39, b: 14},
      "water": {r: 114, g: 173, b: 213},
      //"water-green": {r: 30, g: 48, b: 16},
      "grass-1": {r: 145, g: 190, b: 148},
      "grass-3": {r: 180, g: 205, b: 165},
      "grass-2": {r: 212, g: 218, b: 174},
      "dirt-3": {r: 220, g: 220, b: 217},
      "dirt-6": {r: 154, g: 149, b: 135},
      "sand-1": {r: 241, g: 237, b: 209},
      "sand-3": {r: 227, g: 203, b: 188}
    };
    var lowestDif = 9999999;
    var lowestDifTile = "out-of-map";
    for (const [key, value] of Object.entries(tiles)) {
      var dif = Math.abs(r-value.r) + Math.abs(g-value.g) + Math.abs(b-value.b);
      if (dif < lowestDif) {
        lowestDif = dif;
        lowestDifTile = key;
      }
    }
    return lowestDifTile;
}

function EncodeTiles(tiles)
{
    var tilesFrequencies = {}
    var mostFrequentTile = "out-of-map"
    var mostFrequentTileCount = 0;
    var tileOffsetEncodings = {}
    var tileOffsetEncodingsLastPosition = {}
    var index = 0;
    for (const [key, value] of Object.entries(tiles))
    {
      if (typeof tilesFrequencies[value] == "undefined")
      {
        tilesFrequencies[value] = 0;
        tileOffsetEncodings[value] = [];
        tileOffsetEncodingsLastPosition[value] = -1;
      }
      tilesFrequencies[value] = tilesFrequencies[value] + 1;
      if (tilesFrequencies[value] > mostFrequentTileCount)
      {
        mostFrequentTile = value;
        mostFrequentTileCount = tilesFrequencies[value];
      }
      if (tileOffsetEncodingsLastPosition[value] == -1)
      {
        tileOffsetEncodings[value].push(index);
      }
      else
      {
        tileOffsetEncodings[value].push(index - tileOffsetEncodingsLastPosition[value]);
      }
      tileOffsetEncodingsLastPosition[value] = index;
      
      index = index + 1;
    }
    delete tileOffsetEncodings[mostFrequentTile]; //not needed since most frequent will just be stored as default
    
    var resultString = "def:"+mostFrequentTile+";";
    for (const [key, value] of Object.entries(tileOffsetEncodings))
    {
      resultString += (key + ":");
      resultString += value.join(":");
      resultString += ";";
    }
    return resultString;
}
