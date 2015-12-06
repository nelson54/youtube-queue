var parse = require('./parse-factory')();
var uuid = require('node-uuid');
var ParseRoom = parse.Object.extend("Room");

function Room(obj) {

    function getId() {
        return obj.id;
    }

    function getName() {
        return obj.get('name') || obj.id;
    }

    function setName(name) {
        obj.set('name', name);
    }

    function setLinks(links) {
        obj.set('links', links);
    }

    function addLink(id, title, image) {
        var newLink = {id: uuid.v4(), title:title, image:image, votes: 1, site: 'youtube', siteId: id};
        var links = getLinks();
        links[newLink.id] = newLink;
        setLinks(links);
        return newLink.id;
    }

    function removeLink(id) {
        var links = getLinks();
        delete links[id];
        setLinks(links);
    }

    function setLinkVideoUrl(id, url) {
        var links = getLinks();
        links[id].videoUrl = url;
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
        setLinkVideoUrl: setLinkVideoUrl,
        getId: getId,
        getName: getName,
        setName: setName,
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

Room.sortLinksByVoteDesc = function (links) {
    return Object.keys(links)
        .map(function(i){return links[i]})
        .sort(function (a, b) {
            return b.votes - a.votes
        });
}
module.exports = Room;