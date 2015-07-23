package thx.http;

import thx.Functions;
import thx.Error;
import thx.promise.Promise;

class Request {
  public static function make(requestInfo : RequestInfo) : Promise<Response> {
#if hxnodejs
    return thx.http.core.NodeJSRequest.make(requestInfo);
#elseif js
    return thx.http.core.Html5Request.make(requestInfo);
#else
    return thx.http.core.HaxeRequest.make(requestInfo);
#end
  }

  public static function get(url : String) : Promise<Response> {
    return make(new RequestInfo(Get, url));
  }
}
