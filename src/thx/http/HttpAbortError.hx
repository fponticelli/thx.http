package thx.http;

class HttpAbortError extends thx.Error {
  public function new(url : Url, ?pos : haxe.PosInfos) {
    super('user aborted connection to $url', pos);
  }
}
