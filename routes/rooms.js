var express = require('express');
var router = express.Router();
var Room = require('../data/room');
var youTubeData = require('../data/youtube-data-factory')();
var youtubedl = require('youtube-dl');
var Promise = require("bluebird");

var save = function(res){
    return function(room){
        res.send(room)
    }
};

function filterUrlForYoutubeId(link){
    var videoId = link.split('v=')[1];
    var ampersandPosition = videoId.indexOf('&');
    if(ampersandPosition != -1) {
        videoId = videoId.substring(0, ampersandPosition);
    }
    return videoId;
}

function addLink(roomId, id, url, title, image, res){
    var deffered = Promise.pending();
    Room.findOne(roomId)
        .then(function(room){
            var linkId = room.addLink(id, title, image);
            return room.save(
                function(room){
                    res.redirect('/rooms/' + roomId);
                    var updatedRoom = new Room(room);
                    updatedRoom.linkId = linkId;
                    deffered.resolve(updatedRoom);
                }, function(){
                    res.redirect('/rooms/' + roomId);
                    deffered.resolve(new Room(room));
                });
        });

    return deffered.promise;
}

router.get('/add', function(req, res) {
    var room = Room.create();
    room.save(
        function(room){
            res.redirect('/rooms/' + room.id);
        },function(room, error){
            res.send(error);
        }
    );
});

router.get('/:id/', function(req, res) {
    Room.findOne(req.params.id)
        .then(function(room){
            res.render('room', {path: '/rooms'+req.path, name: room.getName(), links: Room.sortLinksByVoteDesc(room.getLinks())})
        });
});

router.get('/:id/links', function(req, res){
    Room.findOne(req.params.id)
        .then(function(room){
            res.send(Room.sortLinksByVoteDesc(room.getLinks()));
        });
});

router.post('/:id/name', function(req, res) {
    Room.findOne(req.params.id)
        .then(function(room){
            var name = req.param('name');
            room.setName(name);
            room.save(function() {
                res.redirect('/rooms/' + req.params.id);
            }, function () {
                res.status(500)
                    .send({msg: "Couldn't save name"});
            });
        });
});

router.post('/:id/links', function(req, res) {
    var roomId = req.params.id;
    var link = req.param('link');
    var siteId = filterUrlForYoutubeId(link);
    var linkId;

    youTubeData.getData(siteId)
        .then(function(data){
            return addLink(roomId, siteId, req.param('link'), data.title, data.imageSrc, res)
        })
        .then(function(room){
            var deferred = Promise.pending();
            var video = youtubedl(link);

            video.on('info', function(info) {
                info.room = room;
                info.linkId = room.linkId;
                deferred.resolve(info)
            });

            return deferred.promise;
        })
        .then(function(info){
            info.room.setLinkVideoUrl(info.linkId, info.url);
            info.room.save(console.log, console.log);
        });
});

router.put('/:id/pop', function(req, res) {
    Room.findOne(req.params.id)
        .then(function(room){
            room.popLink();
            room.save(
                function(room){
                    res.send(new Room(room));
                }, function(){
                    res.redirect('/rooms/' + req.params.id);
                });
        });
});

router.get('/:roomId/links/:linkId/remove', function(req, res) {
    Room.findOne(req.param('roomId'))
        .then(function(room){
            room.removeLink(req.param('linkId'));
            room.save(
                function(room) {
                    res.send(new Room(room).getLinks());
                }
                ,function(room){
                    res
                        .status(500)
                        .send(new Room(room));
                });
        });
});

router.get('/:roomId/links/:linkId/downvote', function(req, res) {
    Room.findOne(req.param('roomId'))
        .then(function(room){
            room.downVote(req.param('linkId'));
            function redirect() {
                res.redirect('/rooms/' + req.params.roomId);
            }
            room.save(redirect, redirect);
        });
});

router.get('/:roomId/links/:linkId/upvote', function(req, res) {
    Room.findOne(req.param('roomId'))
        .then(function(room){
            room.upVote(req.param('linkId'));
            function redirect() {
                res.redirect('/rooms/' + req.params.roomId);
            }
            room.save(redirect, redirect);
        });
});

router.get('/:id/player', function(req, res) {
    res.render('queue', {room: req.params.id});
});

router.get('/', function(req, res) {
    Room.findAll()
        .then(function(rooms) {
            var roomsByName = rooms.sort(function(a,b) { return a.getName().localeCompare(b.getName())});
            res.render('rooms', {rooms: roomsByName});
        });
});

module.exports = router;