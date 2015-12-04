var Parse = require('parse');

module.exports = function(){
    Parse.initialize(process.env.applicationId, process.env.javaScriptKey);
};