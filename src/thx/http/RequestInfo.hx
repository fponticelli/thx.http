package thx.http;

import haxe.io.Bytes;
import thx.http.RequestBody;
using thx.promise.Promise;
using thx.stream.Emitter;
using thx.Strings;
import thx.Url;

class RequestInfo {
	public static function parse(request : String) : RequestInfo {
		Const.NL.match(request);
		var firstLine = Const.WS.split(Const.NL.matchedLeft());
		request = Const.NL.matchedRight();

		var headersBlock,
				bodyBlock = null,
				method : Method = firstLine[0],
				headers : Headers,
				url,
				body;

		if(Const.NL2.match(request)) {
			headersBlock = Const.NL2.matchedLeft();
			bodyBlock = Const.NL2.matchedRight();
		} else {
			headersBlock = request;
		}
		headers = headersBlock;
		var host = headers.get("Host");
		if(null == host) {
			url = firstLine[1];
		} else {
			if(!host.startsWith('http://') && !host.startsWith('https://'))
				host = 'http://$host';
			url = '$host${firstLine[1]}';
			headers.remove("Host");
		}
		body = bodyBlock.isEmpty() ? NoBody : BodyString(bodyBlock);
		return new RequestInfo(
			method,
			url,
			headers,
			body,
			firstLine[2].split("/").pop()
		);
	}

	public var method : Method;
	public var url : Url;
	public var headers : Headers;
	public var version : String;
	public var body : RequestBody;

	public function new(method : Method, url : Url, ?headers : Headers, ?body : RequestBody, ?version = "1.1") {
		this.method = method;
		this.url = url;
		this.headers = null == headers ? Headers.empty() : headers;
		this.version = version;
		this.body = null == body ? NoBody : body;
	}

	public function toString() {
		var h = headers.toString(),
				path = url.path;

		if(path.substring(0, 1) != "/")
			path = '/$path';
		var buf = ['$method $path ${url.protocol.toUpperCase()}/$version'];
		if(url.isAbsolute)
			buf.push('Host: ${url.host}');
		if(h != "")
			buf.push(h);
		switch body {
			case NoBody:
			case BodyStream(e): // TODO print something here?
			case BodyString(s, _):
				buf.push(Const.CRLF + s);
			case BodyBytes(b):
				buf.push(Const.CRLF + b.toString());
			case BodyInput(s):
				var b = s.readAll();
				body = BodyBytes(b);
				buf.push(Const.CRLF + b.toString());
		}
		return buf.join(Const.CRLF);
	}

	public function read() : Promise<Bytes> {
		switch body {
			case NoBody:
				return Promise.value(Bytes.alloc(0));
			case BodyBytes(b):
				return Promise.value(b);
			case BodyStream(e):
				return e.toPromise()
					.mapSuccess(function(bytes) {
						body = BodyBytes(bytes);
						return bytes;
					});
			case BodyString(s, _):
				var b = Bytes.ofString(s);
				body = BodyBytes(b);
				return Promise.value(b);
			case BodyInput(s):
				var b = s.readAll();
				body = BodyBytes(b);
				return Promise.value(b);
		}
	}
}
