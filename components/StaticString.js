var noflo = require('noflo');

exports.getComponent = function () {
  var c = new noflo.Component();
  
  var staticString = "My Test Page";

  c.inPorts.add('in', function (event, httpReq) {
    if (event !== 'data') {
      return;
    }
    // Do something with the packet, then
    httpReq.res.write(staticString);
    c.outPorts.out.send(httpReq);
  });
  
  c.outPorts.add('out');
  
  return c;
};