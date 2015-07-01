package thx.http.core;

import js.node.Http;
import js.node.Https;
import js.node.http.IncomingMessage;
import js.node.Buffer;
import haxe.io.Bytes;
import thx.Error;
using thx.nodejs.io.Buffers;
using thx.promise.Promise;
using thx.stream.Bus;
using thx.stream.Emitter;

class NodeJSRequest {
  public static function make(requestInfo : RequestInfo) : Promise<Response> {
    return Promise.create(function(resolve : Response -> Void, reject) {
      function callbackResponse(res : IncomingMessage) resolve(new NodeJSResponse(res));

      var url = requestInfo.url,
          req : js.node.http.ClientRequest = switch url.protocol {
            case "http":
              Http.request({
                hostname: url.hostName,
                port: url.port,
                method: (requestInfo.method : String),
                path: url.path,
                headers: requestInfo.headers.toObject()
                //auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
              }, callbackResponse);
            case "https":
              Https.request({
                hostname: url.hostName,
                port: url.port,
                method: (requestInfo.method : String),
                path: url.path,
                headers: requestInfo.headers.toObject()
                //auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
              }, callbackResponse);
            case other:
              throw 'unexpected protocol $other';
          };
      req.on("error", function(e) {
        trace("ERROR", e);
        reject(Error.fromDynamic(e));
      });
      switch requestInfo.body {
        case NoBody:
          req.end();
        case BodyString(s, null):
          req.end(s);
        case BodyString(s, e):
          req.end(s, e);
        case BodyStream(e):
          e.subscribe(
            function(bytes) req.write(bytes.toBuffer()),
            function(cancelled) if(cancelled) {
              throw "Http Stream cancelled";
            } else {
              req.end();
            }
          );
        case BodyInput(i):
          var size = 8192,
              buf = Bytes.alloc(size),
              len;

          while(true) {
            len = i.readBytes(buf, 0, size);
            if(len < size) {
              req.write(buf.sub(0, len).toBuffer());
              break;
            } else {
              req.write(buf.toBuffer());
            }
          }
          req.end();
        case BodyBytes(b):
          req.end(b.toBuffer());
      }
    });
  }
}
class NodeJSResponse extends thx.http.Response {
  var res : IncomingMessage;
  public function new(res : IncomingMessage) {
    this.res = res;
    headers = res.headers;
    var bus = new Bus();
    res.on("readable", function() {
      var buf : Buffer = res.read();
      if(buf != null)
        bus.pulse(buf.toBytes());
    });
    res.on("end", function() {
      bus.end();
    });
    this.emitter = bus;
  }

  override function get_statusCode() return res.statusCode;
}
