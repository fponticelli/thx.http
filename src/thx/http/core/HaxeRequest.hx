package thx.http.core;

using thx.Arrays;
import thx.Functions;

class HaxeRequest {
	public static function make(requestInfo : RequestInfo, callback : Response -> Void, error : thx.Error -> Void) : Void -> Void {
		var req = new haxe.Http(requestInfo.url);
		(requestInfo.headers : Array<Header>)
			.pluck(req.addHeader(_.key, _.value));

		switch requestInfo.body {
			case BodyString(s, _): // TODO encoding
				req.setPostData(s);
			case BodyBytes(b):
				req.setPostData(b.toString());
			case BodyStream(s):
				req.setPostData(s.readAll().toString());
			case NoBody: // do nothing
		}

		var status = 0;
		req.onData = function(data : String) {
			var res = new HaxeResponse(status, data, #if js new haxe.ds.StringMap() #else req.responseHeaders #end);
			callback(res);
		};
		req.onStatus = function(s) {
			status = s;
		};
		req.onError = function(msg) {
			error(new thx.Error(msg));
		};

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

class HaxeResponse implements thx.http.Response {
	@:isVar public var body(get, null) : ResponseBody;
	@:isVar public var statusCode(get, null) : Int;
	public var statusText(get, null) : String;
	@:isVar public var headers(get, null) : Headers;
	var responseHeaders : haxe.ds.StringMap<String>;

	public function new(statusCode : Int, body : String, responseHeaders : haxe.ds.StringMap<String>) {
		this.statusCode = statusCode;
		this.body = null == body || "" == body ? NoBody : BodyString(body);
		this.responseHeaders = responseHeaders;
	}

	function get_body() return body;
	function get_statusCode() return statusCode;
	function get_statusText() return null;
	function get_headers() {
		if(null == headers) {
			headers = responseHeaders;
		}
		return headers;
	}
}
