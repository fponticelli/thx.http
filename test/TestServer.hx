class TestServer implements abe.IRoute {
	static function main() {
		abe.App.installNpmDependencies(false);
		var app = new abe.App(),
				router = app.router;
		router.use(mw.Cors.create());
		router.register(new TestServer());
		var server : js.node.http.Server = null;
		server = app.http(8081);
	}

	@:get("/")
	function root() {
		trace('SEND: OK');
		response.status(200).send("OK");
	}

	@:post("/")
	@:use(mw.BodyParser.text())
	function bounce() {
		var content = Reflect.field(request.query, "q");
		trace('SEND: $content');
		response.status(200).send(content);
	}

	@:get("/nocontent")
	function nocontent() {
		trace('SEND: NO CONTENT');
		response.sendStatus(204);
	}
}
