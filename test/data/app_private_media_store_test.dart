import 'dart:io';

import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory root;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cutting-log-store-test-');
  });

  tearDown(() async {
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('imports image into app-private originals and thumbnails', () async {
    final source = await _writePng(root, 'source.png');
    final store = AppPrivateMediaStore(root);

    final imported = await store.importImage(
      assetId: 'asset-1',
      sourcePath: source.path,
    );

    expect(imported.mediaType, 'image/png');
    expect(imported.sha256, hasLength(64));
    expect(await store.exists(imported.originalRelativePath), isTrue);
    expect(await store.exists(imported.thumbnailRelativePath), isTrue);

    final inventory = await store.scanInventory();
    expect(inventory.files.map((file) => file.relativePath), hasLength(2));
  });

  test('rejects unsupported source formats', () async {
    final source = File('${root.path}/bad.txt')..writeAsStringSync('nope');
    final store = AppPrivateMediaStore(root);

    expect(
      () => store.importImage(assetId: 'asset-2', sourcePath: source.path),
      throwsA(isA<UnsupportedMediaException>()),
    );
  });

  test('rejects oversized images from policy limits', () async {
    final source = await _writePng(root, 'large.png', width: 128, height: 128);
    final store = AppPrivateMediaStore(
      root,
      policy: const MediaImportPolicy(maxSourceBytes: 512),
    );

    expect(
      () => store.importImage(assetId: 'asset-3', sourcePath: source.path),
      throwsA(isA<OversizedMediaException>()),
    );
  });

  test('rejects malformed images and leaves no managed files', () async {
    final source = File('${root.path}/bad.jpg')
      ..writeAsBytesSync(<int>[0xFF, 0xD8, 0x00, 0x01, 0x02]);
    final store = AppPrivateMediaStore(root);

    expect(
      () => store.importImage(assetId: 'asset-4', sourcePath: source.path),
      throwsA(isA<MalformedMediaException>()),
    );

    final inventory = await store.scanInventory();
    expect(inventory.files, isEmpty);
  });

  test('fails hash verification when expected hash does not match source', () async {
    final source = await _writePng(root, 'hash.png');
    final store = AppPrivateMediaStore(root);

    expect(
      () => store.importImage(
        assetId: 'asset-5',
        sourcePath: source.path,
        expectedSourceSha256: 'deadbeef',
      ),
      throwsA(isA<HashMismatchMediaException>()),
    );
  });

  test('cleans staging files when finalization is interrupted', () async {
    final source = await _writePng(root, 'interrupt.png');
    final store = AppPrivateMediaStore(
      root,
      beforeFinalizeHook: () => throw StateError('disk full'),
    );

    expect(
      () => store.importImage(assetId: 'asset-6', sourcePath: source.path),
      throwsA(isA<StateError>()),
    );

    final staging = Directory('${root.path}/${AppPrivateMediaStore.stagingDir}');
    if (await staging.exists()) {
      expect(await staging.list().isEmpty, isTrue);
    }
    final inventory = await store.scanInventory();
    expect(inventory.files, isEmpty);
  });
}

Future<File> _writePng(
  Directory root,
  String name, {
  int width = 24,
  int height = 24,
}) async {
  final file = File('${root.path}/$name');
  final image = img.Image(width: width, height: height);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgba(x, y, 32 + (x % 200), 100 + (y % 120), 150, 255);
    }
  }
  await file.writeAsBytes(img.encodePng(image), flush: true);
  return file;
}
