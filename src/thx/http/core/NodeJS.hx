package thx.http.core;

import js.html.ArrayBuffer;
import js.node.Buffer;
import haxe.io.Bytes;

class NodeJS {

  public static function bufferToArrayBuffer(buf : Buffer) : ArrayBuffer {
    var ab = new ArrayBuffer(buf.length);
    var view = new js.html.Uint8Array(ab);
    for(i in 0...buf.length)
      view[i] = buf[i];
    return ab;
  }

  // static function arrayBufferToString(ab : ArrayBuffer) : String {
  //   return (untyped __js__("String")).fromCharCode.apply(null, new js.html.Uint16Array(ab));
  // }
  //

  public static function bufferToBytes(buf : Buffer) : Bytes {
    var ab = bufferToArrayBuffer(buf);
    return Bytes.ofData(ab);
  }

  public static function arrayBufferToBuffer(ab : ArrayBuffer) : Buffer {
    var buffer = new Buffer(ab.byteLength);
    var view = new js.html.Uint8Array(ab);
    for(i in 0...buffer.length)
      buffer[i] = view[i];
    return buffer;
  }
}
