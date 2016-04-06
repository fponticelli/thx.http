package thx.http;

import haxe.io.Bytes;
import haxe.io.Input;
import thx.stream.Emitter;

abstract RequestBody(RequestBodyImpl) from RequestBodyImpl to RequestBodyImpl {
  @:from inline public static function fromString(s : String) : RequestBody
    return BodyString(s);

  inline public static function fromStringWithEncoding(s : String, encoding : String) : RequestBody
    return BodyString(s, encoding);

  @:from inline public static function fromBytes(b : Bytes) : RequestBody
    return BodyBytes(b);

  @:from inline public static function fromInput(i : Input) : RequestBody
    return BodyInput(i);

  @:from inline public static function fromStream(s : Emitter<Bytes>) : RequestBody
    return BodyStream(s);

#if(nodejs || hxnodejs)
  @:from inline public static function fromJSBuffer(buffer : js.node.Buffer) : RequestBody
    return BodyJSBuffer(buffer);
#elseif js
  @:from inline public static function fromJSArrayBufferView(buffer : js.html.ArrayBufferView) : RequestBody
    return BodyJSArrayBufferView(buffer);
  @:from inline public static function fromJSBlob(blob : js.html.Blob) : RequestBody
    return BodyJSBlob(blob);
  @:from inline public static function fromJSDocument(doc : js.html.HTMLDocument) : RequestBody
    return BodyJSDocument(doc);
  @:from inline public static function fromJSFormData(formData : js.html.FormData) : RequestBody
    return BodyJSFormData(formData);
#end


  public static var noBody(default, null) : RequestBody = NoBody;
}

enum RequestBodyImpl {
  // TODO JSON
  NoBody;
  BodyString(s : String, ?encoding : String);
  BodyBytes(b : Bytes);
  BodyInput(s : Input);
  BodyStream(e : Emitter<Bytes>); // TODO NodeJS: Stream of String with and without encoding
#if(nodejs || hxnodejs)
  BodyJSBuffer(buffer : js.node.Buffer);
  // TODO NodeJS pipes
#elseif js
  BodyJSArrayBufferView(buffer : js.html.ArrayBufferView);
  BodyJSBlob(blob : js.html.Blob);
  BodyJSDocument(doc : js.html.HTMLDocument);
  BodyJSFormData(formData : js.html.FormData);
#end
}
