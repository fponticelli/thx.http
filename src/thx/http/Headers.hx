package thx.http;

using thx.core.Arrays;
using thx.core.Iterators;
using thx.core.Maps;
using thx.core.Strings;

abstract Headers(Map<String, String>) to Map<String, String> {
	public static function empty()
		return new Headers(new Map());

	inline function new(map : Map<String, String>)
		this = map;

	@:from static function fromMap(map : Map<String, String>) : Headers {
		// TODO normalize keys
		var skeys = map.keys().toArray(),
				nkeys = skeys.map(normalize);
		skeys.zip(nkeys).map(function(t) {
			if(t._0 == t._1) return;
			var v = map.get(t._0);
			map.remove(t._0);
			map.set(t._1, v);
		});
		return new Headers(map);
	}

	public static function normalize(key : String)
		return key.underscore().dasherize().capitalizeWords();

	public function toString()
		return this.tuples().pluck('${_.left}: ${_.right}').join("\n");
}
