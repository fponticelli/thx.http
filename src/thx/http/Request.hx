package thx.http;

import thx.Functions;
import thx.Error;
import thx.promise.Promise;

class Request<T> {
  public static function make<T>(requestInfo : RequestInfo, responseType : ResponseType<T>) : Request<T> {
#if hxnodejs
    return thx.http.core.NodeJSRequest.make(requestInfo, responseType);
#elseif js
    return thx.http.core.Html5Request.make(requestInfo, responseType);
#else
    return thx.http.core.HaxeRequest.make(requestInfo, responseType);
#end
  }

  public static function ping(url : String) : Request<thx.Nil>
    return get(url, ResponseTypeNoBody);

  public static function getBytes(url : String) : Request<haxe.io.Bytes>
    return get(url, ResponseTypeBytes);

  public static function getJson(url : String) : Request<Dynamic>
    return get(url, ResponseTypeJson);

  public static function getText(url : String) : Request<String>
    return get(url, ResponseTypeText);

  public static function get<T>(url : String, responseType : ResponseType<T>) : Request<T>
    return make(new RequestInfo(Get, url), responseType);

  // instance fields
  public var response(default, null) : Promise<Response<T>>;
  public var body(get, null) : Promise<T>;

  public function abort() : Request<T>
    return this;

  var _body : Promise<T>;
  function get_body() {
    if(null != _body)
      return _body;
    return _body = response.flatMap(function(response) {
      return switch response.statusCode {
        case 200, 201, 202, 203, 204, 205, 206:
          response.body;
        case serverError if(serverError >= 500):
          Promise.error(new HttpServerError(serverError, response.statusText));
        case clientError if(clientError >= 400):
          Promise.error(new HttpClientError(clientError, response.statusText));
        case other:
          Promise.error(new HttpStatusError(other, response.statusText));
      }
      return response.body;
    });
  }
}
