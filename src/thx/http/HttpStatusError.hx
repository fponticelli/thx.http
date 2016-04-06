package thx.http;

class HttpStatusError extends thx.Error {
  var statusCode(default, null) : Int;
  var statusText(default, null) : String;
  public function new(statusCode : Int, ?statusText : String, ?pos : haxe.PosInfos) {
    this.statusCode = statusCode;
    if(null == statusText)
      statusText = Response.statusCodes.get(statusCode);
    this.statusText = statusText;
    super('$statusCode: $statusText', pos);
  }
}
