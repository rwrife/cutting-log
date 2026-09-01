/// Product guarantees that must hold before optional features are enabled.
final class StartupPolicy {
  const StartupPolicy();

  bool get requiresAccount => false;
  bool get requiresNetwork => false;
  bool get requestsOptionalPermissions => false;
  bool get storesDataLocally => true;
}
