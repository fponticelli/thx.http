package thx.http.core;

import haxe.io.Bytes;
import js.html.XMLHttpRequest;
import thx.Nil;
import thx.error.*;
import thx.http.Header;
import thx.http.RequestBody;
import thx.stream.*;
using thx.Arrays;
using thx.Functions;
using thx.Error;
using thx.promise.Promise;
using thx.stream.Emitter;

class Html5Request<T> extends Request<T> {
  public static function make<T>(requestInfo : RequestInfo, responseType : ResponseType<T>) : Request<T> {
    var request = new XMLHttpRequest();
    request.responseType = switch responseType {
      case ResponseTypeBytes: ARRAYBUFFER;
      case ResponseTypeNoBody: NONE;
      case ResponseTypeText: TEXT;
      case ResponseTypeJson: JSON;
      case ResponseTypeArrayBuffer: ARRAYBUFFER;
      case ResponseTypeBlob: BLOB;
      case ResponseTypeDocument: DOCUMENT;
    };
    return new Html5Request(Promise.create(function(resolve : Response<T> -> Void, reject) {
      var promiseResponseBody = Promise.create(function(resolveBody, rejectBody) {
        request.addEventListener("load", function(e) {
          var body : Dynamic = switch responseType {
            case ResponseTypeBytes: Bytes.ofData(request.response);
            case ResponseTypeNoBody: Nil.nil;
            case ResponseTypeText: request.response;
            case ResponseTypeJson: request.response;
            case ResponseTypeArrayBuffer: request.response;
            case ResponseTypeBlob: request.response;
            case ResponseTypeDocument: request.response;
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
        reject(Error.fromDynamic(e)); // TODO
      });
      request.addEventListener("abort", function(e) {
        reject(new Error('used aborted request of ${requestInfo.url}')); // TODO
      });
      request.open(requestInfo.method, requestInfo.url.toString());

      (requestInfo.headers : Array<Header>).map.fn(request.setRequestHeader(_.key, _.value));
      var body : RequestBodyImpl = requestInfo.body;
      switch body {
        case NoBody:
          request.send();
        case BodyInput(i):
          request.send(i.readAll().getData());
        case BodyString(s, e):
          request.send(s);
        case BodyStream(e):
          e.toPromise()
            .success(function(bytes) request.send(bytes.getData()))
            .failure(function(e) throw e);
        case BodyBytes(b):
          request.send(b.getData()); // TODO needs conversion
        case BodyJSFormData(formData):
          request.send(formData);
        case BodyJSDocument(doc):
          request.send(doc);
        case BodyJSBlob(blob):
          request.send(blob);
        case BodyJSArrayBufferView(arrayBufferView):
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
