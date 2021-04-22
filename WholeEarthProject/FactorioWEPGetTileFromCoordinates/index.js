exports.handler = async (event) => {
    
    //TODO should this interface even accept the surface name?
    if(!(typeof event.queryStringParameters.surfaceName != "undefined" && typeof event.queryStringParameters.lat != "undefined"&& typeof event.queryStringParameters.lon != "undefined"))
    {
      const response = {
        statusCode: 400,
        body: JSON.stringify('request malformed'),
      };
      return response;
    }
    console.log('Request tile from coordinates:', event.queryStringParameters.surfaceName, " lat:", event.queryStringParameters.lat, " lon:", event.queryStringParameters.lon);
    
    var zoom_level = 2;
    var num_chunks = Math.pow(2, zoom_level) * 8; //in Web_Mercator_projection there are 256 pixels for an image, in factorio there are 32 tiles per chunk, so multiply by 8. also zoom is a subdivision (e.g. zoom=0 is 2^0 image, zoom=4 is 2^4 images);
    var num_pixels = num_chunks * 32
    var latitude = parseFloat(event.queryStringParameters.lat);
    var longitude = parseFloat(event.queryStringParameters.lon);
    if(latitude > 85.051129) latitude = 85.051129
    if(latitude < -85.051129) latitude = -85.051129
    if(longitude > 180.0) longitude = 180.0
    if(longitude < -180.0) longitude = -180.0
    latitude = latitude * 2 * Math.PI / 360
    longitude = longitude * 2 * Math.PI / 360
    var x = (256/(2*Math.PI)) * Math.pow(2, zoom_level) * (longitude + Math.PI)
    var y = (256/(2*Math.PI)) * Math.pow(2, zoom_level) * (Math.PI - Math.log(Math.tan((Math.PI/4) + (latitude/2))))
    const response = {
      statusCode: 200,
      body: JSON.stringify({x:x,y:y}),
    };
    return response;
    
};

