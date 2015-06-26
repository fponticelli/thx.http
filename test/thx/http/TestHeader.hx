package thx.http;

import utest.Assert;
using thx.http.Headers;

class TestHeader {
	public function new() {}

	public function testNormalization() {
		var tests = [
			["Accept", "Accept"],
			["accept", "accept"],
			["Transfer-Encoding", "TransferEncoding"],
			["Transfer-Encoding", "transferEncoding"],
			["X-Powered-By", "xPoweredBy"],
			["x-powered-by", "x-powered-by"]
		];

		for(test in tests)
			Assert.equals(test[0], Header.normalizeKey(test[1]));
	}
}
