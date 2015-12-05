var express = require('express');
var router = express.Router();
var Room = require('../data/room');
var youTubeData = require('../data/youtube-data-factory')();

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

function addLink(roomId, id, title, image, res){
    Room.findOne(roomId)
        .then(function(room){
            room.addLink(id, title, image);
            room.save(
                function(){
                    res.redirect('/rooms/' + roomId);
                }, function(){
                    res.redirect('/rooms/' + roomId);
                });
        });
}

router.get('/add', function(req, res) {
    var room = Room.create();
    room.save(
        function(room){
            res.render('room', {room: new Room(room)})
        },function(room, error){
            res.send(error);
        }
    );
});

router.get('/:id/', function(req, res) {
    Room.findOne(req.params.id)
        .then(function(room){
            res.render('room', {path: '/rooms'+req.path, room: room})
        });
});

router.get('/:id/links', function(req, res){
    Room.findOne(req.params.id)
        .then(function(room){
            var links = JSON.stringify({links: room.getLinks()});
            res.send(links);
        });
});

router.post('/:id/links', function(req, res) {
    var roomId = req.params.id;
    var siteId = filterUrlForYoutubeId(req.param('link'));

    youTubeData.getData(siteId)
        .then(function(data){
            addLink(roomId, siteId, data.title, data.imageSrc, res)
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
            res.render('rooms', {rooms: rooms});
        });
});

module.exports = router;