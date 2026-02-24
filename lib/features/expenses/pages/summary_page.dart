import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../expense_controller.dart';

class SummaryPage extends GetView<ExpenseController> {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary'),
      ),
      body: Obx(() {
        final items = controller.expenses;
        final base = controller.baseCurrency.value;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text('Base currency:'),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: base,
                    items: const ['INR', 'USD', 'EUR', 'GBP', 'JPY', 'AED']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => controller.baseCurrency.value = v ?? 'INR',
                  ),
                  const Spacer(),
                  if (controller.isLoadingRates.value)
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),

              const SizedBox(height: 10),

              Expanded(
                child: items.isEmpty
                    ? const Center(child: Text('No expenses to summarize.'))
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final e = items[i];

                          final converted = controller.convertedById[e.id];
                          final err = controller.conversionErrorById[e.id];
                          print(err);

                          final trailing = err != null
                              ? 'Error'
                              : (converted == null
                                  ? '...'
                                  : '${converted.toStringAsFixed(2)} $base');

                          return ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            tileColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            title: Text(e.title),
                            subtitle: Text(
                              err != null
                                  ? 'Conversion failed $err'
                                  : '${DateFormat.yMMMd().format(e.date)} • '
                                      '${e.amount.toStringAsFixed(2)} ${e.currency}',
                            ),
                            trailing: Text(trailing),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
