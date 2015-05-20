package thx.http.core;

import js.node.Http;
import js.node.Https;
import js.node.http.IncomingMessage;
import js.node.Buffer;
import thx.Error;
import thx.nodejs.io.StreamInput;

class NodeJSRequest {
	public static function make(requestInfo : RequestInfo, callback : Response -> Void, error : Error -> Void) : Void -> Void {
		trace("MAKE");
		function callbackResponse(res : IncomingMessage) {
			callback(new NodeJSResponse(res));
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
		req.on("error", function(e) {
			trace("ERROR", e);
			error(Error.fromDynamic(e));
		});
		req.end();
		return req.abort;
	}
}

class NodeJSResponse implements thx.http.Response {
	@:isVar public var body(get, null) : ResponseBody;
	public var statusCode(get, null) : Int;
	@:isVar public var statusText(get, null) : String;
	@:isVar public var headers(get, null) : Headers;
	var getRawHeaders : Void -> String;
	var res : IncomingMessage;
	public function new(res : IncomingMessage) {
		this.res = res;
		var length;
		trace(headers.exists("Content-Length"), Std.parseInt(headers.get("Content-Length")));
		var input = new StreamInput(res);
		this.body = NoBody;
		/*
		if(null == firstChunk) {
			this.body = NoBody;
		} else if(headers.exists("Content-Length") && Std.parseInt(headers.get("Content-Length")) == firstChunk.length) {
			trace("SET TO BODY STRING");
			this.body = BodyString(firstChunk.toString());
		} else {
			res.on("data", function(chunk : Buffer) {

			});

		}
		*/
		// TODO BodyBytes
		// TODO BodyString encoding
	}

	function get_body() return ResponseBody.NoBody;
	function get_statusCode() return res.statusCode;
	function get_statusText() return null;
	function get_headers() {
		if(null == headers) {
			headers = res.headers;
		}
		return headers;
	}
}
