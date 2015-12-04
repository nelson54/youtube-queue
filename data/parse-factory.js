var Parse = require('parse/node');

module.exports = function(){
    Parse.initialize(process.env.applicationId, process.env.javaScriptKey);
    return Parse;
};