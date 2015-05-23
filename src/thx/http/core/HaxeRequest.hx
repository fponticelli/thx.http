package thx.http.core;

using thx.Arrays;
using thx.Strings;
using thx.promise.Promise;
using thx.stream.Value;
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

			var value = new Value(null);
			req.onData = function(data : String) {
				if(!data.isEmpty())
					value.set(Bytes.ofString(data));
			};
			req.onStatus = function(s) {
				resolve(new HaxeResponse(s, value, req.responseHeaders));
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
	public function new(statusCode : Int, value : Value<Bytes>, headers : Headers) {
		this._statusCode = statusCode;
		this.headers = headers;
		emitter = value;
	}

	override function get_statusCode() return _statusCode;
}
