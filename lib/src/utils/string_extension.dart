/// An extension of [String] that adds capitalization functionality.
extension StringExtension on String {
  /// Capitalizes first letter of the text.
  String capitalize() {
    if (this == null || isEmpty) {
      return '';
    }

    if (length == 1) {
      return capitalize();
    }

    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
