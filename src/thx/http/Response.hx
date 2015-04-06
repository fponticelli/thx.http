package thx.http;

interface Response {
	public var body(get, null) : ResponseBody;
	public var statusCode(get, null) : Int;
	public var statusText(get, null) : String;
	public var headers(get, null) : Headers;
}
