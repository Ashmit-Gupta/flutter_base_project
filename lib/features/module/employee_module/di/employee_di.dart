import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../data/data_source/employee_data_source.dart';
import '../data/repo/employee_repo.dart';



final employeeDataSourceProvider = Provider<EmployeeDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final logger = ref.read(appLoggerProvider);
  return EmployeeDataSource(dio: dio, logger: logger);
});

final employeeRepoProvider = Provider<EmployeeRepo>(
  (ref) {
    final dataSource = ref.read(employeeDataSourceProvider);
    return EmployeeRepo(dataSource: dataSource);
  },
);
