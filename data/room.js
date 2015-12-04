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

    function addLink(link) {
        var links = getLinks();
        links.push({id: uuid.v4(), link: link, votes: 0, site: 'youtube', siteId: filterUrlForYoutubeId(link)});
        obj.set('links', links);
    }

    function getLinks() {
        return obj.get('links')
    }

    function popLink() {
        var links = getLinks().reverse();
        links.pop();
        links.set('links', links);
    }

    function upVote(id) {
        var link = getLinks()[id];
        link.votes =+ 1;
    }

    function downVote(id) {
        var link = getLinks()[id];
        link.votes =- 1;
    }

    function save(success, error){
        return obj.save(null, {success: success, error: error});
    }

    return {
        getId: getId,
        addLink: addLink,
        getLinks: getLinks,
        popLink: popLink,
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
    room.set('links', []);

    return new Room(room);
};

module.exports = Room;