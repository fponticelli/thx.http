import utest.Runner;
import utest.ui.Report;

class TestAll {
	static function main() {
		abe.App.installNpmDependencies(false);
		var app = new abe.App();
		app.router.register(new TestServer());
		var server : js.node.http.Server = null;
		server = app.http(6666, function() {
			var runner = new Runner();
			register(runner);
			Report.create(runner);
			runner.onComplete.add(function(_) {
				server.close();
			});
			runner.run();
		});
	}

	static function register(runner : Runner) {
		runner.addCase(new thx.http.TestRequestInfo());
		runner.addCase(new thx.http.TestRequest());
	}
}
