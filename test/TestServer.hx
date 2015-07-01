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

  @:get("/shutdown")
  function shutdown() {
    response.sendStatus(204);
    js.Node.process.exit(0);
  }
}
