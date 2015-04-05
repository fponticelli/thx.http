import utest.Runner;
import utest.ui.Report;

class TestAll {
	static function main() {
		var runner = new Runner();
		runner.addCase(new thx.http.TestHeaders());
		runner.addCase(new thx.http.TestRequestInfo());
		runner.addCase(new thx.http.TestRequest());
		Report.create(runner);
		runner.run();
	}
}
