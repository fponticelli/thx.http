package thx.http;

using thx.Arrays;
using thx.Functions;
using thx.Dynamics;
using thx.Ints;
using thx.Iterators;
using thx.Maps;
using thx.Strings;
using thx.Tuple;

@:forward(iterator)
abstract Headers(Array<Header>) from Array<Header> to Array<Header> {
  @:from public static function fromDynamic(object : Dynamic<String>) : Headers
    return object.tuples();

  @:from public static function fromMap(map : Map<String, String>) : Headers
    return map.tuples();

  @:from public static function fromStringMap(map : haxe.ds.StringMap<String>) : Headers
    return map.tuples();

  @:from public static function fromTuples(arr : Array<Tuple2<String, String>>) : Headers
    return arr.map(function(t) return (t : Header));

  @:from public static function fromString(s : String) : Headers {
    if(s == null)
      return empty();

    // TODO this will fail with multiple-line values
    return Const.SPLIT_NL.split(s)
      .map(function(line) return line.trim())
      .filter(function(line) return line != "")
      .map(function(line) {
        var parts = line.split(":"),
            key   = parts.shift(),
            value = parts.join(":").ltrim();
        return Header.create(key, value);
      });
  }

  public static function empty()
    return new Headers([]);

  inline function new(arr : Array<Header>)
    this = arr;

  public function exists(key : String) : Bool {
    key = Header.normalizeKey(key).toLowerCase();
    return this.any(function(h) return h.key.toLowerCase() == key);
  }

  public function get(key : String) : String {
    var p = getHeader(key);
    return p == null ? null : p.value;
  }

  public function remove(key : String) {
    key = Header.normalizeKey(key).toLowerCase();
    var p = this.find(function(h) return h.key.toLowerCase() == key);
    return this.remove(p);
  }

  public function getHeader(key : String) : Header {
    key = Header.normalizeKey(key).toLowerCase();
    return this.find(function(h) return h.key.toLowerCase() == key);
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
    this.map.fn(Reflect.setField(o, _.key, _.value));
    return o;
  }

  public function toString()
    return this.map.fn('${_.key}: ${formatValue(_.value, _.key)}').join("\n");
}
