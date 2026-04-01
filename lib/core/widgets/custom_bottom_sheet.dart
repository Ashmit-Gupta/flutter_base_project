import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../app/theme/app_theme_extension.dart';

class CustomBottomSheet extends HookConsumerWidget {
  const CustomBottomSheet({
    super.key,
    this.minHeight,
    this.sheetBgColor,
    this.snapPositions,
    required this.child,
    this.isList = false,
    this.minHeightExtent,
    this.maxHeightExtent,
    this.initialChildSize,
    this.customController,
    this.hideDragHandle = false,
    this.showCloseButton = true,
    this.onClose,
  });

  final bool isList;
  final double? minHeight;
  final Color? sheetBgColor;
  final bool showCloseButton;
  final bool hideDragHandle;
  final double? minHeightExtent;
  final double? maxHeightExtent;
  final double? initialChildSize;
  final List<double>? snapPositions;
  final VoidCallback? onClose;

  final Widget Function(ScrollController scrollController) child;
  final DraggableScrollableController? customController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;

    final resolvedSheetColor = sheetBgColor ?? colors.surface;
    final closeButtonColor = colors.surfaceElevated;
    final closeIconColor = colors.textPrimary;
    final dragHandleColor = colors.border;

    /// ✅ Proper controller lifecycle
    final controller = useMemoized(
          () => customController ?? DraggableScrollableController(),
    );

    useEffect(() {
      return () {
        if (customController == null) {
          controller.dispose();
        }
      };
    }, [controller]);

    /// ✅ GoRouter-safe (Navigator-based)
    void collapse() => Navigator.of(context).pop();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        snap: true,
        expand: true,
        controller: controller,
        minChildSize: minHeight ?? 0.2,
        maxChildSize: maxHeightExtent ?? 0.95,
        initialChildSize: initialChildSize ?? minHeight ?? 0.5,
        snapSizes: snapPositions ??
            ((minHeight != null)
                ? [minHeight!, minHeightExtent ?? 0.5]
                : [minHeightExtent ?? 0.5]),
        builder: (context, scrollController) {
          return Column(
            children: [
              if (showCloseButton) ...[
                Center(
                  child: Material(
                    color: closeButtonColor,
                    borderRadius: BorderRadius.circular(40),
                    child: InkWell(
                      onTap: onClose ?? collapse,
                      borderRadius: BorderRadius.circular(40),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          size: 28,
                          color: closeIconColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (!hideDragHandle) ...[
                Container(
                  decoration: BoxDecoration(
                    color: resolvedSheetColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 4,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: dragHandleColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],

              Expanded(
                child: Material(
                  color: resolvedSheetColor,
                  borderRadius: hideDragHandle
                      ? const BorderRadius.vertical(
                    top: Radius.circular(16),
                  )
                      : null,
                  child: child(scrollController),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}