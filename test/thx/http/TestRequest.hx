package thx.http;

import haxe.io.Bytes;
import utest.Assert;
import thx.http.RequestBody;
using thx.http.Request;
using thx.stream.Emitter;
using thx.stream.Bus;
using thx.Arrays;

class TestRequest {
  public function new() {}

  public function testSimpleRequest() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", [
            "Agent" => "thx.http.Request"
          ]);

    Request.make(info, ResponseTypeText)
      .response
      .mapSuccessPromise(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.equals("OK", r))
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }

  public function testQueryStringBody() {
    var message = "request thx body",
        done = Assert.createAsync(),
        info = new RequestInfo(Post, 'http://localhost:8081/qs?q=$message', NoBody);

    Request.make(info, ResponseTypeText)
      .response
      .mapSuccessPromise(function(r) {
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
        info = new RequestInfo(Post, 'http://localhost:8081/json', BodyString('{"q":"$message"}'));
    info.headers.add("Content-Type", "application/json");

    Request.make(info, ResponseTypeText)
      .response
      .mapSuccessPromise(function(r) {
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
        info = new RequestInfo(Post, 'http://localhost:8081/raw', BodyBytes(message));

    info.headers.add("Content-Type", "text/plain");

    for(i in 0...size)
      message.set(i, Math.floor(31 + Math.random() * 95));

    Request.make(info, ResponseTypeText)
      .response
      .mapSuccessPromise(function(r) {
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
        info = new RequestInfo(Post, 'http://localhost:8081/raw', BodyInput(input));

    info.headers.add("Content-Type", "text/plain");

    for(i in 0...size)
      message.set(i, Math.floor(31 + Math.random() * 95));

    Request.make(info, ResponseTypeText)
      .response
      .mapSuccessPromise(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.same(message.toString(), r))
      .failure(function(e) Assert.fail('$e'))
      .always(done);
  }
#if !neko
  public function testStreamBody() {
    var size = 10000,
        chunks = 10,
        messages = [for(i in 0...chunks) Bytes.alloc(size)],
        message = Bytes.alloc(size * chunks),
        done = Assert.createAsync(3000),
        emitter : Bus<Bytes> = new Bus(),
        info = new RequestInfo(Post, 'http://localhost:8081/raw', BodyStream(emitter));

    info.headers.add("Content-Type", "text/plain");

    messages.mapi(function(msg, j) {
      for(i in 0...size) {
        msg.set(i, Math.floor(31 + Math.random() * 95));
        message.set(j * size + i, msg.get(i));
      }
      #if neko
      emitter.pulse(msg);
      #else
      thx.Timer.delay(function() emitter.pulse(msg), 50 * (j + 1));
      #end
    });
    #if neko
    emitter.end();
    #else
    thx.Timer.delay(function() emitter.end(), 50 * (chunks + 2));
    #end

    Request.make(info, ResponseTypeText)
      .response
      .mapSuccessPromise(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) Assert.same(message.toString(), r))
      .failure(function(e) Assert.fail('$e'))
      .always(done);
  }
#end
  public function testNoContent() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/nocontent", [
            "Agent" => "thx.http.Request"
          ]);

    Request.make(info, ResponseTypeNoBody)
      .response
      .mapSuccessPromise(function(r) {
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

  public function testBytesResponse() {
    var done = Assert.createAsync(),
        info = new RequestInfo(Get, "http://localhost:8081/", ["Agent" => "thx.http.Request"]);

    Request.make(info, ResponseTypeBytes)
      .response
      .mapSuccessPromise(function(r) {
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

    Request.make(info, ResponseTypeJSBuffer)
      .response
      .mapSuccessPromise(function(r) {
        Assert.equals(200, r.statusCode);
        return r.body;
      })
      .success(function(r) {
        Assert.isTrue(null != r.copy, "response is not of type Buffer");
      })
      .failure(function(e) Assert.fail("should never reach this point"))
      .always(done);
  }
#end
}
