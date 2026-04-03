import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/module/employee_module/data/model/get_all_employee_model.dart';
import '../../../../features/module/employee_module/data/model/register_employee_face_detection_images_model.dart';
import '../../../../features/module/employee_module/di/employee_di.dart';
import '../../../../features/shared/file_controller.dart';
import '../../../../features/shared/models/app_file_model.dart';

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
          employees: response.data,
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
        final users = response.data;
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

  Future<RegisterEmployeeActionResult> submit({
    required bool isFormValid,
  }) async {
    if (!isFormValid) {
      return Future.value(const RegisterEmployeeActionResult(
        message: 'Please fill required fields.',
        isError: true,
      ));
    }

    final employeeCode = state.selectedEmployeeCode;
    if (employeeCode == null || employeeCode.isEmpty) {
      return Future.value(const RegisterEmployeeActionResult(
        message: 'Please select an employee.',
        isError: true,
      ));
    }

    final fileController = ref.read(fileControllerProvider.notifier);
    final left = _firstProfileFile(fileController, 'left_profile');
    final front = _firstProfileFile(fileController, 'front_profile');
    final right = _firstProfileFile(fileController, 'right_profile');
    if (left == null || front == null || right == null) {
      return Future.value(const RegisterEmployeeActionResult(
        message: 'Please capture all profiles (left, front, right).',
        isError: true,
      ));
    }

    final images = RegisterEmployeeFaceDetectionImagesModel(
      leftProfile: left,
      frontProfile: front,
      rightProfile: right,
    );

    final result = await ref
        .read(employeeRepoProvider)
        .registerEmployee(employeeCode: employeeCode, images: images)
        .run();

    return result.match(
      (failure) => RegisterEmployeeActionResult(
        message: failure.message,
        isError: true,
      ),
      (_) => const RegisterEmployeeActionResult(
        message: 'Employee registration submitted',
        isError: false,
      ),
    );
  }

  AppFileModel? _firstProfileFile(
    FileController controller,
    String profileKey,
  ) {
    final files = controller.filesForProfile(profileKey);
    if (files.isEmpty) return null;
    return files.first;
  }
}
