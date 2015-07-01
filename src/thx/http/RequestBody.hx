package thx.http;

import haxe.io.Bytes;
import haxe.io.Input;
import thx.stream.Emitter;

enum RequestBody {
  NoBody;
  BodyString(s : String, ?encoding : String);
  BodyBytes(b : Bytes);
  BodyInput(s : Input);
  BodyStream(e : Emitter<Bytes>);
}
