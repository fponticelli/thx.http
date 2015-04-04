package thx.http;

class RequestHandler {
	public static function create(statusHandler : Int -> Void) {
		return new DynamicRequestHandler(statusHandler);
	}

	private function new() {

	}
}

private class DynamicRequestHandler extends RequestHandler {
	public function new(statusHandler : Int -> Void) {
		super();
	}
}
