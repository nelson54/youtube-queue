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
            res.render('room', {room: room})
        });
});

router.post('/:id/', function(req, res) {
    Room.findOne(req.params.id)
        .then(function(room){
            room.addLink(req.param('link'));
            console.log(room.getLinks());
            room.save(save(res), save(res));
        });
});

router.get('/', function(req, res, next) {
    Room.findAll()
        .then(function(rooms) {
            res.render('rooms', {rooms: rooms});
        });
});

module.exports = router;