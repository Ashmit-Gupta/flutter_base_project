import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/core_providers.dart';
import '../data/data_source/employee_data_source.dart';
import '../data/repo/employee_repository_impl.dart';
import '../domain/repositories/employee_repository.dart';
import '../domain/usecases/register_employee_usecase.dart';

final employeeDataSourceProvider = Provider<EmployeeDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(appLoggerProvider);
  return EmployeeDataSource(dio: dio, logger: logger);
});

final employeeRepositoryImplProvider = Provider<EmployeeRepositoryImpl>((ref) {
  return EmployeeRepositoryImpl(dataSource: ref.watch(employeeDataSourceProvider));
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return ref.watch(employeeRepositoryImplProvider);
});

final registerEmployeeUseCaseProvider = Provider<RegisterEmployeeUseCase>((ref) {
  return RegisterEmployeeUseCase(ref.watch(employeeRepositoryProvider));
});
