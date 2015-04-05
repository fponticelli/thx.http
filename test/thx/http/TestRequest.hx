package thx.http;

import utest.Assert;
using thx.http.Request;

class TestRequest {
	public function new() {}

	public function testSimpleRequest() {
		var done = Assert.createAsync(),
				info = new RequestInfo(Get, "http://localhost:8081/", [
						"Agent" => "thx.http.Request"
					]),
				handler = RequestHandler.create(function(status : Int) {
					Assert.equals(200, status);
					done();
				});

		Request.make(info, handler);
	}
}
