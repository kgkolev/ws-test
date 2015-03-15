var noflo = require('noflo');

exports.getComponent = function () {
  var c = new noflo.Component();

  c.inPorts.add('in', function (event, payload) {
    if (event !== 'data') {
      return;
    }
    console.log("forwarding data");
    // Do something with the packet, then
    c.outPorts.out.send(payload);
    c.outPorts.out.disconnect();
  });
  c.outPorts.add('out');
  return c;
};