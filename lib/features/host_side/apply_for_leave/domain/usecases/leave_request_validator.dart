/// Validates the leave-request form fields before submission. Pulled out of
/// the cubit so this business rule is testable on its own; error messages
/// are unchanged from the original inline checks.
class LeaveRequestValidator {
  const LeaveRequestValidator._();

  /// Returns the first validation error found, or `null` if the form is valid.
  static String? validate({
    required DateTime? startDate,
    required DateTime? endDate,
    required String reason,
  }) {
    if (startDate == null) {
      return 'Please select a start date';
    }
    if (endDate == null) {
      return 'Please select an end date';
    }
    if (reason.trim().isEmpty) {
      return 'Please provide a reason for leave';
    }
    if (endDate.isBefore(startDate)) {
      return 'End date cannot be before start date';
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedStart = DateTime(startDate.year, startDate.month, startDate.day);
    if (selectedStart.isBefore(today)) {
      return 'Start date cannot be in the past';
    }
    return null;
  }
}
