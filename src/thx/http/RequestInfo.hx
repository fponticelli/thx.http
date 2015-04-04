package thx.http;

import thx.core.Url;

class RequestInfo {
	public var method : Method;
	public var url : Url;
	public var headers : Headers;
	// TODO add body
	public function new(method : Method, url : Url, ?headers : Headers) {
		this.method = method;
		this.url = url;
		this.headers = null == headers ? Headers.empty() : headers;
	}

	public function toString() {
		var h = headers.toString(),
				buf = ['$method $url'];
		if(h != "")
			buf.push(h);
		return buf.join("\n");
	}
}
