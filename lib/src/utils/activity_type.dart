/// The type of activity that user did.
enum ActivityType {
  /// The view activity.
  view,
  /// The create activity.
  create,
  /// The modify activity.
  modify,
  /// The delete activity.
  delete,
  /// The restore activity.
  restore,
}

/// An extension of [ActivityType] that adds parsing value functionality.
extension Parser on ActivityType {
  /// Parses value to text.
  String parseValueToString() {
    return toString().split('.').last;
  }
}