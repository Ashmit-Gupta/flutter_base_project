import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/core_providers.dart';
import '../data/data_source/mark_attendance_data_source.dart';
import '../data/repo/mark_attendance_repo.dart';

final markAttendanceDataSourceProvider = Provider<MarkAttendanceDataSource>(
  (ref) {
    final dio = ref.read(dioProvider);
    final logger = ref.read(appLoggerProvider);
    return MarkAttendanceDataSource(dio: dio, logger: logger);
  },
);

final markAttendanceRepoProvider = Provider<MarkAttendanceRepo>(
  (ref) {
    final dataSource = ref.read(markAttendanceDataSourceProvider);
    return MarkAttendanceRepo(dataSource: dataSource);
  },
);

