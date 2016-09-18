package thx.http.core;

import haxe.io.Bytes;
import js.html.XMLHttpRequest;
import thx.Nil;
import thx.http.*;
#if thx_stream
import thx.stream.*;
using thx.stream.Emitter;
#end
using thx.Arrays;
using thx.Functions;
using thx.promise.Promise;

class Html5Request<T> extends Request<T> {
  public static function make<T>(requestInfo : RequestInfo, responseType : ResponseType<T>) : Request<T> {
    var request = new XMLHttpRequest();
    request.responseType = switch responseType {
      case Binary: ARRAYBUFFER;
      case NoBody: NONE;
      case Text: TEXT;
      case Json: JSON;
      case JSArrayBuffer: ARRAYBUFFER;
      case JSBlob: BLOB;
      case JSDocument: DOCUMENT;
    };
    return new Html5Request(Promise.create(function(resolve : Response<T> -> Void, reject) {
      var promiseResponseBody = Promise.create(function(resolveBody, rejectBody) {
        request.addEventListener("load", function(e) {
          var body : Dynamic = switch responseType {
            case Binary: Bytes.ofData(request.response);
            case NoBody: Nil.nil;
            case Text: request.response;
            case Json: request.response;
            case JSArrayBuffer: request.response;
            case JSBlob: request.response;
            case JSDocument: request.response;
          };
          resolveBody(body);
        });
      });
      request.addEventListener("readystatechange", function(e) {
        if(request.readyState == 2) // HEADERS_RECEIVED
          resolve(new Html5Response(promiseResponseBody, request));
        // var state = switch request.readyState {
        //   case 0: "UNSENT";
        //   case 1: "OPENED";
        //   case 2: "HEADERS_RECEIVED";
        //   case 3: "LOADING";
        //   case 4: "DONE";
        //   case other: 'MEH $other';
        // }
        // trace('readystatechange $state');
      });
      request.addEventListener("error", function(e) {
        reject(new HttpConnectionError(e.message));
      });
      request.addEventListener("abort", function(e) {
        reject(new HttpAbortError(requestInfo.url));
      });
      request.open(requestInfo.method, requestInfo.url.toString());

      (requestInfo.headers : Array<Header>).map.fn(request.setRequestHeader(_.key, _.value));
      var body : RequestType.RequestTypeImpl = requestInfo.body;
      switch body {
        case NoBody:
          request.send();
        case Input(i):
          request.send(i.readAll().getData());
        case Text(s, e):
          request.send(s);
#if thx_stream
        case Stream(e):
          e.toPromise()
            .success(function(bytes) request.send(bytes.getData()))
            .failure(function(e) throw e);
#end
        case Binary(b):
          request.send(b.getData()); // TODO needs conversion
        case JSFormData(formData):
          request.send(formData);
        case JSDocument(doc):
          request.send(doc);
        case JSBlob(blob):
          request.send(blob);
        case JSArrayBufferView(arrayBufferView):
          request.send(arrayBufferView);
      }
    }), request);
  }
  public var request(default, null) : XMLHttpRequest;
  function new(response : Promise<Response<T>>, request : XMLHttpRequest) {
    this.response = response;
    this.request = request;
  }

  override function abort() {
    request.abort();
    return this;
  }
}

class Html5Response<T> extends thx.http.Response<T> {
  public var request(default, null) : XMLHttpRequest;
  var _body : Promise<T>;
  public function new(body : Promise<T>, request : XMLHttpRequest) {
    this._body = body;
    this.request = request;
  }

  override function get_body() return _body;
  override function get_statusCode() return request.status;
  override function get_statusText() return request.statusText;
  var _headers : Headers;
  override function get_headers() {
    if(null != _headers)
      return _headers;
    return _headers = request.getAllResponseHeaders();
  }
}
