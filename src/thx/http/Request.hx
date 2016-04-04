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

  public static function get<T>(url : String, responseType : ResponseType<T>) : Request<T>
    return make(new RequestInfo(Get, url), responseType);

  // instance fields
  public var response(default, null) : Promise<Response<T>>;

  public function abort() : Request<T> {
    return this;
  }
}
