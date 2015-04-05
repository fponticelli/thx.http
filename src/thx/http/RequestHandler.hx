package thx.http;

class RequestHandler {
	public static function create(statusHandler : Int -> Void) {
		return new DynamicRequestHandler(statusHandler);
	}

	private function new() {

	}

	public function statusHandler(status : Int) {}
}

private class DynamicRequestHandler extends RequestHandler {
	var _statusHandler : Int -> Void;
	public function new(statusHandler : Int -> Void) {
		super();
		_statusHandler = statusHandler;
	}

	override public function statusHandler(status : Int)
		_statusHandler(status);
}
