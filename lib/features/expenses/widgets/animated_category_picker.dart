import 'package:flutter/material.dart';
import '../../../data/models/expense.dart';

class AnimatedCategoryPicker extends StatefulWidget {
  final ExpenseCategory selected;
  final ValueChanged<ExpenseCategory> onChanged;

  const AnimatedCategoryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  State<AnimatedCategoryPicker> createState() => _AnimatedCategoryPickerState();
}

class _AnimatedCategoryPickerState extends State<AnimatedCategoryPicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
  }

  @override
  void didUpdateWidget(covariant AnimatedCategoryPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  IconData _icon(ExpenseCategory c) => switch (c) {
        ExpenseCategory.food => Icons.restaurant,
        ExpenseCategory.transport => Icons.directions_bus,
        ExpenseCategory.shopping => Icons.shopping_bag,
        ExpenseCategory.bills => Icons.receipt_long,
        ExpenseCategory.entertainment => Icons.movie,
        ExpenseCategory.others => Icons.category,
      };

  Color _color(BuildContext context, ExpenseCategory c) {
    final scheme = Theme.of(context).colorScheme;
    return c == widget.selected ? scheme.primary : scheme.outline;
  }

  @override
  Widget build(BuildContext context) {
    final cats = ExpenseCategory.values;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: cats.map((c) {
        final selected = c == widget.selected;
        return GestureDetector(
          onTap: () => widget.onChanged(c),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              final t = Curves.easeOutBack.transform(_controller.value);
              final scale = selected ? (1.0 + 0.06 * t) : 1.0;
              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _color(context, c)),
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surface,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_icon(c), size: 18, color: _color(context, c)),
                      const SizedBox(width: 8),
                      Text(
                        c.name.toUpperCase(),
                        style: TextStyle(
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }).toList(),
    );
  }
}
