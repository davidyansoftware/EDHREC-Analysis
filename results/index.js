const express = require('express');
const app = express();

//app.use(express.static('./'));

//app.listen(3000, '0.0.0.0');

var server = require('http').createServer(app);

server.listen(3000, '0.0.0.0');
