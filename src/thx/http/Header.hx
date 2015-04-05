package thx.http;

import thx.core.Tuple;
using thx.core.Strings;

abstract Header(Tuple2<String, String>) to Tuple2<String, String> {
	static var CRLF_PATTERN = ~/\r\n|\n\r|\r|\n/mg;

	@:from static public inline function fromTuple(t : Tuple2<String, String>) : Header {
		return new Header(normalize(t));
	}

	public static function normalize(t : Tuple2<String, String>) {
		t._0 = normalizeKey(t._0);
		t._1 = normalizeKey(t._1);
		return t;
	}

	public static function normalizeKey(key : String)
		return key.trim().underscore().dasherize().capitalizeWords();

	public static function normalizeValue(value : String, ?key : String = " ")
		return CRLF_PATTERN.replace(value, Const.CRLF);

	inline function new(t : Tuple2<String, String>)
		this = t;
}
