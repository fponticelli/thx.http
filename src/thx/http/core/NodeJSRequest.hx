package thx.http.core;

import js.node.Http;
import js.node.Https;

class NodeJSRequest {
	public static function make(requestInfo : RequestInfo, requestHandler : RequestHandler) : Void -> Void {
		var url = requestInfo.url,
				req = switch url.protocol {
					case "http":
						Http.request({
							hostname: url.hostName,
							port: url.port,
							//localAddress: Local interface to bind for network connections.
							//socketPath: Unix Domain Socket (use one of host:port or socketPath)
							method: (requestInfo.method : String),
							path: url.path,
							headers: requestInfo.headers.toObject()
							//auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
							//agent: Controls Agent behavior. When an Agent is used request will default to Connection: keep-alive. Possible values:
							//keepAlive: {Boolean} Keep sockets around in a pool to be used by other requests in the future. Default = false
							//keepAliveMsecs: {Integer} When using HTTP KeepAlive, how often to send TCP KeepAlive packets over sockets being kept alive. Default = 1000. Only relevant if keepAlive is set to true.
						}, function(res) {
							requestHandler.statusHandler(res.statusCode);
						});
					case "https":
						Https.request({
							hostname: url.hostName,
							port: url.port,
							//localAddress: Local interface to bind for network connections.
							//socketPath: Unix Domain Socket (use one of host:port or socketPath)
							method: (requestInfo.method : String),
							path: url.path,
							headers: requestInfo.headers.toObject()
							//auth: Basic authentication i.e. 'user:password' to compute an Authorization header.
							//agent: Controls Agent behavior. When an Agent is used request will default to Connection: keep-alive. Possible values:
							//keepAlive: {Boolean} Keep sockets around in a pool to be used by other requests in the future. Default = false
							//keepAliveMsecs: {Integer} When using HTTP KeepAlive, how often to send TCP KeepAlive packets over sockets being kept alive. Default = 1000. Only relevant if keepAlive is set to true.
						}, function(res) {
							requestHandler.statusHandler(res.statusCode);
						});
					case other:
						throw 'unexpected protocol $other';
				}
		req.end();
		return req.abort;
	}
}
