package thx.http.core;

import js.node.Http;
import js.node.Https;
import thx.core.Error;

class NodeJSRequest {
	public static function make(requestInfo : RequestInfo, callback : Response -> Void, error : Error -> Void) : Void -> Void {
		function callbackResponse(res : js.node.http.IncomingMessage) {
			var first = true;
			// TODO stream response
			res.on("data", function(chunk) {
				if(first) {
					first = false;
					callback(new NodeJSResponse(res.statusCode));
				}
			});

			res.on("end", function(_) {
				if(first) {
					first = false;
					callback(new NodeJSResponse(res.statusCode));
				}
			});
		}

		var url = requestInfo.url,
				req : js.node.http.ClientRequest = switch url.protocol {
					case "http":
						Http.request({
							hostname: url.hostName,
							port: url.port,
							method: (requestInfo.method : String),
							path: url.path,
							headers: requestInfo.headers.toObject()
							//auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
						}, callbackResponse);
					case "https":
						Https.request({
							hostname: url.hostName,
							port: url.port,
							method: (requestInfo.method : String),
							path: url.path,
							headers: requestInfo.headers.toObject()
							//auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
						}, callbackResponse);
					case other:
						throw 'unexpected protocol $other';
				};
		req.on("error", function(e) error(Error.fromDynamic(e)));
		req.end();
		return req.abort;
	}
}

class NodeJSResponse implements thx.http.Response {
	@:isVar public var body(get, null) : ResponseBody;
	@:isVar public var statusCode(get, null) : Int;
	@:isVar public var statusText(get, null) : String;
	@:isVar public var headers(get, null) : Headers;
	var getRawHeaders : Void -> String;
	public function new(statusCode : Int/*, body : String, getRawHeaders : Void -> String*/) {
		this.statusCode = statusCode;
		//this.body = null == body || "" == body ? NoBody : BodyString(body);
		//this.getRawHeaders = getRawHeaders;
	}

	function get_body() return ResponseBody.NoBody;
	function get_statusCode() return statusCode;
	function get_statusText() return null;
	function get_headers() {
		if(null == headers) {
			//headers = getRawHeaders();
		}
		return Headers.empty();
	}
}
