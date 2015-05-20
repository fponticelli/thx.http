package thx.http;

import thx.stream.Emitter;
import haxe.io.Bytes;

interface Response {
	public var statusCode(get, null) : Int;
	public var statusText(get, null) : String;
	public var headers(get, null) : Headers;
	public var emitter(get, null) : Emitter<Bytes>;
	//public function cancel() : Void;
}
