package thx.http;

import utest.Assert;
using thx.http.Headers;

class TestHeader {
	public function new() {}

	public function testNormalization() {
		var tests = [
			["Accept", "Accept"],
			["Accept", "accept"],
			["Transfer-Encoding", "TransferEncoding"],
			["Transfer-Encoding", "transferEncoding"],
			["X-Powered-By", "xPoweredBy"]
		];

		for(test in tests)
			Assert.equals(test[0], Header.normalizeKey(test[1]));
	}
}
