package thx.http;

import utest.Assert;
import thx.http.RequestBody;
using thx.http.Request;
using thx.stream.Emitter;

class TestRequest {
	public function new() {}

	public function testSimpleRequest() {
		var done = Assert.createAsync(),
				info = new RequestInfo(Get, "http://localhost:8081/", [
						"Agent" => "thx.http.Request"
					]);

		Request.make(info)
			.mapSuccessPromise(function(r) {
				Assert.equals(200, r.statusCode);
				return r.asString();
			})
			.success(function(r) Assert.equals("OK", r))
			.failure(function(e) Assert.fail("should never reach this point"))
			.always(done);
	}

	public function testStringBody() {
		var message = "request thx body",
				done = Assert.createAsync(),
				info = new RequestInfo(Post, 'http://localhost:8081/?q=$message', NoBody);

		Request.make(info)
			.mapSuccessPromise(function(r) {
				Assert.equals(200, r.statusCode);
				return r.asString();
			})
			.success(function(r) Assert.equals(message, r))
			.failure(function(e) Assert.fail('$e'))
			.always(done);
	}

	public function testNoContent() {
		var done = Assert.createAsync(),
				info = new RequestInfo(Get, "http://localhost:8081/nocontent", [
						"Agent" => "thx.http.Request"
					]);

		Request.make(info)
			.success(function(r) {
				//Assert.same(r.body, ResponseBody.NoBody);
				Assert.equals(204, r.statusCode);
				done();
			})
			.failure(function(e) Assert.fail("should never reach this point"));
	}
}
