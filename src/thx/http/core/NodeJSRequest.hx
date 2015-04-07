package thx.http.core;

import js.node.Http;
import js.node.Https;
import thx.core.Error;

class NodeJSRequest {
	public static function make(requestInfo : RequestInfo, callback : Response -> Void, error : Error -> Void) : Void -> Void {
		function callbackResponse(res : js.node.http.IncomingMessage) {
			//var buf = "";
			var first = true;
			res.on("data", function(chunk) {
				if(first) {
					first = false;
					callback(new NodeJSResponse(res.statusCode));
				}
				trace(res.statusCode);
				trace(Std.is(chunk, String));
				trace(chunk);
				//buf += chunk;
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
							//localAddress: Local interface to bind for network connections.
							//socketPath: Unix Domain Socket (use one of host:port or socketPath)
							method: (requestInfo.method : String),
							path: url.path,
							headers: requestInfo.headers.toObject()
							//auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
							//agent: Controls Agent behavior. When an Agent is used request will default to Connection: keep-alive. Possible values:
							//keepAlive: {Boolean} Keep sockets around in a pool to be used by other requests in the future. Default = false
							//keepAliveMsecs: {Integer} When using HTTP KeepAlive, how often to send TCP KeepAlive packets over sockets being kept alive. Default = 1000. Only relevant if keepAlive is set to true.
						}, callbackResponse);
					case "https":
						Https.request({
							hostname: url.hostName,
							port: url.port,
							//localAddress: Local interface to bind for network connections.
							//socketPath: Unix Domain Socket (use one of host:port or socketPath)
							method: (requestInfo.method : String),
							path: url.path,
							headers: requestInfo.headers.toObject()
							//auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
							//agent: Controls Agent behavior. When an Agent is used request will default to Connection: keep-alive. Possible values:
							//keepAlive: {Boolean} Keep sockets around in a pool to be used by other requests in the future. Default = false
							//keepAliveMsecs: {Integer} When using HTTP KeepAlive, how often to send TCP KeepAlive packets over sockets being kept alive. Default = 1000. Only relevant if keepAlive is set to true.
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
