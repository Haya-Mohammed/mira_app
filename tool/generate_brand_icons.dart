// Run with `dart run tool/generate_brand_icons.dart` after changing the logo.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;

const sourcePath = 'assets/images/logo.png';
final background = img.ColorRgba8(255, 250, 250, 255);

void main() {
  final source = img.decodePng(File(sourcePath).readAsBytesSync());
  if (source == null) throw StateError('Could not decode $sourcePath');

  Uint8List icon(int size, {double fraction = 0.82, bool transparent = false}) {
    final canvas = img.Image(width: size, height: size, numChannels: 4);
    img.fill(
      canvas,
      color: transparent ? img.ColorRgba8(0, 0, 0, 0) : background,
    );
    final side = (size * fraction).round();
    final logo = img.copyResize(
      source,
      width: side,
      interpolation: img.Interpolation.cubic,
    );
    img.compositeImage(canvas, logo, center: true);
    return Uint8List.fromList(img.encodePng(canvas));
  }

  void write(String path, Uint8List bytes) {
    final file = File(path);
    file.parent.createSync(recursive: true);
    file.writeAsBytesSync(bytes);
  }

  const androidSizes = {
    'mdpi': 48,
    'hdpi': 72,
    'xhdpi': 96,
    'xxhdpi': 144,
    'xxxhdpi': 192,
  };
  for (final entry in androidSizes.entries) {
    write(
      'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      icon(entry.value),
    );
  }
  write(
    'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png',
    icon(432, fraction: 0.67, transparent: true),
  );
  write(
    'android/app/src/main/res/drawable/launch_logo.png',
    icon(196, fraction: 0.92, transparent: true),
  );

  final iosDir = 'ios/Runner/Assets.xcassets/AppIcon.appiconset';
  final iosManifest = jsonDecode(
    File('$iosDir/Contents.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  for (final entry in iosManifest['images'] as List<dynamic>) {
    final item = entry as Map<String, dynamic>;
    final filename = item['filename'] as String;
    final points = double.parse((item['size'] as String).split('x').first);
    final scale = double.parse((item['scale'] as String).replaceAll('x', ''));
    write('$iosDir/$filename', icon((points * scale).round()));
  }
  for (final scale in [1, 2, 3]) {
    final suffix = scale == 1 ? '' : '@${scale}x';
    write(
      'ios/Runner/Assets.xcassets/LaunchImage.imageset/LaunchImage$suffix.png',
      icon(168 * scale, fraction: 0.96, transparent: true),
    );
  }

  write('web/icons/Icon-192.png', icon(192));
  write('web/icons/Icon-512.png', icon(512));
  write('web/icons/Icon-maskable-192.png', icon(192, fraction: 0.66));
  write('web/icons/Icon-maskable-512.png', icon(512, fraction: 0.66));
  write('web/favicon.png', icon(48, fraction: 0.9));

  final windowsSizes = [16, 32, 48, 64, 128, 256];
  final images = [for (final size in windowsSizes) icon(size)];
  final builder = BytesBuilder();
  final header = ByteData(6)
    ..setUint16(0, 0, Endian.little)
    ..setUint16(2, 1, Endian.little)
    ..setUint16(4, images.length, Endian.little);
  builder.add(header.buffer.asUint8List());
  var offset = 6 + images.length * 16;
  for (var index = 0; index < images.length; index++) {
    final size = windowsSizes[index];
    final bytes = images[index];
    final entry = ByteData(16)
      ..setUint8(0, size == 256 ? 0 : size)
      ..setUint8(1, size == 256 ? 0 : size)
      ..setUint8(2, 0)
      ..setUint8(3, 0)
      ..setUint16(4, 1, Endian.little)
      ..setUint16(6, 32, Endian.little)
      ..setUint32(8, bytes.length, Endian.little)
      ..setUint32(12, offset, Endian.little);
    builder.add(entry.buffer.asUint8List());
    offset += bytes.length;
  }
  for (final bytes in images) {
    builder.add(bytes);
  }
  write('windows/runner/resources/app_icon.ico', builder.toBytes());
}
