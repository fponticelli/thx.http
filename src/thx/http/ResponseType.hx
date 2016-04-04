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
    // ResponseTypeArrayBufferView(buffer : js.html.ArrayBufferView); // TODO or ArrayBuffer
    // ResponseTypeBlob(blob : js.html.Blob);
    // ResponseTypeDocument(doc : js.html.Document); // TODO Document or HTMLDocument
    // ResponseTypeFormData(formData : js.html.FormData);
#end
}
