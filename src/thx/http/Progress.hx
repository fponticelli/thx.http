package thx.http;

enum Progress {
  Uncomputable;
  Step(done : Float, total : Float);
}
