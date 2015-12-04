var express = require('express');
var router = express.Router();
var Room = require('../data/room');

var save = function(res){
    return function(room){
        res.send(room)
    }
};

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
            res.render('room', {action: '/rooms'+req.path+'/links', room: room})
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
    Room.findOne(req.params.id)
        .then(function(room){
            room.addLink(req.param('link'));
            room.save(
                function(){
                    res.redirect('/rooms/' + req.params.id);
                }, function(){
                    res.redirect('/rooms/' + req.params.id);
                });
        });
});

router.get('/:roomId/links/:linkId/delete', function(req, res) {
    Room.findOne(req.params.roomId)
        .then(function(room){
            room.addLink(req.param('link'));
            room.save(
                function(){
                    res.redirect('/rooms/' + req.params.id);
                }, function(){
                    res.redirect('/rooms/' + req.params.id);
                });
        });
});

router.get('/:id/player', function(req, res) {
    res.render('queue', {room: req.params.id});
});

router.get('/', function(req, res, next) {
    Room.findAll()
        .then(function(rooms) {
            res.render('rooms', {rooms: rooms});
        });
});

module.exports = router;