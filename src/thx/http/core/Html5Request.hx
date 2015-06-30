package thx.http.core;

import js.html.XMLHttpRequest;
using thx.Arrays;
using thx.Functions;
using thx.Error;
import thx.error.*;
import thx.http.Header;
using thx.promise.Promise;
using thx.stream.Emitter;
import thx.stream.*;
import haxe.io.Bytes;

class Html5Request {
  public static function make(requestInfo : RequestInfo) : Promise<Response> {
    return Promise.create(function(resolve : Response -> Void, reject) {
      var bus = new Bus(),
          req = new XMLHttpRequest();

      function send() {
        (requestInfo.headers : Array<Header>).map.fn(req.setRequestHeader(_.key, _.value));

        switch requestInfo.body {
          case NoBody:
            req.send();
          case BodyInput(i):
            try {
              var b;
              while((b = i.read(8192)).length > 0) {
                req.send(b.getData());
              }
            } catch(e : haxe.io.Eof) {
              req.send(); // TODO is this needed?
            }
            req.send(); // TODO needs conversion
          case BodyString(s, e):
            req.send(s);
          case BodyStream(e):
            e.toPromise()
              .success(function(bytes) req.send(bytes.getData()))
              .failure(function(e) throw e);
          case BodyBytes(b):
            req.send(b.getData()); // TODO needs conversion
        }
      }
      req.onload = function(e) {
        if(req.response == null || req.response.length == 0) {
          bus.end();
        } else {
          bus.pulse(Bytes.ofData(req.response));
          bus.end();
        }
        resolve(new Html5Response(req, bus));
      };

      req.onreadystatechange = function(e) {
        if(req.readyState == 1) {// 1: connection opened
          send();
          return;
        }
        if(req.readyState != 2) {// 2: request received
          return;
        }
        resolve(new Html5Response(req, bus));
      };

      req.onabort = function(e) {
        reject(new ErrorWrapper("connection aborted", e, null));
      };
      req.onerror = function(e) {
        reject(thx.Error.fromDynamic(e));
      };
      req.open(
        requestInfo.method,
        requestInfo.url,
        true
      );
      req.responseType = ARRAYBUFFER;
    });
  }
}

class Html5Response extends thx.http.Response {
  var req : XMLHttpRequest;
  public function new(req : XMLHttpRequest, bus : Bus<Bytes>) {
    this.req = req;
    headers = req.getAllResponseHeaders();
    this.emitter = bus;
  }

  override function get_statusCode() return req.status;
  override function get_statusText() return req.statusText;
}
