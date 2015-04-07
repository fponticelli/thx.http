package thx.http;

import thx.core.Tuple;
using thx.core.Strings;

abstract Header(Tuple2<String, String>) to Tuple2<String, String> {
	static var CRLF_PATTERN = ~/\r\n|\n\r|\r|\n/mg;

	public static function raw(key : String, value : String)
		return new Header(new Tuple2(key, value));

	@:from static public inline function fromTuple(t : Tuple2<String, String>) : Header
		return new Header(normalize(t));

	public static function normalize(t : Tuple2<String, String>) {
		t._0 = normalizeKey(t._0);
		t._1 = normalizeValue(t._1);
		return t;
	}

	public static function normalizeKey(key : String)
		return key.trim().underscore().dasherize().capitalizeWords();

	public static function normalizeValue(value : String, ?key : String = " ")
		return CRLF_PATTERN.replace(value, Const.CRLF);

	public var key(get, set) : String;
	public var value(get, set) : String;

	inline function new(t : Tuple2<String, String>)
		this = t;

	inline function get_key()
		return this._0;

	inline function set_key(v : String)
		return this._0 = normalizeKey(v);

	inline function get_value()
		return this._1;

	inline function set_value(v : String)
		return this._1 = normalizeValue(v);
}
