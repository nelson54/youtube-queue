var fs = require('fs');
var youtubedl = require('youtube-dl');
var video = youtubedl('http://www.youtube.com/watch?v=90AiXO1pAiA');

// Will be called when the download starts.
video.on('info', function(info) {
    console.log('url: '+ info.url);
    console.log('description: ' + info.display_id);
});
