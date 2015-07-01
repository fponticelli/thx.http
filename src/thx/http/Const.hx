package thx.http;

class Const {
  public static inline var CRLF = "\r\n";
  public static var NL = ~/\r\n|\n\r|\n|\r/;
  public static var SPLIT_NL = ~/\r\n|\n\r|\n|\r/g;
  public static var NL2 = ~/(\r\n|\n\r|\n|\r){2}/;
  public static var WS = ~/(\s+)/g;
}
