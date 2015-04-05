package thx.http;

class RequestHandler {
	public static function create(statusHandler : Int -> String -> Void) {
		return new DynamicRequestHandler(statusHandler);
	}

	private function new() {

	}

	public function statusHandler(status : Int, content : String) {}
}

private class DynamicRequestHandler extends RequestHandler {
	var _statusHandler : Int -> String -> Void;
	public function new(statusHandler : Int -> String -> Void) {
		super();
		_statusHandler = statusHandler;
	}

	override public function statusHandler(status : Int, content : String)
		_statusHandler(status, content);
}
