package thx.http;

import haxe.io.Bytes;
import thx.http.RequestType;
import utest.Assert;
using thx.http.Request;
using thx.Arrays;
using thx.Strings;
#if thx_stream
using thx.stream.Bus;
using thx.stream.Emitter;
#end

class TestResponse {
  public function new() {}

  public function testGetText() {
    var done = Assert.createAsync();

    Request.getText("http://localhost:8081/")
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.equals("OK", r))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testBody() {
    var done = Assert.createAsync();

    Request.getText("http://localhost:8081/")
      .body
      .success(function(r) Assert.equals("OK", r))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testResponseMap() {
    var done = Assert.createAsync();

    Request.getText("http://localhost:8081/")
      .body
      .map(function(v) return v.toLowerCase())
      .success(function(r) Assert.equals("ok", r))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testGetJson() {
    var done = Assert.createAsync();

    Request.getJson("http://localhost:8081/json")
      .body
      .success(function(r) Assert.equals("OK", r.message))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }
}
