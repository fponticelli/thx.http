package thx.http;

import thx.Url;
import thx.http.RequestBody;

class RequestInfo {
	public var method : Method;
	public var url : Url;
	public var headers : Headers;
	public var version : String;
	public var body : RequestBody;

	public function new(method : Method, url : Url, ?headers : Headers, ?body : RequestBody) {
		this.method = method;
		this.url = url;
		this.headers = null == headers ? Headers.empty() : headers;
		this.version = "1.1";
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
			case BodyString(s, _):
				buf.push(Const.CRLF + s);
			case BodyBytes(b):
				buf.push(Const.CRLF + b.toString());
			case BodyStream(s):
				buf.push(Const.CRLF + s.readAll().toString());
		}
		return buf.join(Const.CRLF);
	}
}
