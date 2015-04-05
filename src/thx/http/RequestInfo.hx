package thx.http;

import thx.core.Url;

class RequestInfo {
	public var method : Method;
	public var url : Url;
	public var headers : Headers;
	public var version : String;
	// TODO add body
	public function new(method : Method, url : Url, ?headers : Headers, version = "1.1") {
		this.method = method;
		this.url = url;
		this.headers = null == headers ? Headers.empty() : headers;
		this.version = version;
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
		return buf.join(Const.CRLF);
	}
}
