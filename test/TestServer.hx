class TestServer implements abe.IRoute {
	static function main() {
		abe.App.installNpmDependencies(false);
		var app = new abe.App();
		app.router.register(new TestServer());
		var server : js.node.http.Server = null;
		server = app.http(6666);
	}

	@:get("/")
	function root() {
		response.status(200).send("OK");
	}
}
