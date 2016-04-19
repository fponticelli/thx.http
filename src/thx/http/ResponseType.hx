package thx.http;

import thx.Nil;

enum ResponseType<T> {
  Binary : ResponseType<haxe.io.Bytes>;
  NoBody : ResponseType<Nil>;
  Text : ResponseType<String>;
  Json : ResponseType<Dynamic>;
#if(nodejs || hxnodejs)
  JSBuffer : ResponseType<js.node.Buffer>;
  // TODO NodeJS pipes
#elseif js
  JSArrayBuffer : ResponseType<js.html.ArrayBuffer>;
  JSBlob : ResponseType<js.html.Blob>;
  JSDocument : ResponseType<js.html.HTMLDocument>;
#end
}
