var Promise = require("bluebird"),
request = Promise.promisify(require("request"));

function YouTubeData(apiKey){

    function getUrl(id){
        return 'https://www.googleapis.com/youtube/v3/videos?id='+id+'&key='+apiKey+'&fields=items(id,snippet(title))&part=snippet,statistics'
    }

    function getData(id){
        return request(getUrl(id))
            .then(function(response){
                return JSON.parse(response.body).items[0];
            })
            .then(function(data){
                data.imageSrc = '//i.ytimg.com/vi/' + id + '/default.jpg';
                data.title = data.snippet.title;
                return data;
            })
    }

    return {getData: getData}
}

module.exports = YouTubeData;