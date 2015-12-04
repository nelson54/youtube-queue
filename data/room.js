var parse = require('./parse-factory')();
var uuid = require('node-uuid');
var ParseRoom = parse.Object.extend("Room");

function Room(obj) {

    function filterUrlForYoutubeId(link){
        var videoId = link.split('v=')[1];
        var ampersandPosition = videoId.indexOf('&');
        if(ampersandPosition != -1) {
            videoId = videoId.substring(0, ampersandPosition);
        }
        return videoId;
    }

    function getId() {
        return obj.id;
    }

    function setLinks(links) {
        obj.set('links', links);
    }

    function addLink(link) {
        var newLink = {id: uuid.v4(), link: link, votes: 0, site: 'youtube', siteId: filterUrlForYoutubeId(link)};
        var links = getLinks();
        links[newLink.id] = newLink;
        setLinks(links);
    }

    function removeLink(id) {
        var links = getLinks();
        delete links[id];
        setLinks(links);
    }

    function getLinks() {
        return obj.get('links')
    }

    function adjustVote(id, change) {
        var links = getLinks();
        var link = links[id];
        if (link !== undefined &&
              link.votes + change >= 0) {
            link.votes += change;
            setLinks(links);
        }
    }

    function upVote(id) {
        adjustVote(id, 1);
    }

    function downVote(id) {
        adjustVote(id, -1);
    }

    function save(success, error){
        return obj.save(null, {success: success, error: error});
    }

    return {
        getId: getId,
        addLink: addLink,
        removeLink: removeLink,
        getLinks: getLinks,
        upVote: upVote,
        downVote: downVote,
        save: save
    };
}

Room.findOne = function(id) {
    return new parse.Query(ParseRoom)
        .get(id)
        .then(function(room){
            return new Room(room)
        })

};

Room.findAll = function() {
    var query = new parse.Query(ParseRoom);

    return query
        .find()
        .then(function(objs){
            return objs.map(function(obj){
                return new Room(obj)
            });
        })
};

Room.create = function(){
    var room = new ParseRoom();
    room.set('links', {});

    return new Room(room);
};

module.exports = Room;