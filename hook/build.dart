import 'package:native_toolchain_rust/native_toolchain_rust.dart';
import 'package:logging/logging.dart';
import 'package:hooks/hooks.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    final packageName = input.packageName;
    final builder = RustBuilder(
      assetName: 'src/${packageName}_bindings_generated.dart',
      cratePath: 'src',
    );
    await builder.run(
      input: input,
      output: output,
      logger: Logger('')
        ..level = Level.ALL
        ..onRecord.listen((record) => print(record.message)),
    );
  });
}
