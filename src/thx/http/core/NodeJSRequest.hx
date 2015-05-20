package thx.http.core;

import js.node.Http;
import js.node.Https;
import js.node.http.IncomingMessage;
import js.node.Buffer;
import thx.Error;
import haxe.io.Bytes;
using thx.promise.Promise;
using thx.stream.Bus;
using thx.stream.Emitter;
using thx.stream.Stream;
using thx.nodejs.io.Buffers;

class NodeJSRequest {
	public static function make(requestInfo : RequestInfo) : Promise<Response> {
		return Promise.create(function(resolve : Response -> Void, reject) {
			function callbackResponse(res : IncomingMessage) {
				resolve(new NodeJSResponse(res));
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
				reject(Error.fromDynamic(e));
			});
			req.end();
		});
	}
}

class NodeJSResponse implements thx.http.Response {
	public var statusCode(get, null) : Int;
	@:isVar public var statusText(get, null) : String;
	@:isVar public var headers(get, null) : Headers;
	public var emitter(get, null) : Emitter<Bytes>;
	var getRawHeaders : Void -> String;
	var res : IncomingMessage;
	var _emitter : Emitter<Bytes>;
	public function new(res : IncomingMessage) {
		this.res = res;
		var bus = new Bus();
		res.on("readable", function() {
			var buf : Buffer = res.read();
			if(buf == null)
				bus.end();
			else
				bus.pulse(buf.toBytes());
		});
		this._emitter = bus;
	}

	function get_statusCode() return res.statusCode;
	function get_statusText() return null;
	function get_headers() {
		if(null == headers) {
			headers = res.headers;
		}
		return headers;
	}
	function get_emitter() return _emitter;
}
