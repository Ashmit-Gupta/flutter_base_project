import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../app/routes.dart';
import '../../../../../app/theme/app_theme_extension.dart';
import '../../../../../core/design/app_radius.dart';
import '../../../../../core/design/app_spacing.dart';
import '../../../../../core/feedback/app_snackbar.dart';
import '../../data/model/get_all_employee_model.dart';
import '../view_models/employee_list_view_model.dart';

class EmployeeListScreen extends HookConsumerWidget {
  const EmployeeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(employeeListViewModelProvider);
    final vm = ref.read(employeeListViewModelProvider.notifier);
    final searchController = useTextEditingController(text: state.searchQuery);
    final debounceRef = useRef<Timer?>(null);

    ref.listen<EmployeeListState>(employeeListViewModelProvider, (
      previous,
      next,
    ) {
      final error = next.errorMessage;
      if (error != null &&
          error.isNotEmpty &&
          error != previous?.errorMessage) {
        AppSnackbar.error(context, error);
      }
    });

    Future<void> onSearchChanged(String value) async {
      debounceRef.value?.cancel();
      debounceRef.value = Timer(const Duration(milliseconds: 400), () {
        vm.setSearchQuery(value);
      });
    }

    useEffect(() {
      return () {
        debounceRef.value?.cancel();
      };
    }, const []);

    return Scaffold(
      appBar: AppBar(title: Text('Employees', style: context.text.title())),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search employees',
                      prefixIcon: const Icon(Icons.search_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    onChanged: onSearchChanged,
                    onSubmitted: vm.setSearchQuery,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  tooltip: 'Filter',
                  onPressed: () => _showFilterSheet(
                    context: context,
                    selected: state.registeredFilter,
                    onSelected: vm.setRegisteredFilter,
                  ),
                  icon: const Icon(Icons.filter_list_rounded),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: vm.fetchEmployees,
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.employees.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Text(
                            'No employees found',
                            style: context.text.body(),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        0,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      itemCount: state.employees.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final employee = state.employees[index];
                        return _EmployeeCard(employee: employee);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFilterSheet({
    required BuildContext context,
    required bool? selected,
    required Future<void> Function(bool?) onSelected,
  }) async {
    final value = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.verified_user_rounded,
                  color: context.theme.colors.success,
                ),
                title: const Text('Registered'),
                trailing: selected == true
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: context.theme.colors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(true),
              ),
              ListTile(
                leading: Icon(
                  Icons.person_off_rounded,
                  color: context.theme.colors.warning,
                ),
                title: const Text('Unregistered'),
                trailing: selected == false
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: context.theme.colors.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        );
      },
    );

    if (value == null) return;
    await onSelected(value);
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({required this.employee});

  final GetAllEmployeeUserModel employee;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () => context.push(AppRoutes.registerEmployee, extra: employee),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  employee.name.isEmpty ? '?' : employee.name[0].toUpperCase(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      employee.name,
                      style: context.text.body().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Code: ${employee.empCode}',
                      style: context.text.body().copyWith(
                        color: context.theme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: context.theme.colors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
