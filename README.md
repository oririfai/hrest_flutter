# HRest Flutter (hrest_flutter)

[Benchmark](https://github.com/oririfai/hrest-benchmark) | [Core](https://github.com/oririfai/hrest-core) | [CLI](https://github.com/oririfai/hrest-cli) | [Python](https://github.com/oririfai/hrest-py) | [Node](https://github.com/oririfai/hrest-node) | [Go](https://github.com/oririfai/hrest-go) | [TS](https://github.com/oririfai/hrest-ts)

---

> High-Performance Dart/Flutter Client SDK for the [HRest Binary Protocol](https://github.com/oririfai/hrest-core)

`hrest_flutter` is a highly optimized client SDK for Flutter and Dart. It leverages Dart FFI (Foreign Function Interface) to bind directly to the Rust-powered `hrest-core` engine, achieving zero-parsing overhead and massive bandwidth savings.

It includes a seamless `DioInterceptor` that automatically translates your standard JSON payloads into highly compressed HRest binary formats on the fly!

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  hrest_flutter: ^0.1.0
  dio: ^5.11.0 # Required for the interceptor
```

## Quick Start

### 1. Initialize the SDK

Load the SDK once at the root of your application. This initializes the native Rust engine and reads your generated HRest contract files.

```dart
import 'package:hrest_flutter/hrest_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() async {
  // Load generated contracts (from assets)
  final reqJson = await rootBundle.loadString('assets/hrest-req-contract.json');
  final resJson = await rootBundle.loadString('assets/hrest-res-contract.json');
  
  // Initialize the Stateful FFI Loader
  final loader = HrestLoader(reqJson: reqJson, resJson: resJson);
  
  // Attach to Dio
  final dio = Dio();
  dio.interceptors.add(HrestDioInterceptor(loader: loader));
  
  runApp(MyApp(dio: dio));
}
```

### 2. Make API Calls (Transparently)

Use `Dio` exactly as you normally would. The `HrestDioInterceptor` will automatically intercept the request, encode the outgoing JSON into binary, and decode the incoming binary response back into a normal JSON Map.

```dart
Future<void> runTask(Dio dio) async {
  // Just send a normal JSON map!
  final response = await dio.post('/api/v1/run', data: {
    "event": "click",
    "headless": true,
    "task_id": 42
  });

  // The response is already decoded back to a JSON Map
  print("Success: ${response.data}");
}
```

## Architecture

- **Stateful C-FFI**: Binds natively to `libhrest_core` using Dart `dart:ffi`. The JSON schemas are parsed only once into Rust's heap memory, completely eliminating parsing overhead on every request.
- **Dio Integration**: Follows Clean Architecture by isolating the complex FFI logic inside a simple Presentation-layer Dio Interceptor.
- **Extreme Performance**: HRest FFI is proven to be faster than native JSON parsers while cutting network bandwidth usage by **~50%**.

## License

MIT © 2026 HyperRest Project
