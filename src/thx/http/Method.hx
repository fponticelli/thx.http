package thx.http;

@:enum abstract Method(String) to String {
	var Get = "get";
	var Post = "post";
	var Put = "put";
	var Delete = "delete";
	// TODO add remaining
}
