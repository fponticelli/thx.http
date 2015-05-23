package thx.http.core;

using thx.Arrays;
using thx.Strings;
using thx.promise.Promise;
using thx.stream.Emitter;
import haxe.io.Bytes;

class HaxeRequest {
	public static function make(requestInfo : RequestInfo) : Promise<Response> {
		return Promise.create(function(resolve : Response -> Void, reject) {
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

			var data = null,
					emitter = new Emitter(function(stream){
						if(null != data)
							stream.pulse(data);
						stream.end();
					});
			req.onData = function(d : String) {
				data = Bytes.ofString(d);
			};
			req.onStatus = function(s) {
				resolve(new HaxeResponse(s, emitter, req.responseHeaders));
			};
			req.onError = function(msg) {
				trace('ERROR: $msg');
				reject(new thx.Error(msg));
			};

			switch requestInfo.method {
				case Get:   req.request(false);
				case Post:  req.request(true);
				case other: throw 'haxe.Http doesn\'t support method "$other"';
			}
		});
	}
}

class HaxeResponse extends thx.http.Response {
	var _statusCode : Int;
	public function new(statusCode : Int, emitter : Emitter<Bytes>, headers : Headers) {
		this._statusCode = statusCode;
		this.headers = headers;
		this.emitter = emitter;
	}

	override function get_statusCode() return _statusCode;
}
