class TestServer implements abe.IRoute {
  static function main() {
    abe.App.installNpmDependencies(false);
    var app = new abe.App(),
        router = app.router;
    router.use(mw.Cors.create());
    router.register(new TestServer());
    app.http(8081);
  }

  @:get("/")
  function root() {
    trace('SEND: OK');
    response.status(200).send("OK");
  }

  @:post("/qs")
  @:args(Query, Body)
  function bounceQs(q : String) {
    trace('QUERY', q);
    response.status(200).send(q);
  }

  @:post("/json")
  @:use(mw.BodyParser.json())
  //@:args(Body)
  function bounceJson() {
    trace('BODY', request.body);
    response.status(200).send(Reflect.field(request.body, "q"));
  }

  @:get("/html")
  function sendHtml() {
    trace('SEND: HTML');
    response.send('<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <title>title</title>
  </head>
  <body><div></div></body>
</html>');
  }

  @:get("/json")
  function sendJson() {
    trace('SEND: JSON OBJECT');
    response.send({ message : "OK" });
  }

  @:post("/raw")
  @:use(mw.BodyParser.text())
  function bounceRaw() {
    trace("RAW");
    response.status(200).send(request.body);
  }

  @:get("/nocontent")
  function nocontent() {
    trace('SEND: NO CONTENT');
    response.sendStatus(204);
  }

  @:get("/headers")
  function headers() {
    response.send((cast request.headers : {}));
  }

  @:get("/shutdown")
  function shutdown() {
    response.sendStatus(204);
    js.Node.process.exit(0);
  }
}
