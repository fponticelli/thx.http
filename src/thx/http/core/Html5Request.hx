package thx.http.core;

import thx.http.Header;
import js.html.XMLHttpRequest;
using thx.promise.Promise;
import thx.stream.*;
using thx.Arrays;
using thx.Error;
import haxe.io.Bytes;

class Html5Request {
	public static function make(requestInfo : RequestInfo) : Promise<Response> {
		return Promise.create(function(resolve : Response -> Void, reject) {
			var req = new XMLHttpRequest();
			req.onreadystatechange = function(e) {
				if(req.readyState != 2) // 2: request received
					return;
				resolve(new Html5Response(req));
			};
			req.onerror = function(e) {
				reject(thx.Error.fromDynamic(e));
			};
			req.open(
				requestInfo.method,
				requestInfo.url,
				true
			);
			req.responseType = ARRAYBUFFER;
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
		});
	}
}

class Html5Response implements thx.http.Response {
	public var statusCode(get, null) : Int;
	public var statusText(get, null) : String;
	@:isVar public var headers(get, null) : Headers;
	@:isVar public var emitter(get, null) : Emitter<Bytes>;
	var req : XMLHttpRequest;
	public function new(req : XMLHttpRequest) {
		this.req = req;
		var bus = new Bus();
		req.onload = function(e) {
			if(req.response == null) {
				bus.end();
			} else {
				bus.pulse(Bytes.ofData(req.response));
				bus.end();
			}
		};
		/*
		res.on("readable", function() {
			var buf : Buffer = res.read();
			if(buf == null)
				bus.end();
			else
				bus.pulse(buf.toBytes());
		});
		*/
		this.emitter = bus;
	}

	function get_emitter() return emitter;
	function get_statusCode() return req.status;
	function get_statusText() return req.statusText;
	function get_headers() {
		if(null == headers) {
			headers = req.getAllResponseHeaders();
		}
		return headers;
	}
}
