package thx.http;

import thx.core.Functions;
import thx.core.Error;

class Request {
	public static function make(requestInfo : RequestInfo, callback : Response -> Void, error : Error -> Void) : Void -> Void {
#if hxnodejs
		return thx.http.core.NodeJSRequest.make(requestInfo, callback, error);
#elseif js
		return thx.http.core.Html5Request.make(requestInfo, callback, error);
#else
		return thx.http.core.HaxeRequest.make(requestInfo, callback, error);
#end
	}
}
