package thx.http;

import thx.Nil;

enum ResponseType<T> {
  ResponseTypeBytes : ResponseType<haxe.io.Bytes>;
  ResponseTypeNoBody : ResponseType<Nil>;
  ResponseTypeText : ResponseType<String>;
  ResponseTypeJson : ResponseType<Dynamic>;
#if(nodejs || hxnodejs)
  ResponseTypeJSBuffer : ResponseType<js.node.Buffer>;
  // TODO NodeJS pipes
#elseif js
  ResponseTypeArrayBuffer : ResponseType<js.html.ArrayBuffer>;
  ResponseTypeBlob : ResponseType<js.html.Blob>;
  ResponseTypeDocument : ResponseType<js.html.HTMLDocument>;
#end
}
