library hrest_flutter;

import 'dart:ffi';
import 'dart:io';

import 'src/application/hrest_loader.dart';

export 'src/application/hrest_loader.dart';
export 'src/presentation/dio_interceptor.dart';

const String _libName = 'hrest_flutter';

/// The dynamic library in which the symbols for [HrestLoader] can be found.
final DynamicLibrary hrestDylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.executable();
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// Create a new HRest Loader for the application.
HrestLoader createHrestLoader(String contractJson) {
  return HrestLoader(hrestDylib, contractJson);
}
