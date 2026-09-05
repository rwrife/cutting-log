import 'dart:io';

import 'package:cutting_log/src/application/media_workflow.dart';
import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/data/in_memory_journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

void main() {
  late Directory root;
  late InMemoryJournalDataRepository repository;
  late _Fixture fixture;
  late _FakePermissionGateway permissions;
  late _FakePhotoImportGateway picker;
  late AppPrivateMediaStore store;
  late MediaWorkflow workflow;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cutting-log-media-test-');
    repository = InMemoryJournalDataRepository();
    fixture = await _seed(repository);
    permissions = _FakePermissionGateway();
    picker = _FakePhotoImportGateway();
    store = AppPrivateMediaStore(root);
    workflow = MediaWorkflow(
      repository: repository,
      permissions: permissions,
      sourceGateway: picker,
      mediaStore: store,
      clock: () => DateTime.utc(2026, 1, 10),
      idFactory: _incrementingId,
    );
  });

  tearDown(() async {
    _counter = 0;
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  });

  test('attaches selected photo to an event and stores local media', () async {
    final source = await _writePng(root, 'selected.png');
    picker.next = PickedPhoto(
      path: source.path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );

    final attachment = await workflow.attachPhotoToEvent(
      eventId: fixture.event.id,
      source: PhotoImportSource.photoLibrary,
      caption: '  Day 2 roots visible  ',
    );

    expect(attachment, isNotNull);
    final assets = await repository.getMediaAssets(fixture.event.id);
    expect(assets, hasLength(1));
    expect(assets.single.caption, 'Day 2 roots visible');
    expect(assets.single.relativePath, startsWith('media/originals/'));
    expect(store.resolve(assets.single.relativePath).existsSync(), isTrue);
    expect(
      store.resolve(workflow.thumbnailRelativePathForAsset(assets.single)).existsSync(),
      isTrue,
    );
  });

  test('permission denial blocks import and stays recoverable', () async {
    permissions.allowPhotos = false;
    picker.next = PickedPhoto(
      path: (await _writePng(root, 'denied.png')).path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );

    expect(
      () => workflow.attachPhotoToEvent(
        eventId: fixture.event.id,
        source: PhotoImportSource.photoLibrary,
      ),
      throwsA(isA<MediaPermissionDeniedException>()),
    );
    expect(picker.callCount, 0);
    expect(await repository.getAllMediaAssets(), isEmpty);
  });

  test('cancelled photo selection leaves timeline unchanged', () async {
    picker.next = null;

    final result = await workflow.attachPhotoToEvent(
      eventId: fixture.event.id,
      source: PhotoImportSource.photoLibrary,
    );

    expect(result, isNull);
    expect(await repository.getAllMediaAssets(), isEmpty);
  });

  test('hash mismatch prevents import and metadata writes', () async {
    final source = await _writePng(root, 'hash.png');
    picker.next = PickedPhoto(
      path: source.path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );

    expect(
      () => workflow.attachPhotoToEvent(
        eventId: fixture.event.id,
        source: PhotoImportSource.photoLibrary,
        expectedSourceSha256: 'bad-hash',
      ),
      throwsA(isA<HashMismatchMediaException>()),
    );

    expect(await repository.getAllMediaAssets(), isEmpty);
    expect((await store.scanInventory()).files, isEmpty);
  });

  test('repository failures roll back copied files', () async {
    final source = await _writePng(root, 'rollback.png');
    picker.next = PickedPhoto(
      path: source.path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );

    expect(
      () => workflow.attachPhotoToEvent(
        eventId: const EntityId('missing-event'),
        source: PhotoImportSource.photoLibrary,
      ),
      throwsA(isA<JournalNotFoundException>()),
    );

    expect((await store.scanInventory()).files, isEmpty);
  });

  test('storage inspection reports missing and orphan files', () async {
    final source = await _writePng(root, 'inspect.png');
    picker.next = PickedPhoto(
      path: source.path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );
    final attachment = await workflow.attachPhotoToEvent(
      eventId: fixture.event.id,
      source: PhotoImportSource.photoLibrary,
    );
    final asset = attachment!.asset;

    await store.deleteManagedPath(workflow.thumbnailRelativePathForAsset(asset));
    await File('${root.path}/media/originals/orphan.jpg').create(recursive: true);

    final report = await workflow.inspectStorage();

    expect(report.assetCount, 1);
    expect(report.missingReferences, hasLength(1));
    expect(report.missingReferences.single.assetId, asset.id);
    expect(report.missingReferences.single.missingOriginal, isFalse);
    expect(report.missingReferences.single.missingThumbnail, isTrue);
    expect(report.orphanedFiles, contains('media/originals/orphan.jpg'));
  });

  test('deleteMediaAsset removes one media asset and files', () async {
    final source = await _writePng(root, 'delete-one.png');
    picker.next = PickedPhoto(
      path: source.path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );
    final attachment = await workflow.attachPhotoToEvent(
      eventId: fixture.event.id,
      source: PhotoImportSource.photoLibrary,
    );
    final asset = attachment!.asset;

    await workflow.deleteMediaAsset(asset.id);

    expect(await repository.getAllMediaAssets(), isEmpty);
    expect(await store.exists(asset.relativePath), isFalse);
    expect(await store.exists(workflow.thumbnailRelativePathForAsset(asset)), isFalse);
  });

  test('clearAllLocalMedia removes tracked and orphan files', () async {
    final source = await _writePng(root, 'delete-all.png');
    picker.next = PickedPhoto(
      path: source.path,
      source: PhotoImportSource.photoLibrary,
      pickedAtUtc: DateTime.utc(2026, 1, 9),
    );
    await workflow.attachPhotoToEvent(
      eventId: fixture.event.id,
      source: PhotoImportSource.photoLibrary,
    );

    await File('${root.path}/media/thumbnails/orphan.jpg').create(recursive: true);
    await workflow.clearAllLocalMedia();

    expect(await repository.getAllMediaAssets(), isEmpty);
    expect((await store.scanInventory()).files, isEmpty);
  });
}

class _FakePermissionGateway implements OptionalPermissionGateway {
  bool allowCamera = true;
  bool allowPhotos = true;

  @override
  Future<bool> request(OptionalPermission permission) async => switch (permission) {
    OptionalPermission.camera => allowCamera,
    OptionalPermission.photos => allowPhotos,
    OptionalPermission.notifications => true,
  };
}

class _FakePhotoImportGateway implements PhotoImportGateway {
  PickedPhoto? next;
  int callCount = 0;

  @override
  Future<PickedPhoto?> pick(PhotoImportSource source) async {
    callCount += 1;
    return next;
  }
}

final class _Fixture {
  const _Fixture({required this.parent, required this.cutting, required this.event});

  final ParentPlant parent;
  final Cutting cutting;
  final CuttingEvent event;
}

Future<_Fixture> _seed(JournalDataRepository repository) async {
  final created = DateTime.utc(2026, 1, 1);
  final parent = ParentPlant(
    id: const EntityId('parent-1'),
    nickname: 'Monstera Mother',
    createdAtUtc: created,
    updatedAtUtc: created,
  );
  await repository.createParentPlant(parent);

  final cutting = Cutting(
    id: const EntityId('cutting-1'),
    parentId: parent.id,
    name: 'Stem A',
    method: 'Stem',
    startedAtUtc: created,
    createdAtUtc: created,
    updatedAtUtc: created,
  );
  final startEvent = CuttingEvent(
    id: const EntityId('event-1'),
    cuttingId: cutting.id,
    occurredAtUtc: created,
    createdAtUtc: created,
    kind: CuttingEventKind.stage,
    stage: CuttingStage.started,
  );
  await repository.createCuttingWithInitialEvent(cutting, startEvent);

  return _Fixture(parent: parent, cutting: cutting, event: startEvent);
}

int _counter = 0;
String _incrementingId() {
  _counter += 1;
  return 'asset-$_counter';
}

Future<File> _writePng(Directory root, String name) async {
  final file = File('${root.path}/$name');
  final image = img.Image(width: 48, height: 48);
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      image.setPixelRgba(x, y, 50, 120 + (x % 40), 180 + (y % 40), 255);
    }
  }
  await file.writeAsBytes(img.encodePng(image), flush: true);
  return file;
}
