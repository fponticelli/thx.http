package thx.http.core;

import thx.http.Header;
import js.html.XMLHttpRequest;
using thx.core.Arrays;

class Html5Request {
	public static function make(requestInfo : RequestInfo, requestHandler : RequestHandler) : Void -> Void {
		var req = new XMLHttpRequest();
		req.onload = function() {
			requestHandler.statusHandler(req.status, req.responseText);
		};
		req.open(
			requestInfo.method,
			requestInfo.url,
			true
		);
		(requestInfo.headers : Array<Header>).pluck(req.setRequestHeader(_.key, _.value));
		switch requestInfo.body {
			case NoBody:
				req.send();
			case BodyString(s, e):
				req.send(s);
			case BodyBytes(b):
				req.send(b);
			case BodyStream(s):
				req.send(s);
			}
		return function() {};
	}
}
