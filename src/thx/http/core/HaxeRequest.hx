package thx.http.core;

using thx.core.Arrays;
import thx.core.Functions;

class HaxeRequest {
	public static function make(requestInfo : RequestInfo, requestHandler : RequestHandler) : Void -> Void {
		var req = new haxe.Http(requestInfo.url);
		(requestInfo.headers : Array<Header>)
			.pluck(req.addHeader(_.key, _.value));

		var buf = "";
		req.onData = function(data) buf += data;
		req.onStatus = function(status) requestHandler.statusHandler(status, buf);

		//req.onError = requestHandler.errorHandler;
		switch requestInfo.method {
			case Get: req.request(false);
			case Post: req.request(true);
			case other: throw 'haxe.Http doesn\'t support method "$other"';
		}
		#if (flash || js)
		return req.cancel;
		#else
		// no cancel, sorry
		return Functions.noop;
		#end
	}
}
