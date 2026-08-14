import 'dart:ffi';
import 'package:ffi/ffi.dart';

// ignore_for_file: camel_case_types

/// The Dart representation of the Rust FFI bindings.
class HrestFFI {
  final DynamicLibrary _dylib;

  HrestFFI(this._dylib);

  // ---------------------------------------------------------------------------
  // Stateful Loader FFI
  // ---------------------------------------------------------------------------

  /// Create a new stateful HrestLoader instance.
  Pointer<Void> hrestLoaderNew(Pointer<Utf8> contractJson) {
    final func = _dylib.lookupFunction<
        Pointer<Void> Function(Pointer<Utf8>),
        Pointer<Void> Function(Pointer<Utf8>)
    >('hrest_loader_new');
    return func(contractJson);
  }

  /// Free the stateful HrestLoader instance.
  void hrestLoaderFree(Pointer<Void> loaderPtr) {
    final func = _dylib.lookupFunction<
        Void Function(Pointer<Void>),
        void Function(Pointer<Void>)
    >('hrest_loader_free');
    func(loaderPtr);
  }

  /// Encode a JSON payload using a stateful loader.
  Pointer<Uint8> hrestLoaderEncode(Pointer<Void> loaderPtr, Pointer<Utf8> route, Pointer<Utf8> json, Pointer<IntPtr> outLen) {
    final func = _dylib.lookupFunction<
        Pointer<Uint8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Pointer<IntPtr>),
        Pointer<Uint8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Utf8>, Pointer<IntPtr>)
    >('hrest_loader_encode');
    return func(loaderPtr, route, json, outLen);
  }

  /// Decode a binary HRest TLV buffer using a stateful loader.
  Pointer<Utf8> hrestLoaderDecode(Pointer<Void> loaderPtr, Pointer<Utf8> route, Pointer<Uint8> bytes, int bytesLen) {
    final func = _dylib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Uint8>, IntPtr),
        Pointer<Utf8> Function(Pointer<Void>, Pointer<Utf8>, Pointer<Uint8>, int)
    >('hrest_loader_decode');
    return func(loaderPtr, route, bytes, bytesLen);
  }

  /// Verify hash using a stateful loader.
  int hrestLoaderVerifyHash(Pointer<Void> loaderPtr, Pointer<Utf8> clientHash) {
    final func = _dylib.lookupFunction<
        Int32 Function(Pointer<Void>, Pointer<Utf8>),
        int Function(Pointer<Void>, Pointer<Utf8>)
    >('hrest_loader_verify_hash');
    return func(loaderPtr, clientHash);
  }

  // ---------------------------------------------------------------------------
  // Legacy / Stateless FFI
  // ---------------------------------------------------------------------------

  /// Encode a JSON payload to a binary HRest TLV buffer.
  Pointer<Uint8> hrestEncode(Pointer<Utf8> route, Pointer<Utf8> json, Pointer<Utf8> contractJson, Pointer<IntPtr> outLen) {
    final func = _dylib.lookupFunction<
        Pointer<Uint8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<IntPtr>),
        Pointer<Uint8> Function(Pointer<Utf8>, Pointer<Utf8>, Pointer<Utf8>, Pointer<IntPtr>)
    >('hrest_encode');
    return func(route, json, contractJson, outLen);
  }

  /// Decode a binary HRest TLV buffer to a JSON string.
  Pointer<Utf8> hrestDecode(Pointer<Utf8> route, Pointer<Uint8> bytes, int bytesLen, Pointer<Utf8> contractJson) {
    final func = _dylib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Uint8>, IntPtr, Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<Utf8>, Pointer<Uint8>, int, Pointer<Utf8>)
    >('hrest_decode');
    return func(route, bytes, bytesLen, contractJson);
  }

  /// Verify that a client-provided hash matches the contract's stored hash.
  int hrestVerifyHash(Pointer<Utf8> contractJson, Pointer<Utf8> clientHash) {
    final func = _dylib.lookupFunction<
        Int32 Function(Pointer<Utf8>, Pointer<Utf8>),
        int Function(Pointer<Utf8>, Pointer<Utf8>)
    >('hrest_verify_hash');
    return func(contractJson, clientHash);
  }

  /// Compute the SHA-256 hash of a contract JSON string.
  Pointer<Utf8> hrestComputeHash(Pointer<Utf8> contractJson) {
    final func = _dylib.lookupFunction<
        Pointer<Utf8> Function(Pointer<Utf8>),
        Pointer<Utf8> Function(Pointer<Utf8>)
    >('hrest_compute_hash');
    return func(contractJson);
  }

  /// Free a byte buffer allocated by `hrest_encode`.
  void hrestFreeBytes(Pointer<Uint8> ptr, int len) {
    final func = _dylib.lookupFunction<
        Void Function(Pointer<Uint8>, IntPtr),
        void Function(Pointer<Uint8>, int)
    >('hrest_free_bytes');
    func(ptr, len);
  }

  /// Free a C string allocated by `hrest_decode` or `hrest_compute_hash`.
  void hrestFreeStr(Pointer<Utf8> ptr) {
    final func = _dylib.lookupFunction<
        Void Function(Pointer<Utf8>),
        void Function(Pointer<Utf8>)
    >('hrest_free_str');
    func(ptr);
  }
}
