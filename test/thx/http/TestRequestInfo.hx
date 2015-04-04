package thx.http;

import utest.Assert;
using thx.http.Request;

class TestRequestInfo {
	public function new() {}

	public function testToString() {
		var info = new RequestInfo(Get, "http://localhost:6666", [
						"agent" => "thx.http.Request"
					]);

		Assert.equals(
			"GET / HTTP/1.1\r\nHost: localhost:6666\r\nAgent: thx.http.Request",
			info.toString()
		);
	}
}
