package thx.http.core;

import thx.http.Header;
import js.html.XMLHttpRequest;
using thx.core.Arrays;
using thx.core.Error;

class Html5Request {
	public static function make(requestInfo : RequestInfo, callback : Response -> Void, error : Error -> Void) : Void -> Void {
		var req = new XMLHttpRequest();
		req.onload = function() {
			var res = new Html5Response(req.status, req.statusText, req.responseText, req.getAllResponseHeaders);
			callback(res);
		};
		req.onerror = function(e) {
			error(thx.core.Error.fromDynamic(e));
		};
		req.open(
			requestInfo.method,
			requestInfo.url,
			true
		);
		(requestInfo.headers : Array<Header>).pluck(req.setRequestHeader(_.key, _.value));
		switch requestInfo.body {
			case NoBody:
				req.send();
			case BodyString(s, e):
				req.send(s);
			case BodyBytes(b):
				req.send(b); // TODO needs conversion
			case BodyStream(s):
				try {
					var b;
					while((b = s.read(8192)).length > 0) {
						req.send(b.getData());
					}
				} catch(e : haxe.io.Eof) {
					req.send(); // TODO is this needed?
				}
				req.send(s); // TODO needs conversion
			}
		return function() {};
	}
}



class Html5Response implements thx.http.Response {
	@:isVar public var body(get, null) : ResponseBody;
	@:isVar public var statusCode(get, null) : Int;
	@:isVar public var statusText(get, null) : String;
	@:isVar public var headers(get, null) : Headers;
	var getRawHeaders : Void -> String;
	public function new(statusCode : Int, statusText : String, body : String, getRawHeaders : Void -> String) {
		this.statusCode = statusCode;
		this.statusText = statusText;
		this.body = null == body || "" == body ? NoBody : BodyString(body);
		this.getRawHeaders = getRawHeaders;
	}

	function get_body() return body;
	function get_statusCode() return statusCode;
	function get_statusText() return null;
	function get_headers() {
		if(null == headers) {
			headers = getRawHeaders();
		}
		return headers;
	}
}
