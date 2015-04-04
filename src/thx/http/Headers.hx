package thx.http;

using thx.core.Arrays;
using thx.core.Iterators;
using thx.core.Maps;
using thx.core.Strings;
using thx.core.Ints;

abstract Headers(Map<String, String>) to Map<String, String> {
	static var CRLF_PATTERN = ~/\r\n|\n\r|\r|\n/mg;
	public static function empty()
		return new Headers(new Map());

	inline function new(map : Map<String, String>)
		this = map;

	@:from static function fromMap(map : Map<String, String>) : Headers {
		var skeys = map.keys().toArray(),
				nkeys = skeys.map(normalizeKey);
		skeys.zip(nkeys).map(function(t) {
			var v = normalizeValue(map.get(t._0));
			map.remove(t._0);
			map.set(t._1, v);
		});
		return new Headers(map);
	}

	public static function normalizeKey(key : String)
		return key.trim().underscore().dasherize().capitalizeWords();

	public static function normalizeValue(value : String, ?key : String = " ")
		return CRLF_PATTERN.replace(value, Const.CRLF);

	public static function formatValue(value : String, key : String) {
		var len = key.length.max(1) + 2; // +2 for ": "
		return value.replace(Const.CRLF, Const.CRLF + Strings.repeat(" ", len));
	}

	public function toString()
		return this.tuples().pluck('${_.left}: ${formatValue(_.right, _.left)}').join("\n");
}
