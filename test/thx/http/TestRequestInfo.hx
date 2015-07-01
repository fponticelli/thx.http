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
      "GET / HTTP/1.1\r\nHost: localhost:6666\r\nagent: thx.http.Request",
      info.toString()
    );
  }

  public function testParse() {
    var info = RequestInfo.parse("POST / HTTP/1.1
content-type:application/x-www-form-urlencoded;charset=utf-8
host: https://importexport.amazonaws.com
content-length:207

Action=GetStatus&SignatureMethod=HmacSHA256&JobId=JOBID&SignatureVersion=2&Version=2014-12-18&Signature=%2FVfkltRBOoSUi1sWxRzN8rw%3D&Timestamp=2014-12-20T22%3A30%3A59.556Z");

    Assert.equals("POST", info.method);
    Assert.equals("https://importexport.amazonaws.com/", info.url.toString());
    Assert.equals("application/x-www-form-urlencoded;charset=utf-8", info.headers.get("content-type"));
    Assert.equals("207", info.headers.get("content-length"));
    Assert.isFalse(info.headers.exists("host"));
    Assert.same(RequestBody.BodyString("Action=GetStatus&SignatureMethod=HmacSHA256&JobId=JOBID&SignatureVersion=2&Version=2014-12-18&Signature=%2FVfkltRBOoSUi1sWxRzN8rw%3D&Timestamp=2014-12-20T22%3A30%3A59.556Z"), info.body);
  }
}
