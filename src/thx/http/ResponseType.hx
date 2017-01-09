package thx.http;

import thx.Nil;
import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.Input;

enum ResponseType<T> {
  Binary : ResponseType<Bytes>;
  NoBody : ResponseType<Nil>;
  Text : ResponseType<String>;
  Json : ResponseType<Dynamic>;
  Input : ResponseType<Input>;
#if(nodejs || hxnodejs)
  JSBuffer : ResponseType<js.node.Buffer>;
  // TODO NodeJS: Stream of String with and without encoding
  // TODO NodeJS pipes
#elseif js
  JSArrayBuffer : ResponseType<js.html.ArrayBuffer>;
  JSBlob : ResponseType<js.html.Blob>;
  JSDocument : ResponseType<js.html.HTMLDocument>;
#end
}
