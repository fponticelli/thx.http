package thx.http;

import utest.Assert;
import thx.http.RequestBody;
using thx.http.Request;

class TestRequest {
	public function new() {}

	public function testSimpleRequest() {
		var done = Assert.createAsync(),
				info = new RequestInfo(Get, "http://localhost:8081/", [
						"Agent" => "thx.http.Request"
					]);

		Request.make(info,
			function(r) {
				Assert.equals(200, r.statusCode);
				done();
			},
			function(e) Assert.fail("should never reach this point")
		);
	}

	public function testStringBody() {
		var message = "request thx body",
				done = Assert.createAsync(),
				info = new RequestInfo(Post, "http://localhost:8081/", BodyString(message));

		Request.make(info,
			function(r) {
				trace(r.headers);
				Assert.equals(200, r.statusCode);
				var s = switch r.body {
					case BodyString(s, _): s;
					case BodyBytes(b): b.toString();
					case BodyStream(s): s.readAll().toString();
					case NoBody: null;
				};
				Assert.equals(message, s);
				done();
			},
			function(e) Assert.fail("should never reach this point")
		);
	}
}
