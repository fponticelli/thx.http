package thx.http;

@:enum abstract Method(String) to String {
	var Get = "GET";
	var Post = "POST";
	var Put = "PUT";
	var Delete = "DELETE";
	// TODO add remaining
}
