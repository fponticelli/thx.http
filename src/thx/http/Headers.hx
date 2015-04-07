package thx.http;

using thx.core.Arrays;
using thx.core.Iterators;
using thx.core.Maps;
using thx.core.Strings;
using thx.core.Ints;
using thx.core.Tuple;

@:forward(iterator)
abstract Headers(Array<Header>) from Array<Header> to Array<Header> {
	@:from public static function fromMap(map : Map<String, String>) : Headers
		return map.tuples();

	@:from public static function fromStringMap(map : haxe.ds.StringMap<String>) : Headers
		return map.tuples();

	@:from public static function fromTuples(arr : Array<Tuple2<String, String>>) : Headers
		return arr.map(function(t) return (t : Header));

	public static function empty()
		return new Headers([]);

	inline function new(arr : Array<Header>)
		this = arr;

	public function exists(key : String) : Bool {
		key = Header.normalizeKey(key);
		return this.any(function(h) return h.key == key);
	}

	public function get(key : String) : String {
		var p = getHeader(key);
		return p == null ? null : p.value;
	}

	public function remove(key : String) {
		key = Header.normalizeKey(key);
		var p = this.find(function(h) return h.key == key);
		return this.remove(p);
	}

	public function getHeader(key : String) : Header {
		key = Header.normalizeKey(key);
		return this.find(function(h) return h.key == key);
	}

	public function set(key : String, value : String) {
		var p = getHeader(key);
		if(null == p)
			add(key, value);
		else
			p.value = value;
	}

	public function add(key : String, value : String)
		this.push(Header.fromTuple(new Tuple2(key, value)));

	public static function formatValue(value : String, key : String) {
		var len = key.length.max(1) + 2; // +2 for ": "
		return value.replace(Const.CRLF, Const.CRLF + Strings.repeat(" ", len));
	}

	public function toObject() {
		var o = {};
		this.pluck(Reflect.setField(o, _.key, _.value));
		return o;
	}

	public function toString()
		return this.pluck('${_.key}: ${formatValue(_.value, _.key)}').join("\n");
}
