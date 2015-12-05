var $ = require('jquery-browserify');
var youtubeVideo = require('youtube-video');

function Queue(currentLinks){

    var currentLink;

    var links = processLinks(currentLinks);
    links = sortLinks(links);

    function start(){
        if(links.length > 0){
            nextLink();
            setInterval(checkIfVideoIsCancelled, 2000)
        }
    }

    function playCurrentLink(siteId){
        youtubeVideo(siteId, {
            elementId: 'player',
            selector: 'youtube-player',
            width: 1280,
            height: 720,
            autoplay: true,
            controls: true,
            onEnd: nextLink
        });

        $('#player').attr('style', 'margin: 0; position: absolute; left: 50%; top: 50%; transform: translate(-50%, -50%); width: 100%; height: 100%;')
    }

    function nextLink(){
        popCurrentLink(function(link){
            if(link) {
                currentLink = link;
                $('iframe').unbind();
                $('#player, #youtube-video').remove();
                $('body').append('<div id="player"><div id="youtube-video"></div></div>');
                playCurrentLink(currentLink.siteId);
            }
        });
    }

    function checkIfVideoIsCancelled() {
        $.ajax('/rooms/' + roomId + '/links/' + currentLink.id + '/remove')
            .success(function (currentLinks) {
                var exists = false;
                links = processLinks(currentLinks);
                links = sortLinks(links);
                for(var i in links){
                    if(links[i].id == currentLink.id) {
                        exists = true;
                        break;
                    }
                }

                if(!exists){
                    currentLink = null;
                    nextLink();
                }
            })
    }

    function popCurrentLink(callback){
        if(currentLink) {
            $.ajax('/rooms/' + roomId + '/links')
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