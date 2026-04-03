/// Lightweight employee row for lists and registration pre-selection.
class EmployeeSummary {
  const EmployeeSummary({
    required this.employeeId,
    required this.empCode,
    required this.name,
  });

  final int employeeId;
  final String empCode;
  final String name;
}
