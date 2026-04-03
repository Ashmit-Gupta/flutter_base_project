import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/employee_summary.dart';
import '../../di/employee_di.dart';

final employeeListViewModelProvider =
    NotifierProvider.autoDispose<EmployeeListViewModel, EmployeeListState>(
      EmployeeListViewModel.new,
    );

class EmployeeListState {
  const EmployeeListState({
    this.isLoading = false,
    this.employees = const <EmployeeSummary>[],
    this.searchQuery = '',
    this.registeredFilter,
    this.errorMessage,
  });

  final bool isLoading;
  final List<EmployeeSummary> employees;
  final String searchQuery;
  final bool? registeredFilter;
  final String? errorMessage;

  EmployeeListState copyWith({
    bool? isLoading,
    List<EmployeeSummary>? employees,
    String? searchQuery,
    bool? registeredFilter,
    bool clearRegisteredFilter = false,
    String? errorMessage,
  }) {
    return EmployeeListState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      searchQuery: searchQuery ?? this.searchQuery,
      registeredFilter: clearRegisteredFilter
          ? null
          : (registeredFilter ?? this.registeredFilter),
      errorMessage: errorMessage,
    );
  }
}

class EmployeeListViewModel extends Notifier<EmployeeListState> {
  @override
  EmployeeListState build() {
    Future.microtask(fetchEmployees);
    return const EmployeeListState();
  }

  Future<void> fetchEmployees() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final query = state.searchQuery.trim();
    final result = await ref
        .read(employeeRepositoryProvider)
        .getAllEmployee(
          name: query.isEmpty ? null : query,
          registered: state.registeredFilter,
        )
        .run();

    result.match(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          employees: const <EmployeeSummary>[],
          errorMessage: failure.message,
        );
      },
      (employees) {
        state = state.copyWith(
          isLoading: false,
          employees: employees,
          errorMessage: null,
        );
      },
    );
  }

  Future<void> setSearchQuery(String query) async {
    state = state.copyWith(searchQuery: query);
    await fetchEmployees();
  }

  Future<void> setRegisteredFilter(bool? isRegistered) async {
    if (isRegistered == null) {
      state = state.copyWith(clearRegisteredFilter: true);
    } else {
      state = state.copyWith(registeredFilter: isRegistered);
    }
    await fetchEmployees();
  }
}
