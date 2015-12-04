var YouTubeData = require('./youtube-data');

module.exports = function(){
    return YouTubeData(process.env['google-api-key']);
};