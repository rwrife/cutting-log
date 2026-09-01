/// Optional capabilities that may be requested only from a user action.
enum OptionalPermission { camera, photos, notifications }

/// Platform boundary for later just-in-time permission requests.
abstract interface class OptionalPermissionGateway {
  Future<bool> request(OptionalPermission permission);
}

/// Safe default for the bootstrap shell: no platform request can be made.
final class DisabledOptionalPermissionGateway
    implements OptionalPermissionGateway {
  const DisabledOptionalPermissionGateway();

  @override
  Future<bool> request(OptionalPermission permission) async => false;
}
