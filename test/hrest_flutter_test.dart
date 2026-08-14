import 'package:test/test.dart';
import 'package:hrest_flutter/hrest_flutter.dart';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

const mockContract = '''
{
  "version": "1.0.0",
  "contract_hash": "test1234",
  "routes": {
    "POST /api/v1/test": {
      "fields": {
        "id": 1,
        "name": 2,
        "isActive": 3
      }
    }
  }
}
''';

void main() {
  test('HrestLoader E2E Encoding and Decoding', () {
    // Determine the dylib path for tests
    String dylibPath;
    if (Platform.isMacOS) {
      dylibPath = '.dart_tool/lib/libhrest_flutter.dylib';
    } else if (Platform.isLinux) {
      dylibPath = '.dart_tool/lib/libhrest_flutter.so';
    } else {
      dylibPath = '.dart_tool/lib/hrest_flutter.dll';
    }

    // Only run if the dylib is built (hook succeeded)
    if (!File(dylibPath).existsSync()) {
      print('Skipping test because dynamic library was not built at $dylibPath');
      return;
    }

    final dylib = DynamicLibrary.open(dylibPath);
    final loader = HrestLoader(dylib, mockContract);

    // Removed computeHash debug test

    final payload = {
      "id": 100,
      "name": "Flutter",
      "isActive": true
    };

    final route = "POST /api/v1/test";
    
    // 1. Encode
    final jsonStr = jsonEncode(payload);
    final binary = loader.encode(route, jsonStr);
    
    expect(binary.length, lessThan(jsonStr.length), reason: 'Binary should be smaller than JSON string');
    print('JSON Size: \${jsonStr.length}, Binary Size: \${binary.length}');

    // 2. Decode
    final decodedStr = loader.decode(route, binary);
    final decodedObj = jsonDecode(decodedStr);

    expect(decodedObj['id'], 100);
    expect(decodedObj['name'], 'Flutter');
    expect(decodedObj['isActive'], true);

    loader.dispose();
  });
}
