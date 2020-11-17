import 'dart:math';

//Formatting function taken from https://gist.github.com/zzpmaster/ec51afdbbfa5b2bf6ced13374ff891d9
//@author: zzpmaster

String formatBytes(int bytes, int decimals) {
  if (bytes <= 0) return "0 B";
  const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
}
