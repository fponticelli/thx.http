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
		response.status(200).send("OK");
	}

	@:post("/")
	@:use(mw.BodyParser.text())
	function bounce() {
		response.status(200).send(Reflect.field(request.query, "q"));
	}

	@:get("/nocontent")
	function nocontent() {
		response.sendStatus(204);
	}
}
