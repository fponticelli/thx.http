package thx.http;

@:enum abstract Method(String) from String to String {
  var Connect = "CONNECT";
  var Delete = "DELETE";
  var Get = "GET";
  var Head = "HEAD";
  var Options = "OPTIONS";
  var Patch = "PATCH";
  var Post = "POST";
  var Put = "PUT";
  var Trace = "TRACE";
}
