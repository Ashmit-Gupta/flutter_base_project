import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/shared/file_controller.dart';
import '../../data/model/get_all_employee_model.dart';
import '../../di/employee_di.dart';

final registerEmployeeViewModelProvider = NotifierProvider.autoDispose<
    RegisterEmployeeViewModel, RegisterEmployeeState>(
  RegisterEmployeeViewModel.new,
);

class RegisterEmployeeState {
  const RegisterEmployeeState({
    this.isLoadingEmployees = false,
    this.employees = const <GetAllEmployeeUserModel>[],
    this.selectedEmployeeName,
    this.selectedEmployeeCode,
    this.errorMessage,
  });

  final bool isLoadingEmployees;
  final List<GetAllEmployeeUserModel> employees;
  final String? selectedEmployeeName;
  final String? selectedEmployeeCode;
  final String? errorMessage;

  RegisterEmployeeState copyWith({
    bool? isLoadingEmployees,
    List<GetAllEmployeeUserModel>? employees,
    String? selectedEmployeeName,
    String? selectedEmployeeCode,
    String? errorMessage,
  }) {
    return RegisterEmployeeState(
      isLoadingEmployees: isLoadingEmployees ?? this.isLoadingEmployees,
      employees: employees ?? this.employees,
      selectedEmployeeName: selectedEmployeeName ?? this.selectedEmployeeName,
      selectedEmployeeCode: selectedEmployeeCode ?? this.selectedEmployeeCode,
      errorMessage: errorMessage,
    );
  }
}

class RegisterEmployeeActionResult {
  const RegisterEmployeeActionResult({
    required this.message,
    required this.isError,
  });

  final String message;
  final bool isError;
}

class RegisterEmployeeViewModel extends Notifier<RegisterEmployeeState> {
  @override
  RegisterEmployeeState build() {
    return const RegisterEmployeeState();
  }

  Future<void> loadEmployees() async {
    if (state.isLoadingEmployees || state.employees.isNotEmpty) return;
    state = state.copyWith(
      isLoadingEmployees: true,
      errorMessage: null,
    );

    final result = await ref.read(employeeRepoProvider).getAllEmployee().run();
    result.match(
      (failure) {
        state = state.copyWith(
          isLoadingEmployees: false,
          errorMessage: failure.message,
        );
      },
      (GetAllEmployeeModel response) {
        state = state.copyWith(
          isLoadingEmployees: false,
          employees: response.data.users,
          errorMessage: null,
        );
      },
    );
  }

  Future<List<GetAllEmployeeUserModel>> fetchEmployeesForBottomSheet({
    required int page,
    required int limit,
  }) async {
    // Current API returns full list; pagination params are reserved for future.
    // ignore: unused_local_variable
    final _ = (page, limit);

    final result = await ref.read(employeeRepoProvider).getAllEmployee().run();
    return result.match(
      (failure) {
        state = state.copyWith(errorMessage: failure.message);
        return const <GetAllEmployeeUserModel>[];
      },
      (response) {
        final users = response.data.users;
        state = state.copyWith(
          employees: users,
          errorMessage: null,
        );
        return users;
      },
    );
  }

  void selectEmployeeByName(String employeeName) {
    String? employeeCode;
    for (final employee in state.employees) {
      if (employee.name == employeeName) {
        employeeCode = employee.empCode;
        break;
      }
    }
    state = state.copyWith(
      selectedEmployeeName: employeeName,
      selectedEmployeeCode: employeeCode,
    );
  }

  RegisterEmployeeActionResult submit({
    required bool isFormValid,
    required int minUploads,
    required int maxUploads,
  }) {
    if (!isFormValid) {
      return const RegisterEmployeeActionResult(
        message: 'Please fill required fields.',
        isError: true,
      );
    }

    final fileValidationMessage = ref.read(fileControllerProvider.notifier).validateFileCount(
          minFiles: minUploads,
          maxFiles: maxUploads,
        );
    if (fileValidationMessage != null) {
      return RegisterEmployeeActionResult(
        message: fileValidationMessage,
        isError: true,
      );
    }

    return const RegisterEmployeeActionResult(
      message: 'Employee registration submitted',
      isError: false,
    );
  }
}
