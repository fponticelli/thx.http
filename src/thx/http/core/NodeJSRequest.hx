package thx.http.core;

import js.node.Http;
import js.node.Https;
import js.node.http.IncomingMessage;
import js.node.Buffer;
import haxe.io.Bytes;
import thx.Error;
using thx.promise.Promise;
using thx.stream.Bus;
using thx.stream.Emitter;
import thx.Objects;
using thx.Arrays;
import thx.http.RequestBody;

class NodeJSRequest<T> extends thx.http.Request<T> {
  public static function make<T>(requestInfo : RequestInfo, responseType : ResponseType<T>) : Request<T> {
    var url = requestInfo.url,
        path = url.path.substring(0, 1) != "/" ? '/${url.path}' : url.path,
        req : js.node.http.ClientRequest = switch url.protocol {
            case "http":
              Http.request({
                hostname: url.hostName,
                port: url.port,
                method: (requestInfo.method : String),
                path: path,
                headers: requestInfo.headers.toObject()
                //auth: TODO Basic authentication i.e. 'user:password' to compute an Authorization header.
              });
            case "https":
              Https.request({
                hostname: url.hostName,
                port: url.port,
                method: (requestInfo.method : String),
                path: path,
                headers: requestInfo.headers.toObject()
                //auth: TODO Basic authentication i.e. 'user:password' to compute an Authorization header.
              });
            case other:
              throw 'unexpected protocol $other';
          };
    return new NodeJSRequest(Promise.create(function(resolve : Response<T> -> Void, reject) {
      req.once("response", function(res) {
        resolve(new NodeJSResponse(res, responseType));
      });
      req.on("error", function(e) {
        reject(Error.fromDynamic(e)); // TODO better error report
      });

      switch (requestInfo.body : RequestBodyImpl) {
        case NoBody:
          req.end();
        case BodyString(s, null):
          req.end(s);
        case BodyString(s, e):
          req.end(s, e);
        case BodyStream(e):
          e.subscribe(
            function(bytes) req.write(NodeJS.arrayBufferToBuffer(bytes.getData())),
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
              req.write(NodeJS.arrayBufferToBuffer(buf.sub(0, len).getData()));
              break;
            } else {
              req.write(NodeJS.arrayBufferToBuffer(buf.getData()));
            }
          }
          req.end();
        case BodyBytes(b):
          req.end(NodeJS.arrayBufferToBuffer(b.getData()));
#if(nodejs || hxnodejs)
        case BodyJSBuffer(buffer):
          req.end(buffer);
#end
      }
    }), req);
  }

  public var request(default, null) : js.node.http.ClientRequest;
  function new(response : Promise<Response<T>>, request : js.node.http.ClientRequest) {
    this.response = response;
    this.request = request;
  }

  override function abort() {
    request.abort();
    return this;
  }

  override function onProgress(f : Progress -> Void) {
    // TODO
    return this;
  }
}

class NodeJSResponse<T> extends thx.http.Response<T> {
  public var response(default, null) : IncomingMessage;
  public function new(response : IncomingMessage, responseType : ResponseType<T>) {
    this.response = response;
    this.responseType = responseType;
    _body = switch responseType {
      case ResponseTypeBytes:
        promiseOfBuffer(response)
          .mapSuccess(NodeJS.bufferToBytes);
      case ResponseTypeText:
        promiseOfText(response);
      case ResponseTypeJSBuffer:
        promiseOfBuffer(response);
      case ResponseTypeNoBody:
        promiseOfNil(response);
    };
  }

  override function get_statusCode() : Int
    return response.statusCode;
  // override function get_statusText() : String
  //   return response.statusMessage; // TODO statusMessage should exist
  var _headers : Headers;
  override function get_headers() : Headers {
    if(null != _headers)
      return _headers;
    return _headers = Objects.tuples(cast response.headers).map(function(t) : Header {
      return if(Std.is(t._1, String)) {
        new Header(cast t);
      } else if(Std.is(t._1, Array)) {
        Header.raw(t._0, (t._1 : Array<String>).join(" "));
      } else {
        throw 'unable to convert header value ${t._1}';
      };
    });
  }
  var _body : Promise<T>;
  override function get_body() : Promise<T>
    return _body;

  static function promiseOfBuffer(response : IncomingMessage) : Promise<Buffer> {
    // response.setEncoding(null); // tried this and it seems to encode the output as a string. The documentation says otherwise.
    return Promise.create(function(resolve, reject) {
      var buffer = new Buffer(0);
      response.on("readable", function() {
        var chunk = null;
        while(null != (chunk = response.read()))
          buffer = Buffer.concat([buffer, chunk]);
      });
      response.on("end", function() resolve(buffer));
      response.on("error", function(e) reject(thx.Error.fromDynamic(e)));
    });
  }

  static function promiseOfText(response : IncomingMessage) : Promise<String> {
    response.setEncoding("utf8");
    return Promise.create(function(resolve, reject) {
      var buffer = "";
      response.on("readable", function() {
        var chunk = null;
        while(null != (chunk = response.read()))
          buffer += chunk;
      });
      response.on("end", function() resolve(buffer));
      response.on("error", function(e) reject(thx.Error.fromDynamic(e)));
    });
  }

  static function promiseOfNil(response : IncomingMessage) : Promise<Nil>
    return Promise.create(function(resolve, reject) {
      response.on("readable", function() {
        while(null != response.read()) {}
      });
      response.on("end", function() resolve(thx.Nil.nil));
      response.on("error", function(e) reject(thx.Error.fromDynamic(e)));
    });
}
