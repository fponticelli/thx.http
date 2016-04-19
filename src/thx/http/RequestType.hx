package thx.http;

import haxe.io.Bytes;
import haxe.io.Input;
#if thx_stream
import thx.stream.Emitter;
#end

abstract RequestType(RequestTypeImpl) from RequestTypeImpl to RequestTypeImpl {
  @:from inline public static function fromString(s : String) : RequestType
    return BodyString(s);

  inline public static function fromStringWithEncoding(s : String, encoding : String) : RequestType
    return BodyString(s, encoding);

  @:from inline public static function fromBytes(b : Bytes) : RequestType
    return BodyBytes(b);

  @:from inline public static function fromInput(i : Input) : RequestType
    return BodyInput(i);
#if thx_stream
  @:from inline public static function fromStream(s : Emitter<Bytes>) : RequestType
    return BodyStream(s);
#end
#if(nodejs || hxnodejs)
  @:from inline public static function fromJSBuffer(buffer : js.node.Buffer) : RequestType
    return BodyJSBuffer(buffer);
#elseif js
  @:from inline public static function fromJSArrayBufferView(buffer : js.html.ArrayBufferView) : RequestType
    return BodyJSArrayBufferView(buffer);
  @:from inline public static function fromJSBlob(blob : js.html.Blob) : RequestType
    return BodyJSBlob(blob);
  @:from inline public static function fromJSDocument(doc : js.html.HTMLDocument) : RequestType
    return BodyJSDocument(doc);
  @:from inline public static function fromJSFormData(formData : js.html.FormData) : RequestType
    return BodyJSFormData(formData);
#end


  public static var noBody(default, null) : RequestType = NoBody;
}

enum RequestTypeImpl {
  // TODO JSON
  NoBody;
  BodyString(s : String, ?encoding : String);
  BodyBytes(b : Bytes);
  BodyInput(s : Input);
#if thx_stream
  BodyStream(e : Emitter<Bytes>); // TODO NodeJS: Stream of String with and without encoding
#end
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
