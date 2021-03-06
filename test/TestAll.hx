import utest.Runner;
import utest.ui.Report;

class TestAll {
  static function main() {
    var runner = new Runner();
    runner.addCase(new thx.http.TestHeader());
    runner.addCase(new thx.http.TestHeaders());
    runner.addCase(new thx.http.TestRequestInfo());
    runner.addCase(new thx.http.TestRequest());
    runner.addCase(new thx.http.TestResponse());
    Report.create(runner);
    runner.run();
  }
}
