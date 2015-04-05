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
					]),
				handler = RequestHandler.create(function(status : Int, _) {
					Assert.equals(200, status);
					done();
				});

		Request.make(info, handler);
	}

	public function testStringBody() {
		var message = "request thx body",
				done = Assert.createAsync(),
				info = new RequestInfo(Post, "http://localhost:8081/", BodyString(message)),
				handler = RequestHandler.create(function(status : Int, body : String) {
					Assert.equals(message, body);
					Assert.equals(200, status);
					done();
				});

		Request.make(info, handler);
	}
}
