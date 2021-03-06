package thx.http;

import haxe.io.Bytes;
import thx.http.RequestType;
import utest.Assert;
using thx.http.Request;
using thx.Arrays;
using thx.Strings;
#if thx_stream
using thx.stream.Stream;
#end

class TestRequest {
  public function new() {}

  public function testSimpleRequest() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", [
            "Agent" => "thx.http.Request"
          ]);

    Request.make(info, Text)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.equals("OK", r))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

public function test404() {
  var done = Assert.createAsync(300),
      info = new RequestInfo(Get, "http://localhost:8081/404", [ "Agent" => "thx.http.Request" ]);

  Request.make(info, Text)
    .response
    .flatMap(function(r) {
      Assert.equals(404, r.statusCode);
      return r.body;
    })
    .success(function(_) Assert.pass())
    .failure(function(e) Assert.fail("should never reach this point"))
    .always(done);
}

  public function testSafe404() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/404", [ "Agent" => "thx.http.Request" ]);

    Request.make(info, Text)
      .body
      .failure(function(_) Assert.pass())
      .success(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testSafe200() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", [ "Agent" => "thx.http.Request" ]);

    Request.make(info, Text)
      .body
      .success(function(r) Assert.equals("OK", r))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testHeaders() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/headers", [ "Agent" => "thx.http.Request" ]);

    Request.make(info, Json)
      .body
      .success(function(r) {
        Assert.equals("thx.http.Request", r.agent);
#if(neko||cpp)
        Assert.equals("localhost", r.host);
#else
        Assert.equals("localhost:8081", r.host);
#end
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testQueryStringBody() {
    var message = "request thx body",
        done = Assert.createAsync(),
        info = new RequestInfo(Post, 'http://localhost:8081/qs?q=$message', NoBody);

    Request.make(info, Text)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.equals(message, r))
      .failure(function(e) Assert.fail('$e'))
      .always(done);
  }

  public function testStringBody() {
    var message = "request thx body",
        done = Assert.createAsync(),
        info = new RequestInfo(Post, 'http://localhost:8081/json', Text('{"q":"$message"}'));
    info.headers.add("Content-Type", "application/json");

    Request.make(info, Text)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.equals(message, r))
      .failure(function(e) Assert.fail('$e'))
      .always(done);
  }

  public function testBytesBody() {
    var size = 100,
        message = Bytes.alloc(size),
        done = Assert.createAsync(),
        info = new RequestInfo(Post, 'http://localhost:8081/raw', Binary(message));

    info.headers.add("Content-Type", "text/plain");

    for(i in 0...size)
      message.set(i, Math.floor(31 + Math.random() * 95));

    Request.make(info, Text)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.same(message.toString(), r))
      .failure(function(e) Assert.fail('$e'))
      .always(done);
  }

  public function testInputBody() {
    var size = 50000,
        message = Bytes.alloc(size),
        done = Assert.createAsync(),
        input = new haxe.io.BytesInput(message),
        info = new RequestInfo(Post, 'http://localhost:8081/raw', Input(input));

    info.headers.add("Content-Type", "text/plain");

    for(i in 0...size)
      message.set(i, Math.floor(31 + Math.random() * 95));

    Request.make(info, Text)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.same(message.toString(), r))
      .failure(function(e) Assert.fail('$e'))
      .always(done);
  }

  public function testNoContent() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/nocontent", [
            "Agent" => "thx.http.Request"
          ]);

    Request.make(info, NoBody)
      .response
      .flatMap(function(r) {
        //Assert.same(r.body, ResponseBody.NoBody);
        Assert.equals(204, r.statusCode);
        return r.body;
      })
      .success(function(_) {
        Assert.pass();
        done();
      })
      .failure(function(e) Assert.fail("should never reach this point"));
  }

  public function testJsonResponse() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/json", ["Agent" => "thx.http.Request"]);

    Request.make(info, Json)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.equals("OK", r.message);
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testBytesResponse() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", ["Agent" => "thx.http.Request"]);

    Request.make(info, Binary)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.is(r, haxe.io.Bytes);
        Assert.equals(2, r.length);
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

#if (nodejs || hxnodejs)
  public function testBuffer() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", ["Agent" => "thx.http.Request"]);

    Request.make(info, JSBuffer)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.isTrue(null != r.copy, "response is not of type Buffer");
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }
#elseif js
/*
JSArrayBufferView(buffer : js.html.ArrayBufferView);
JSBlob(blob : js.html.Blob);
JSDocument(doc : js.html.HTMLDocument); // TODO Document or HTMLDocument
JSFormData(formData : js.html.FormData);
*/

  public function testJSBlob() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", ["Agent" => "thx.http.Request"]);

    Request.make(info, JSBlob)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.equals(2, r.size, "response is not of type Blob");
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testJSArrayBuffer() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", ["Agent" => "thx.http.Request"]);

    Request.make(info, JSArrayBuffer)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.equals(2, r.byteLength, "response is not of type ArrayBuffer");
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testJSDocument() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/html", ["Agent" => "thx.http.Request"]);

    Request.make(info, JSDocument)
      .response
      .flatMap(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.equals('<div></div>', r.body.innerHTML.trim());
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }
#end
}
