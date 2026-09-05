import 'dart:io';

import 'package:cutting_log/src/platform/optional_permission_gateway.dart';
import 'package:permission_handler/permission_handler.dart' as permissions;

/// Requests optional capabilities only when explicitly triggered by the user.
final class PermissionHandlerOptionalPermissionGateway
    implements OptionalPermissionGateway {
  const PermissionHandlerOptionalPermissionGateway();

  @override
  Future<bool> request(OptionalPermission permission) async {
    switch (permission) {
      case OptionalPermission.camera:
        return _request(permissions.Permission.camera);
      case OptionalPermission.photos:
        if (Platform.isIOS) {
          return _request(permissions.Permission.photos);
        }
        // Android uses the system picker for photo import, so no persistent
        // photo-library grant is required for the local-first flow.
        return true;
      case OptionalPermission.notifications:
        return _request(permissions.Permission.notification);
    }
  }

  Future<bool> _request(permissions.Permission permission) async {
    final status = await permission.request();
    return status.isGranted || status.isLimited;
  }
}
