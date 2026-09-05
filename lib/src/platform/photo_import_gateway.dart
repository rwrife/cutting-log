import 'package:image_picker/image_picker.dart';

enum PhotoImportSource { camera, photoLibrary }

final class PickedPhoto {
  const PickedPhoto({
    required this.path,
    required this.source,
    required this.pickedAtUtc,
  });

  final String path;
  final PhotoImportSource source;
  final DateTime pickedAtUtc;
}

abstract interface class PhotoImportGateway {
  Future<PickedPhoto?> pick(PhotoImportSource source);
}

final class DisabledPhotoImportGateway implements PhotoImportGateway {
  const DisabledPhotoImportGateway();

  @override
  Future<PickedPhoto?> pick(PhotoImportSource source) async => null;
}

final class ImagePickerPhotoImportGateway implements PhotoImportGateway {
  ImagePickerPhotoImportGateway([ImagePicker? picker])
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<PickedPhoto?> pick(PhotoImportSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoImportSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      requestFullMetadata: false,
      imageQuality: 95,
    );
    if (file == null) {
      return null;
    }
    return PickedPhoto(
      path: file.path,
      source: source,
      pickedAtUtc: DateTime.now().toUtc(),
    );
  }
}
