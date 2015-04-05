package thx.http;

import thx.core.Functions;

class Request {
	public static function make(requestInfo : RequestInfo, requestHandler : RequestHandler) : Void -> Void {
#if hxnodejs
		return thx.http.core.NodeJSRequest.make(requestInfo, requestHandler);
#else
		return thx.http.core.HaxeRequest.make(requestInfo, requestHandler);
#end
	}
}
