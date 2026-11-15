// Controllable socket.io v4 server for PresenceSocketService integration
// tests. Driven by JSON commands on stdin, one per line; reports JSON events
// on stdout, one per line.
//
// Commands:
//   {"cmd":"mode","value":"accept"|"reject_auth"|"reject_other"}
//   {"cmd":"kick"}      server-side disconnect of every socket ("io server disconnect")
//   {"cmd":"restart"}   drop every connection at the transport level, then listen again
//
// Events:
//   {"event":"listening","port":N}
//   {"event":"handshake","token":"...","accepted":true|false}
//   {"event":"connection","id":"..."}
//   {"event":"update_availability","payload":{...}}
//   {"event":"get_presence_snapshot"}
//   {"event":"disconnect","reason":"..."}
//   {"event":"ack","cmd":"..."}

const http = require('http');
const readline = require('readline');
const { Server } = require('socket.io');

let mode = 'accept';
let port = 0;
let httpServer;
let io;

function report(obj) {
  process.stdout.write(JSON.stringify(obj) + '\n');
}

function start(listenPort) {
  httpServer = http.createServer();
  const sockets = new Set();
  httpServer.on('connection', (s) => {
    sockets.add(s);
    s.on('close', () => sockets.delete(s));
  });
  httpServer.destroyAllSockets = () => sockets.forEach((s) => s.destroy());

  io = new Server(httpServer, { transports: ['websocket'] });

  io.use((socket, next) => {
    const token = (socket.handshake.auth && socket.handshake.auth.token) || null;
    const accepted = mode === 'accept';
    report({ event: 'handshake', token, accepted });
    if (mode === 'reject_auth') return next(new Error('jwt expired'));
    if (mode === 'reject_other') return next(new Error('host suspended'));
    return next();
  });

  io.on('connection', (socket) => {
    report({ event: 'connection', id: socket.id });
    socket.on('update_availability', (payload) =>
      report({ event: 'update_availability', payload }),
    );
    socket.on('get_presence_snapshot', () => {
      report({ event: 'get_presence_snapshot' });
      socket.emit('host_status_update', []);
    });
    socket.on('disconnect', (reason) => report({ event: 'disconnect', reason }));
  });

  httpServer.listen(listenPort, '127.0.0.1', () => {
    port = httpServer.address().port;
    report({ event: 'listening', port });
  });
}

const rl = readline.createInterface({ input: process.stdin });
rl.on('line', (line) => {
  let msg;
  try {
    msg = JSON.parse(line);
  } catch (_) {
    return;
  }
  switch (msg.cmd) {
    case 'mode':
      mode = msg.value;
      break;
    case 'kick':
      io.sockets.sockets.forEach((s) => s.disconnect(true));
      break;
    case 'restart': {
      const samePort = port;
      httpServer.destroyAllSockets();
      io.close(() => start(samePort));
      break;
    }
    default:
      break;
  }
  report({ event: 'ack', cmd: msg.cmd });
});
rl.on('close', () => process.exit(0));

start(0);
