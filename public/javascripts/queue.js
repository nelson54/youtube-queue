var $ = require('jquery-browserify');
var youtubeVideo = require('youtube-video');

function Queue(links){

    var currentLink;

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
        popCurrentLink(function(link){
            currentLink = link;
            playCurrentLink(currentLink.siteId);
        });
    }

    function processLinks(links){
        Object.keys(links).map(function(id){
            var value = links[id];
            value.id = id;

            return value;
        })
    }

    function popCurrentLink(callback){
        $.ajax('/rooms/'+roomId+'/links/'+currentLink.id+'/remove')
            .success(function(currentLinks){
                var links = processLinks(currentLinks);
                links = sortLinks(currentLinks);
                callback(links.pop());
            })
    }

    function sortLinks(links){

        return links
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