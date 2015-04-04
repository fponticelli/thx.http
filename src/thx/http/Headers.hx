package thx.http;

using thx.core.Arrays;
using thx.core.Maps;

abstract Headers(Map<String, String>) to Map<String, String> {
	public static function empty()
		return new Headers(new Map());

	inline function new(map : Map<String, String>)
		this = map;

	@:from static function fromMap(map : Map<String, String>) : Headers {
		// TODO normalize keys
		return new Headers(map);
	}

	public function toString()
		return this.tuples().pluck('${_.left}: ${_.right}').join("\n");
}
