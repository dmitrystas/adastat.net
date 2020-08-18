const NODE_SOCKET = '/opt/cardano/mainnet/node/db/node.socket'; // real node socket
const PROXY_SOCKET = '/opt/cardano/mainnet/proxy/proxy.socket'; // socket for db-sync --socket-path

let net = require('net'),
	fs = require('fs'),
	log_file = fs.createWriteStream(__dirname + '/debug.log', {flags : 'w'}),
	connections = {},
	server,
	client,
	;

function createServer(socket){
	let server = net.createServer(function(stream) {
		let client = net.createConnection(NODE_SOCKET)
			.on('data', function(data) {
				stream.write(data);
			})
			.on('error', function(data) {
				console.error('Node is not active.');
				process.exit(1);
			})
			.on('close', function(data) {
				console.error('Node is close.');
			})
			;

		let self = Date.now();
		connections[self] = (stream);
		stream.on('end', function() {
			delete connections[self];
		});

		stream.on('data', function(msg) {
			client.write(msg);
			
			log_file.write('db-sync: ' + msg.toString('hex') + '\n');
		});
	})
	.listen(socket)
	;
	return server;
}

fs.stat(PROXY_SOCKET, function (err, stats) {
	if (err) {
		server = createServer(PROXY_SOCKET);
		return;
	}
	fs.unlink(PROXY_SOCKET, function(err){
		if(err){
			console.error(err);
			process.exit(0);
		}
		server = createServer(PROXY_SOCKET);
		return;
	});
});
