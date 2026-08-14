import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../application/hrest_loader.dart';

/// Dio Interceptor that automatically encodes/decodes HRest payloads.
/// It seamlessly integrates with Dio so developers can continue using JSON in their code.
class HrestInterceptor extends Interceptor {
  final HrestLoader loader;
  final bool enableDebugLog;

  HrestInterceptor({
    required this.loader,
    this.enableDebugLog = false,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.data != null && options.data is Map<String, dynamic>) {
      try {
        final route = "${options.method.toUpperCase()} ${options.path}";
        
        // Convert the JSON map to a JSON string, then let WASM/FFI encode it to binary
        final jsonString = jsonEncode(options.data);
        final binaryPayload = loader.encode(route, jsonString);

        if (enableDebugLog) {
          print("[HRest] Encoded payload for $route: ${jsonString.length} bytes -> ${binaryPayload.length} bytes");
        }

        // Replace the body with the binary buffer and set content type
        options.data = binaryPayload;
        options.headers['Content-Type'] = 'application/hrest';
        options.headers['Accept'] = 'application/hrest';
      } catch (e) {
        if (enableDebugLog) print("[HRest] Encoding Error: $e");
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.headers.value('Content-Type')?.contains('application/hrest') == true ||
        response.data is List<int>) {
      try {
        final route = "${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path}";
        
        // Ensure data is Uint8List
        Uint8List binaryData;
        if (response.data is Uint8List) {
          binaryData = response.data;
        } else if (response.data is List<int>) {
          binaryData = Uint8List.fromList(response.data);
        } else {
          return super.onResponse(response, handler);
        }

        // Decode the binary buffer back to JSON string
        final jsonString = loader.decode(route, binaryData);
        
        // Parse the JSON string back to Map<String, dynamic> for the developer
        response.data = jsonDecode(jsonString);

        if (enableDebugLog) {
          print("[HRest] Decoded payload for $route: ${binaryData.length} bytes -> ${jsonString.length} bytes");
        }
      } catch (e) {
        if (enableDebugLog) print("[HRest] Decoding Error: $e");
      }
    }
    super.onResponse(response, handler);
  }
}
