import 'dart:ffi';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import '../infrastructure/ffi_wrapper.dart';

/// HRestLoader represents a stateful parser for the HRest Contract.
/// It parses the contract JSON once during initialization, making encoding and decoding operations extremely fast.
class HrestLoader {
  final HrestFFI ffi;
  final String contractJson;
  late final Pointer<Void> _loaderPtr;

  HrestLoader(DynamicLibrary dylib, this.contractJson) : ffi = HrestFFI(dylib) {
    final contractPtr = contractJson.toNativeUtf8();
    _loaderPtr = ffi.hrestLoaderNew(contractPtr);
    malloc.free(contractPtr);

    if (_loaderPtr == nullptr) {
      throw Exception("HRest Initialization Error: Failed to parse contract schema in Rust.");
    }
  }

  /// Disposes the native memory. Must be called when the loader is no longer needed.
  void dispose() {
    ffi.hrestLoaderFree(_loaderPtr);
  }

  /// Encodes a JSON string payload into a binary HRest TLV buffer.
  Uint8List encode(String route, String jsonPayload) {
    final routePtr = route.toNativeUtf8();
    final jsonPtr = jsonPayload.toNativeUtf8();
    final outLenPtr = malloc<IntPtr>();

    try {
      final bytesPtr = ffi.hrestLoaderEncode(_loaderPtr, routePtr, jsonPtr, outLenPtr);
      
      if (bytesPtr == nullptr) {
        throw Exception("HRest FFI Error: Failed to encode payload.");
      }

      final len = outLenPtr.value;
      // Copy bytes to a Dart Uint8List so we can free the native memory safely
      final dartBytes = Uint8List.fromList(bytesPtr.asTypedList(len));
      
      ffi.hrestFreeBytes(bytesPtr, len);
      return dartBytes;
    } finally {
      malloc.free(routePtr);
      malloc.free(jsonPtr);
      malloc.free(outLenPtr);
    }
  }

  /// Decodes a binary HRest TLV buffer into a JSON string.
  String decode(String route, Uint8List binaryPayload) {
    final routePtr = route.toNativeUtf8();
    
    // Allocate memory for the incoming binary payload
    final bytesPtr = malloc<Uint8>(binaryPayload.length);
    final bytesList = bytesPtr.asTypedList(binaryPayload.length);
    bytesList.setAll(0, binaryPayload);

    try {
      final jsonStrPtr = ffi.hrestLoaderDecode(_loaderPtr, routePtr, bytesPtr, binaryPayload.length);
      
      if (jsonStrPtr == nullptr) {
        throw Exception("HRest FFI Error: Failed to decode binary payload.");
      }

      final jsonStr = jsonStrPtr.toDartString();
      ffi.hrestFreeStr(jsonStrPtr);
      
      return jsonStr;
    } finally {
      malloc.free(routePtr);
      malloc.free(bytesPtr);
    }
  }

  /// Verifies the hash of the contract
  bool verifyHash(String clientHash) {
    final hashPtr = clientHash.toNativeUtf8();
    try {
      return ffi.hrestLoaderVerifyHash(_loaderPtr, hashPtr) == 1;
    } finally {
      malloc.free(hashPtr);
    }
  }
}
