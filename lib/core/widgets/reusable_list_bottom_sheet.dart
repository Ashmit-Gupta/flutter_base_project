import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../app/theme/app_theme_extension.dart';
import 'custom_bottom_sheet.dart';

class ReusableListBottomSheet<T> extends HookConsumerWidget {
  final String? initialValue;
  final bool autoFocusSearch;
  final String title;
  final List<T>? list;
  final Map<dynamic, T>? map;
  final String Function(dynamic key, T value)? labelBuilder;
  final void Function(dynamic key, T value) onTap;
  final bool showSearch;
  final String searchHint;
  final bool allowAdding;
  final TextInputType? textInputType;

  /// Multi-select
  final bool allowMultiSelect;
  final void Function(Map<dynamic, T> selections)? onConfirmMultiSelect;

  /// Initial selections for multi-select mode (list of labels that should be pre-selected)
  final List<String>? initialSelectedLabels;

  /// Async pagination
  final Future<List<T>> Function(int page, int limit)? onFetchPage;
  final Future<List<T>> Function(String query, int page, int limit)? onSearchPagePaged;

  final int pageSize;
  final double bottomSheetInitialSize;

  const ReusableListBottomSheet({
    super.key,
    required this.title,
    this.list,
    this.map,
    this.labelBuilder,
    required this.onTap,
    this.initialValue,
    this.autoFocusSearch = false,
    this.showSearch = true,
    this.searchHint = "Search",
    this.allowAdding = false,
    this.textInputType,
    this.onFetchPage,
    this.onSearchPagePaged,
    this.pageSize = 20,
    this.bottomSheetInitialSize = 0.8,
    this.allowMultiSelect = false,
    this.onConfirmMultiSelect,
    this.initialSelectedLabels,
  }) : assert(list != null || map != null || onFetchPage != null, 'Either list, map, or onFetchPage must be provided');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMounted = useIsMounted();
    final searchController = useTextEditingController();
    final paginationController = useScrollController();

    final searchQuery = useState<String>('');
    final paginatedItems = useState<List<T>>(<T>[]);
    final hasMore = useState<bool>(true);
    final currentPage = useState<int>(0);
    final isFetching = useState<bool>(false);

    final remoteMode = useState<bool>(false);
    final isRemoteSearching = useState<bool>(false);
    final remoteSearchItems = useState<List<T>>(<T>[]);
    final searchPage = useState<int>(1);
    final searchHasMore = useState<bool>(true);
    final isRemoteFetchingMore = useState<bool>(false);

    final selected = useState<Map<dynamic, T>>(<dynamic, T>{});
    final selectedLabels = useState<Set<String>>(<String>{});

    final isPaginated = onFetchPage != null;
    final canRemoteSearch = onSearchPagePaged != null;

    void closeSheet([String? result]) => Navigator.of(context).pop(result);

    bool isAllLabel(dynamic key, T value) {
      final label = labelBuilder?.call(key, value) ?? value.toString();
      return label.trim().toLowerCase() == 'all';
    }

    Map<dynamic, T> allRealEntries(Map<dynamic, T>? entries) {
      final out = <dynamic, T>{};
      if (entries == null) return out;
      entries.forEach((k, v) {
        if (!isAllLabel(k, v)) out[k] = v;
      });
      return out;
    }

    bool areAllRealEntriesSelected(Map<dynamic, T>? entries) {
      final real = allRealEntries(entries);
      if (real.isEmpty) return false;
      for (final k in real.keys) {
        if (!selected.value.containsKey(k)) return false;
      }
      return true;
    }

    void toggleSelectAllFor(Map<dynamic, T>? entries) {
      final real = allRealEntries(entries);
      final allSelected = areAllRealEntriesSelected(entries);
      final next = Map<dynamic, T>.from(selected.value);
      if (allSelected) {
        for (final k in real.keys) {
          next.remove(k);
        }
      } else {
        for (final kv in real.entries) {
          next[kv.key] = kv.value;
        }
      }
      selected.value = next;
    }

    Future<void> fetchPage(int page) async {
      if (!isPaginated || isFetching.value) return;
      isFetching.value = true;
      try {
        final result = await onFetchPage!(page, pageSize);
        if (!isMounted()) return;
        final nextItems = List<T>.from(paginatedItems.value);
        if (page == 1) {
          nextItems
            ..clear()
            ..addAll(result);
        } else {
          nextItems.addAll(result);
        }
        paginatedItems.value = nextItems;
        currentPage.value = page;
        hasMore.value = result.length == pageSize;

        if (allowMultiSelect && selectedLabels.value.isNotEmpty) {
          final nextSelected = Map<dynamic, T>.from(selected.value);
          final startIdx = nextItems.length - result.length;
          for (int i = 0; i < result.length; i++) {
            final globalIdx = startIdx + i;
            final item = result[i];
            final label = labelBuilder?.call(globalIdx, item) ?? item.toString();
            if (selectedLabels.value.contains(label) &&
                !nextSelected.containsKey(globalIdx)) {
              nextSelected[globalIdx] = item;
            }
          }
          selected.value = nextSelected;
        }
      } finally {
        if (!isMounted()) return;
        isFetching.value = false;
      }
    }

    Future<void> runRemoteSearch() async {
      if (!canRemoteSearch) return;
      final q = searchController.text.trim();
      if (q.isEmpty) {
        remoteMode.value = false;
        remoteSearchItems.value = <T>[];
        isRemoteSearching.value = false;
        searchPage.value = 1;
        searchHasMore.value = true;
        return;
      }

      remoteMode.value = true;
      isRemoteSearching.value = true;
      remoteSearchItems.value = <T>[];
      searchPage.value = 1;
      searchHasMore.value = true;

      try {
        final result = await onSearchPagePaged!(q, 1, pageSize);
        if (!isMounted()) return;
        remoteSearchItems.value = List<T>.from(result);
        searchHasMore.value = result.length == pageSize;
      } finally {
        if (!isMounted()) return;
        isRemoteSearching.value = false;
      }
    }

    Future<void> fetchNextRemotePage() async {
      if (!canRemoteSearch ||
          isRemoteFetchingMore.value ||
          !searchHasMore.value) {
        return;
      }
      isRemoteFetchingMore.value = true;
      final q = searchController.text.trim();
      final nextPage = searchPage.value + 1;
      try {
        final result = await onSearchPagePaged!(q, nextPage, pageSize);
        if (!isMounted()) return;
        remoteSearchItems.value = [...remoteSearchItems.value, ...result];
        searchPage.value = nextPage;
        searchHasMore.value = result.length == pageSize;
      } finally {
        if (!isMounted()) return;
        isRemoteFetchingMore.value = false;
      }
    }

    void onLocalSearchChanged(String raw) {
      final q = raw.trim();
      searchQuery.value = q;
      if (q.isEmpty) {
        remoteMode.value = false;
        remoteSearchItems.value = <T>[];
        isRemoteSearching.value = false;
        searchPage.value = 1;
        searchHasMore.value = true;
        return;
      }
      if (remoteMode.value) {
        remoteMode.value = false;
      }
    }

    bool isSelected(dynamic key) => selected.value.containsKey(key);

    bool isSelectedByLabel(dynamic key, T value) {
      final label = labelBuilder?.call(key, value) ?? value.toString();
      return selectedLabels.value.contains(label);
    }

    void toggleSelect(dynamic key, T value) {
      final label = labelBuilder?.call(key, value) ?? value.toString();
      final nextSelected = Map<dynamic, T>.from(selected.value);
      final nextLabels = Set<String>.from(selectedLabels.value);

      if (nextSelected.containsKey(key) || nextLabels.contains(label)) {
        nextSelected.remove(key);
        nextLabels.remove(label);
      } else {
        nextSelected[key] = value;
        nextLabels.add(label);
      }
      selected.value = nextSelected;
      selectedLabels.value = nextLabels;
    }

    void confirmSelectionAndClose() {
      onConfirmMultiSelect?.call(selected.value);
      closeSheet();
    }

    useEffect(() {
      if (initialValue?.isNotEmpty ?? false) {
        searchController.text = initialValue!;
        searchQuery.value = initialValue!;
      }
      if (allowMultiSelect && initialSelectedLabels != null) {
        selectedLabels.value = {...selectedLabels.value, ...initialSelectedLabels!};
      }
      if (isPaginated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fetchPage(1);
        });
      }
      return null;
    }, const []);

    useEffect(() {
      if (!(isPaginated || remoteMode.value)) return null;

      void onScroll() {
        if (!paginationController.hasClients) return;
        final nearBottom = paginationController.position.pixels >=
            paginationController.position.maxScrollExtent - 100;
        if (!nearBottom) return;

        if (remoteMode.value &&
            canRemoteSearch &&
            searchHasMore.value &&
            !isRemoteFetchingMore.value) {
          fetchNextRemotePage();
          return;
        }

        if (!remoteMode.value && !isFetching.value && hasMore.value) {
          fetchPage(currentPage.value + 1);
        }
      }

      paginationController.addListener(onScroll);
      return () => paginationController.removeListener(onScroll);
    }, [
      isPaginated,
      remoteMode.value,
      canRemoteSearch,
      searchHasMore.value,
      isRemoteFetchingMore.value,
      isFetching.value,
      hasMore.value,
      currentPage.value,
    ]);

    final colors = context.theme.colors;

    return CustomBottomSheet(
      initialChildSize: bottomSheetInitialSize,
      child: (scrollController) {
        final items =
            isPaginated ? paginatedItems.value.asMap() : (map ?? list?.asMap());
        final isLocalSearchActive =
            searchQuery.value.isNotEmpty && !remoteMode.value;
        final query = searchQuery.value.toLowerCase();
        final localFilteredEntries =
            items?.entries.where((entry) {
                  final label =
                      labelBuilder?.call(entry.key, entry.value) ??
                          entry.value.toString();
                  return label.toLowerCase().contains(query);
                }).toList() ??
                <MapEntry<dynamic, T>>[];

        final effectiveController =
            (isPaginated || remoteMode.value) ? paginationController : scrollController;
        final dataLength = remoteMode.value
            ? remoteSearchItems.value.length
            : localFilteredEntries.length;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.text.title().copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    if (allowMultiSelect)
                      TextButton(
                        onPressed: confirmSelectionAndClose,
                        child: Text(
                          selected.value.isEmpty
                              ? 'Done'
                              : 'Done (${selected.value.length})',
                        ),
                      ),
                  ],
                ),
              ),
              if (showSearch)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  height: 48,
                  child: TextFormField(
                    autofocus: autoFocusSearch,
                    controller: searchController,
                    onChanged: onLocalSearchChanged,
                    keyboardType: textInputType ?? TextInputType.text,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: searchHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                      suffixIcon: IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search),
                        onPressed: canRemoteSearch ? runRemoteSearch : null,
                      ),
                    ),
                    onFieldSubmitted: (_) {
                      if (canRemoteSearch) runRemoteSearch();
                    },
                  ),
                ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (remoteMode.value) {
                      if (isRemoteSearching.value &&
                          remoteSearchItems.value.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (dataLength == 0) {
                        return Text(
                          'No matches',
                          style: context.text.body().copyWith(
                                color: colors.textSecondary,
                              ),
                        );
                      }

                      final visibleMap = {
                        for (var i = 0; i < remoteSearchItems.value.length; i++)
                          i: remoteSearchItems.value[i],
                      };

                      return ListView.builder(
                        controller: effectiveController,
                        padding: const EdgeInsets.all(16),
                        itemCount: dataLength + (searchHasMore.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (searchHasMore.value && index == dataLength) {
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }

                          final value = remoteSearchItems.value[index];
                          final displayText =
                              labelBuilder?.call(index, value) ?? value.toString();
                          final isAll = isAllLabel(index, value);

                          return ListTile(
                            title: Text(displayText),
                            trailing: allowMultiSelect
                                ? Checkbox(
                                    value: isAll
                                        ? areAllRealEntriesSelected(visibleMap)
                                        : (isSelected(index) ||
                                            isSelectedByLabel(index, value)),
                                    onChanged: (_) {
                                      if (isAll) {
                                        toggleSelectAllFor(visibleMap);
                                      } else {
                                        toggleSelect(index, value);
                                      }
                                    },
                                  )
                                : const Icon(Icons.keyboard_arrow_right_rounded),
                            onTap: () {
                              if (allowMultiSelect) {
                                if (isAll) {
                                  toggleSelectAllFor(visibleMap);
                                } else {
                                  toggleSelect(index, value);
                                }
                              } else {
                                onTap(index, value);
                                if (context.mounted) {
                                  closeSheet(displayText);
                                }
                              }
                            },
                          );
                        },
                      );
                    }

                    if (isPaginated &&
                        isFetching.value &&
                        paginatedItems.value.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (dataLength == 0 && !isFetching.value) {
                      return Text(
                        'No items found',
                        style: context.text.body().copyWith(
                              color: colors.textSecondary,
                            ),
                      );
                    }

                    final visibleMap = {
                      for (final e in localFilteredEntries) e.key: e.value,
                    };

                    return ListView.builder(
                      controller: effectiveController,
                      padding: const EdgeInsets.all(16),
                      itemCount: dataLength +
                          (isPaginated &&
                                  !isLocalSearchActive &&
                                  (hasMore.value || isFetching.value)
                              ? 1
                              : 0),
                      itemBuilder: (context, index) {
                        if (isPaginated &&
                            !isLocalSearchActive &&
                            (hasMore.value || isFetching.value) &&
                            index == dataLength) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final entry = localFilteredEntries[index];
                        final key = entry.key;
                        final value = entry.value;
                        final displayText =
                            labelBuilder?.call(key, value) ?? value.toString();
                        final isAll = isAllLabel(key, value);

                        return ListTile(
                          title: Text(displayText),
                          trailing: allowMultiSelect
                              ? Checkbox(
                                  value: isAll
                                      ? areAllRealEntriesSelected(visibleMap)
                                      : (isSelected(key) ||
                                          isSelectedByLabel(key, value)),
                                  onChanged: (_) {
                                    if (isAll) {
                                      toggleSelectAllFor(visibleMap);
                                    } else {
                                      toggleSelect(key, value);
                                    }
                                  },
                                )
                              : const Icon(Icons.keyboard_arrow_right_rounded),
                          onTap: () {
                            if (allowMultiSelect) {
                              if (isAll) {
                                toggleSelectAllFor(visibleMap);
                              } else {
                                toggleSelect(key, value);
                              }
                            } else {
                              onTap(key, value);
                              if (context.mounted) {
                                closeSheet(displayText);
                              }
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/*
Sample usage and use-cases
--------------------------

1) Local static list (simple picker)
Use when options are already available in memory.

showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (_) => ReusableListBottomSheet<String>(
    title: 'Select department',
    list: const ['Engineering', 'HR', 'Finance', 'Operations'],
    onTap: (key, value) {
      // key = index from list.asMap()
      Navigator.of(context).pop(value);
    },
  ),
);

2) Map source (stable IDs)
Use when each item has an external key/id.

final departmentMap = <int, String>{
  10: 'Engineering',
  20: 'HR',
  30: 'Finance',
};

ReusableListBottomSheet<String>(
  title: 'Select department',
  map: departmentMap,
  labelBuilder: (key, value) => '$value (#$key)',
  onTap: (key, value) {
    // key = map key (e.g., 10/20/30)
  },
);

3) Paginated API (infinite scroll)
Use when data is large and loaded page by page.

ReusableListBottomSheet<Employee>(
  title: 'Select employee',
  onFetchPage: (page, limit) async {
    // return await repository.fetchEmployees(page: page, limit: limit);
    return <Employee>[];
  },
  pageSize: 20,
  onTap: (key, employee) {
    // key = visible index in paginated list
  },
);

4) Remote search + pagination
Use when search must call backend.

ReusableListBottomSheet<Employee>(
  title: 'Search employee',
  onFetchPage: (page, limit) async => <Employee>[], // optional initial list
  onSearchPagePaged: (query, page, limit) async {
    // return await repository.searchEmployees(query, page: page, limit: limit);
    return <Employee>[];
  },
  searchHint: 'Search by name or ID',
  onTap: (key, employee) {},
);

5) Multi-select + preselected values
Use when user can pick multiple records and confirm once.

ReusableListBottomSheet<String>(
  title: 'Assign skills',
  list: const ['All', 'Dart', 'Flutter', 'Firebase'],
  allowMultiSelect: true,
  initialSelectedLabels: const ['Dart'],
  onConfirmMultiSelect: (selections) {
    // selections => selected key/value map
  },
  onTap: (_, __) {}, // not used in multi-select mode
);

All constructor fields and when to use:
- title: Sheet header text.
- list: In-memory options as List<T>.
- map: In-memory options as Map<id, T>.
- labelBuilder: Custom display label per item.
- onTap: Single-select callback (item tap closes sheet).
- initialValue: Initial value for search input.
- autoFocusSearch: Focus search field when sheet opens.
- showSearch: Show/hide search field.
- searchHint: Search input label text.
- allowAdding: Reserved for future add-new flow.
- textInputType: Keyboard type for search input.
- allowMultiSelect: Enables checkbox selection.
- onConfirmMultiSelect: Callback for final selected items.
- initialSelectedLabels: Preselect options by label in multi-select.
- onFetchPage: Paginated loader (page, limit).
- onSearchPagePaged: Remote search loader (query, page, limit).
- pageSize: Page size for pagination/search requests.
- bottomSheetInitialSize: Initial draggable sheet height.
*/
