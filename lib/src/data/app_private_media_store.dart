import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as path;

final class MediaImportPolicy {
  const MediaImportPolicy({
    this.maxSourceBytes = 12 * 1024 * 1024,
    this.maxImageDimension = 4096,
    this.thumbnailMaxEdge = 512,
    this.jpegQuality = 90,
    this.thumbnailJpegQuality = 82,
  });

  final int maxSourceBytes;
  final int maxImageDimension;
  final int thumbnailMaxEdge;
  final int jpegQuality;
  final int thumbnailJpegQuality;
}

class MediaImportException implements Exception {
  const MediaImportException(this.message);

  final String message;

  @override
  String toString() => 'MediaImportException: $message';
}

final class OversizedMediaException extends MediaImportException {
  const OversizedMediaException(String message) : super(message);
}

final class UnsupportedMediaException extends MediaImportException {
  const UnsupportedMediaException(String message) : super(message);
}

final class MalformedMediaException extends MediaImportException {
  const MalformedMediaException(String message) : super(message);
}

final class HashMismatchMediaException extends MediaImportException {
  const HashMismatchMediaException(String message) : super(message);
}

final class ImportedOwnedMedia {
  const ImportedOwnedMedia({
    required this.originalRelativePath,
    required this.thumbnailRelativePath,
    required this.mediaType,
    required this.sha256,
    required this.originalBytes,
    required this.thumbnailBytes,
    required this.width,
    required this.height,
  });

  final String originalRelativePath;
  final String thumbnailRelativePath;
  final String mediaType;
  final String sha256;
  final int originalBytes;
  final int thumbnailBytes;
  final int width;
  final int height;
}

final class ManagedMediaFile {
  const ManagedMediaFile({required this.relativePath, required this.sizeBytes});

  final String relativePath;
  final int sizeBytes;
}

final class ManagedMediaInventory {
  const ManagedMediaInventory(this.files);

  final List<ManagedMediaFile> files;

  int get totalBytes => files.fold<int>(0, (sum, file) => sum + file.sizeBytes);
}

abstract interface class OwnedMediaStore {
  Future<ImportedOwnedMedia> importImage({
    required String assetId,
    required String sourcePath,
    String? expectedSourceSha256,
  });

  String thumbnailRelativePathForAsset(String assetId);

  File resolve(String relativePath);

  Future<bool> exists(String relativePath);

  Future<void> deleteManagedPath(String relativePath);

  Future<ManagedMediaInventory> scanInventory();
}

final class AppPrivateMediaStore implements OwnedMediaStore {
  AppPrivateMediaStore(
    this._rootDirectory, {
    this.policy = const MediaImportPolicy(),
    void Function()? beforeFinalizeHook,
  }) : _beforeFinalizeHook = beforeFinalizeHook;

  static const String mediaRoot = 'media';
  static const String originalsDir = 'media/originals';
  static const String thumbnailsDir = 'media/thumbnails';
  static const String stagingDir = 'media/staging';

  final Directory _rootDirectory;
  final MediaImportPolicy policy;
  final void Function()? _beforeFinalizeHook;

  @override
  Future<ImportedOwnedMedia> importImage({
    required String assetId,
    required String sourcePath,
    String? expectedSourceSha256,
  }) async {
    await _ensureDirectories();
    final sourceFile = File(sourcePath);
    if (!await sourceFile.exists()) {
      throw MediaImportException('source image does not exist');
    }
    final sourceBytes = await sourceFile.readAsBytes();
    if (sourceBytes.length > policy.maxSourceBytes) {
      throw OversizedMediaException(
        'image is larger than ${policy.maxSourceBytes} bytes',
      );
    }
    if (expectedSourceSha256 != null) {
      final sourceHash = sha256.convert(sourceBytes).toString();
      if (sourceHash != expectedSourceSha256) {
        throw const HashMismatchMediaException('source hash mismatch');
      }
    }

    final format = _detectSourceFormat(sourceBytes, sourcePath);
    final decoded = img.decodeImage(sourceBytes);
    if (decoded == null) {
      throw const MalformedMediaException('failed to decode image');
    }
    if (decoded.width > policy.maxImageDimension ||
        decoded.height > policy.maxImageDimension) {
      throw OversizedMediaException(
        'image dimensions exceed ${policy.maxImageDimension}px',
      );
    }

    final normalized = _SanitizedImage(img.bakeOrientation(decoded));
    final originalBytes = _encode(normalized, format);
    final thumbnailBytes = _encodeThumbnail(normalized);

    final mediaHash = sha256.convert(originalBytes).toString();
    final originalRelativePath =
        '$originalsDir/$assetId.${format.fileExtension}';
    final thumbnailRelativePath = thumbnailRelativePathForAsset(assetId);

    final stagedOriginal = resolve('$stagingDir/$assetId-original.tmp');
    final stagedThumbnail = resolve('$stagingDir/$assetId-thumb.tmp');
    final finalOriginal = resolve(originalRelativePath);
    final finalThumbnail = resolve(thumbnailRelativePath);

    var originalFinalized = false;
    try {
      if (await finalOriginal.exists() || await finalThumbnail.exists()) {
        throw const MediaImportException('asset paths already exist');
      }
      await stagedOriginal.writeAsBytes(originalBytes, flush: true);
      await stagedThumbnail.writeAsBytes(thumbnailBytes, flush: true);
      _beforeFinalizeHook?.call();

      await stagedOriginal.rename(finalOriginal.path);
      originalFinalized = true;
      await stagedThumbnail.rename(finalThumbnail.path);
    } catch (_) {
      if (originalFinalized && await finalOriginal.exists()) {
        await finalOriginal.delete();
      }
      rethrow;
    } finally {
      if (await stagedOriginal.exists()) {
        await stagedOriginal.delete();
      }
      if (await stagedThumbnail.exists()) {
        await stagedThumbnail.delete();
      }
    }

    return ImportedOwnedMedia(
      originalRelativePath: originalRelativePath,
      thumbnailRelativePath: thumbnailRelativePath,
      mediaType: format.mediaType,
      sha256: mediaHash,
      originalBytes: originalBytes.length,
      thumbnailBytes: thumbnailBytes.length,
      width: normalized.width,
      height: normalized.height,
    );
  }

  @override
  String thumbnailRelativePathForAsset(String assetId) =>
      '$thumbnailsDir/$assetId.jpg';

  @override
  File resolve(String relativePath) =>
      File(path.join(_rootDirectory.path, relativePath));

  @override
  Future<bool> exists(String relativePath) => resolve(relativePath).exists();

  @override
  Future<void> deleteManagedPath(String relativePath) async {
    final file = resolve(relativePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  @override
  Future<ManagedMediaInventory> scanInventory() async {
    final files = <ManagedMediaFile>[];
    for (final relative in <String>[originalsDir, thumbnailsDir]) {
      final directory = Directory(path.join(_rootDirectory.path, relative));
      if (!await directory.exists()) {
        continue;
      }
      await for (final entity in directory.list(recursive: true)) {
        if (entity is! File) {
          continue;
        }
        final stat = await entity.stat();
        final relativePath = path.relative(
          entity.path,
          from: _rootDirectory.path,
        );
        files.add(
          ManagedMediaFile(relativePath: relativePath, sizeBytes: stat.size),
        );
      }
    }
    files.sort((a, b) => a.relativePath.compareTo(b.relativePath));
    return ManagedMediaInventory(files);
  }

  Future<void> _ensureDirectories() async {
    for (final relative in <String>[originalsDir, thumbnailsDir, stagingDir]) {
      await Directory(
        path.join(_rootDirectory.path, relative),
      ).create(recursive: true);
    }
  }

  Uint8List _encode(_SanitizedImage image, _SourceImageFormat format) {
    final encoded = switch (format) {
      _SourceImageFormat.png => img.encodePng(image.pixels),
      _SourceImageFormat.jpeg => img.encodeJpg(
        image.pixels,
        quality: policy.jpegQuality,
      ),
    };
    return Uint8List.fromList(encoded);
  }

  Uint8List _encodeThumbnail(_SanitizedImage image) {
    final resized = img.copyResize(
      image.pixels,
      width: image.width >= image.height ? policy.thumbnailMaxEdge : null,
      height: image.height > image.width ? policy.thumbnailMaxEdge : null,
      interpolation: img.Interpolation.cubic,
    );
    return Uint8List.fromList(
      img.encodeJpg(resized, quality: policy.thumbnailJpegQuality),
    );
  }

  _SourceImageFormat _detectSourceFormat(List<int> bytes, String sourcePath) {
    final extension = path.extension(sourcePath).toLowerCase();
    if (extension == '.jpg' || extension == '.jpeg') {
      return _SourceImageFormat.jpeg;
    }
    if (extension == '.png') {
      return _SourceImageFormat.png;
    }

    if (bytes.length >= 8 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0D &&
        bytes[5] == 0x0A &&
        bytes[6] == 0x1A &&
        bytes[7] == 0x0A) {
      return _SourceImageFormat.png;
    }
    if (bytes.length >= 2 && bytes[0] == 0xFF && bytes[1] == 0xD8) {
      return _SourceImageFormat.jpeg;
    }
    throw const UnsupportedMediaException('only JPEG and PNG are supported');
  }
}

final class _SanitizedImage {
  const _SanitizedImage(this.pixels);

  final img.Image pixels;

  int get width => pixels.width;
  int get height => pixels.height;
}

enum _SourceImageFormat {
  jpeg(fileExtension: 'jpg', mediaType: 'image/jpeg'),
  png(fileExtension: 'png', mediaType: 'image/png');

  const _SourceImageFormat({
    required this.fileExtension,
    required this.mediaType,
  });

  final String fileExtension;
  final String mediaType;
}
