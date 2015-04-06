package thx.http;

import haxe.io.Bytes;
import haxe.io.Output;

enum ResponseBody {
	NoBody;
	BodyString(s : String, ?encoding : String);
	BodyBytes(b : Bytes);
	BodyStream(s : Output);
}
