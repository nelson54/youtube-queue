var $ = require('jquery-browserify');
var youtubeVideo = require('youtube-video');

function Queue(links){
    var currentLinkId;

    function start(){
        if(links.length > 0){
            nextLink();
        }
    }

    function playCurrentLink(link){
        youtubeVideo(link.siteId, {
            width: 640,
            height: 390,
            autoplay: true,
            onEnd: nextLink
        });
    }

    function nextLink(){
        currentLinkId = links.pop();
        playCurrentLink(currentLinkId);
    }

    return {start: start}
}

$(function(){
    $.ajax('/rooms/yY960TePXu/links')
        .success(function(json){
            var links = JSON.parse(json).links.reverse();
            var queue = Queue(links);
            queue.start();

        });
});