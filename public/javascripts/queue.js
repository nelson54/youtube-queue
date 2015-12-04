var $ = require('jquery-browserify');
var youtubeVideo = require('youtube-video');

function Queue(links){

    function start(){
        if(links.length > 0){
            nextLink();
        }
    }

    function playCurrentLink(siteId){
        youtubeVideo(siteId, {
            elementId: 'youtube-video',
            width: 640,
            height: 390,
            autoplay: true,
            onEnd: nextLink
        });
    }

    function nextLink(){
        var currentLink = links.pop();
        playCurrentLink(currentLink.siteId);
    }

    return {start: start}
}

$(function(){
    var roomId = $('#player').data('roomId');

    $.ajax('/rooms/'+roomId+'/links')
        .success(function(json){
            var links = JSON.parse(json).links.reverse();
            var queue = Queue(links);
            queue.start();

        });
});