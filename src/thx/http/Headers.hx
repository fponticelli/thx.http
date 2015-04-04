package thx.http;

abstract Headers(Map<String, String>) to Map<String, String> {
	public static function empty()
		return new Headers(new Map());

	inline function new(map : Map<String, String>)
		this = map;

	@:from static function fromMap(map : Map<String, String>) : Headers {
		// TODO normalize keys
		return new Headers(map);
	}

	public function toString() {

	}
}
