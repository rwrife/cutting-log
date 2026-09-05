import 'dart:io';
import 'dart:math';

import 'package:cutting_log/src/data/app_private_media_store.dart';
import 'package:cutting_log/src/domain/journal_data_repository.dart';
import 'package:cutting_log/src/domain/journal_entities.dart';
import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:cutting_log/src/platform/photo_import_gateway.dart';

final class MediaPermissionDeniedException implements Exception {
  const MediaPermissionDeniedException(this.permission);

  final OptionalPermission permission;

  @override
  String toString() =>
      'MediaPermissionDeniedException: $permission permission denied';
}

final class MediaAttachment {
  const MediaAttachment({
    required this.asset,
    required this.thumbnailRelativePath,
    required this.originalBytes,
    required this.thumbnailBytes,
  });

  final MediaAsset asset;
  final String thumbnailRelativePath;
  final int originalBytes;
  final int thumbnailBytes;
}

final class MissingMediaReference {
  const MissingMediaReference({
    required this.assetId,
    required this.missingOriginal,
    required this.missingThumbnail,
  });

  final EntityId assetId;
  final bool missingOriginal;
  final bool missingThumbnail;
}

final class MediaStorageReport {
  const MediaStorageReport({
    required this.assetCount,
    required this.trackedBytes,
    required this.missingReferences,
    required this.orphanedFiles,
  });

  final int assetCount;
  final int trackedBytes;
  final List<MissingMediaReference> missingReferences;
  final List<String> orphanedFiles;
}

final class MediaWorkflow {
  MediaWorkflow({
    required JournalDataRepository repository,
    required OptionalPermissionGateway permissions,
    required PhotoImportGateway sourceGateway,
    required OwnedMediaStore mediaStore,
    DateTime Function()? clock,
    String Function()? idFactory,
  }) : _repository = repository,
       _permissions = permissions,
       _sourceGateway = sourceGateway,
       _mediaStore = mediaStore,
       _clock = clock ?? _utcNow,
       _idFactory = idFactory ?? _defaultIdFactory;

  final JournalDataRepository _repository;
  final OptionalPermissionGateway _permissions;
  final PhotoImportGateway _sourceGateway;
  final OwnedMediaStore _mediaStore;
  final DateTime Function() _clock;
  final String Function() _idFactory;

  Future<MediaAttachment?> attachPhotoToEvent({
    required EntityId eventId,
    required PhotoImportSource source,
    String? caption,
    String? expectedSourceSha256,
  }) async {
    final permission = source == PhotoImportSource.camera
        ? OptionalPermission.camera
        : OptionalPermission.photos;
    final granted = await _permissions.request(permission);
    if (!granted) {
      throw MediaPermissionDeniedException(permission);
    }

    final picked = await _sourceGateway.pick(source);
    if (picked == null) {
      return null;
    }

    final assetId = _idFactory();
    final imported = await _mediaStore.importImage(
      assetId: assetId,
      sourcePath: picked.path,
      expectedSourceSha256: expectedSourceSha256,
    );

    final importedAtUtc = _clock().toUtc();
    final asset = MediaAsset(
      id: EntityId(assetId),
      eventId: eventId,
      relativePath: imported.originalRelativePath,
      sha256: imported.sha256,
      mediaType: imported.mediaType,
      caption: _normalizedCaption(caption),
      capturedAtUtc: picked.pickedAtUtc,
      importedAtUtc: importedAtUtc,
    );

    try {
      await _repository.addMediaAsset(asset);
    } catch (_) {
      await _mediaStore.deleteManagedPath(imported.originalRelativePath);
      await _mediaStore.deleteManagedPath(imported.thumbnailRelativePath);
      rethrow;
    }

    return MediaAttachment(
      asset: asset,
      thumbnailRelativePath: imported.thumbnailRelativePath,
      originalBytes: imported.originalBytes,
      thumbnailBytes: imported.thumbnailBytes,
    );
  }

  String thumbnailRelativePathForAsset(MediaAsset asset) =>
      _mediaStore.thumbnailRelativePathForAsset(asset.id.value);

  File originalFileFor(MediaAsset asset) =>
      _mediaStore.resolve(asset.relativePath);

  File thumbnailFileFor(MediaAsset asset) =>
      _mediaStore.resolve(thumbnailRelativePathForAsset(asset));

  Future<MediaStorageReport> inspectStorage() async {
    final assets = await _repository.getAllMediaAssets();
    final inventory = await _mediaStore.scanInventory();
    final inventoryByPath = <String, ManagedMediaFile>{
      for (final file in inventory.files) file.relativePath: file,
    };

    var trackedBytes = 0;
    final expectedPaths = <String>{};
    final missing = <MissingMediaReference>[];

    for (final asset in assets) {
      final thumbnailPath = thumbnailRelativePathForAsset(asset);
      final original = inventoryByPath[asset.relativePath];
      final thumbnail = inventoryByPath[thumbnailPath];
      if (original != null) {
        trackedBytes += original.sizeBytes;
      }
      if (thumbnail != null) {
        trackedBytes += thumbnail.sizeBytes;
      }
      expectedPaths
        ..add(asset.relativePath)
        ..add(thumbnailPath);
      if (original == null || thumbnail == null) {
        missing.add(
          MissingMediaReference(
            assetId: asset.id,
            missingOriginal: original == null,
            missingThumbnail: thumbnail == null,
          ),
        );
      }
    }

    final orphaned =
        inventory.files
            .where((file) => !expectedPaths.contains(file.relativePath))
            .map((file) => file.relativePath)
            .toList(growable: false)
          ..sort();

    return MediaStorageReport(
      assetCount: assets.length,
      trackedBytes: trackedBytes,
      missingReferences: missing,
      orphanedFiles: orphaned,
    );
  }

  Future<void> deleteMediaAsset(EntityId assetId) async {
    final asset = await _repository.getMediaAsset(assetId);
    if (asset == null) {
      return;
    }
    await _repository.removeMediaAsset(asset.id);
    await _mediaStore.deleteManagedPath(asset.relativePath);
    await _mediaStore.deleteManagedPath(thumbnailRelativePathForAsset(asset));
  }

  Future<void> clearAllLocalMedia() async {
    final assets = await _repository.getAllMediaAssets();
    for (final asset in assets) {
      await _mediaStore.deleteManagedPath(asset.relativePath);
      await _mediaStore.deleteManagedPath(thumbnailRelativePathForAsset(asset));
    }

    final inventory = await _mediaStore.scanInventory();
    for (final file in inventory.files) {
      await _mediaStore.deleteManagedPath(file.relativePath);
    }

    await _repository.removeAllMediaAssets();
  }

  static DateTime _utcNow() => DateTime.now().toUtc();

  static String _defaultIdFactory() {
    final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
    final suffix = _random.nextInt(1 << 32).toRadixString(16).padLeft(8, '0');
    return 'media-$timestamp-$suffix';
  }

  static final Random _random = Random.secure();

  static String _normalizedCaption(String? caption) {
    if (caption == null) {
      return '';
    }
    final trimmed = caption.trim();
    return trimmed;
  }
}
