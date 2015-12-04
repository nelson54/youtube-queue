var $ = require('jquery-browserify');
var youtubeVideo = require('youtube-video');

function Queue(currentLinks){

    var currentLink;

    var links = processLinks(currentLinks);
    links = sortLinks(links);

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
            if(link) {
                currentLink = link;
                playCurrentLink(currentLink.siteId);
            }
        });
    }

    function popCurrentLink(callback){
        if(currentLink) {
            $.ajax('/rooms/' + roomId + '/links/' + currentLink.id + '/remove')
                .success(function (currentLinks) {
                    links = processLinks(currentLinks);
                    links = sortLinks(links);
                    callback(links.pop());
                })
        } else if (links.length > 0) {
            callback(links[0])
        }
    }

    function processLinks(links){
        return Object.keys(links).map(function(id){
            var value = links[id];
            value.id = id;

            return value;
        })
    }

    function sortLinks(links){
        return links
    }

    return {start: start}
}

$(function(){
    var roomId = window.roomId = $('#player').data('roomId');

    $.ajax('/rooms/'+roomId+'/links')
        .success(function(json){
            var links = JSON.parse(json).links;
            var queue = Queue(links);
            queue.start();

        })
        .done(function(error){
            console.log(error);
        });
});