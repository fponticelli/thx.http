package thx.http.core;

import js.html.XMLHttpRequest;
using thx.Arrays;
using thx.Error;
import thx.http.Header;
using thx.promise.Promise;
import thx.stream.*;
import haxe.io.Bytes;

class Html5Request {
	public static function make(requestInfo : RequestInfo) : Promise<Response> {
		return Promise.create(function(resolve : Response -> Void, reject) {
			var bus = new Bus(),
					req = new XMLHttpRequest();
			req.onload = function(e) {
				if(req.response == null || req.response.length == 0) {
					bus.end();
				} else {
					bus.pulse(Bytes.ofData(req.response));
					bus.end();
				}
			};
			req.onreadystatechange = function(e) {
				if(req.readyState != 2) // 2: request received
					return;
				resolve(new Html5Response(req, bus));
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

class Html5Response extends thx.http.Response {
	var req : XMLHttpRequest;
	public function new(req : XMLHttpRequest, bus : Bus<Bytes>) {
		this.req = req;
		headers = req.getAllResponseHeaders();
		this.emitter = bus;
	}

	override function get_statusCode() return req.status;
	override function get_statusText() return req.statusText;
}
