/// Domain identities are the UUIDv7 public IDs (ADR-017). The database's
/// internal integer keys never reach the domain.
extension type const ActivityTypeId(String value) {}

extension type const ActivityFieldId(String value) {}

extension type const SelectOptionId(String value) {}
