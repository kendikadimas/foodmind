import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../models/food_history.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _filterType = 'semua'; // 'hari', 'minggu', 'semua'

  List<FoodHistory> _getFilteredHistory(List<FoodHistory> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    switch (_filterType) {
      case 'hari':
        return items
            .where((item) =>
                DateTime(item.timestamp.year, item.timestamp.month,
                    item.timestamp.day) ==
                today)
            .toList();
      case 'minggu':
        return items
            .where(
              (item) => item.timestamp.isAfter(weekAgo) && item.timestamp.isBefore(now.add(const Duration(days: 1))),
            )
            .toList();
      case 'semua':
      default:
        return items;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Hari Ini, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (dateOnly == yesterday) {
      return 'Kemarin';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Riwayat Rekomendasi'),
        backgroundColor: AppTheme.white,
        elevation: 0,
        foregroundColor: AppTheme.black,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildFilterButton('Hari Ini', 'hari'),
                const SizedBox(width: 8),
                _buildFilterButton('Minggu Ini', 'minggu'),
                const SizedBox(width: 8),
                _buildFilterButton('Semua', 'semua'),
              ],
            ),
          ),

          // History List
          Expanded(
            child: ValueListenableBuilder<Box<FoodHistory>>(
              valueListenable:
                  Hive.box<FoodHistory>('foodHistory').listenable(),
              builder: (context, box, _) {
                final allItems = box.values.toList();
                allItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                final filtered = _getFilteredHistory(allItems);

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.history,
                          size: 64,
                          color: AppTheme.mediumGray,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Belum ada riwayat',
                          style: AppTheme.headingSmall.copyWith(
                            color: AppTheme.mediumGray,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Cari rekomendasi makanan untuk memulai',
                          style: AppTheme.bodySmall,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    return _buildHistoryCard(item);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String label, String filterValue) {
    final isSelected = _filterType == filterValue;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filterType = filterValue;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryOrange : AppTheme.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.white : AppTheme.black,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(FoodHistory item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryOrange.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.mainFood,
                      style: AppTheme.headingSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(item.timestamp),
                      style: AppTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppTheme.mediumGray),
                onPressed: () {
                  item.delete();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Riwayat dihapus'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          if (item.alternatives.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Alternatif:',
                  style: AppTheme.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  children: item.alternatives
                      .take(2)
                      .map(
                        (alt) => Chip(
                          label: Text(
                            alt,
                            style: const TextStyle(fontSize: 12),
                          ),
                          backgroundColor: AppTheme.primaryOrange
                              .withOpacity(0.1),
                          labelStyle: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontSize: 12,
                          ),
                        ),
                      )
                      .toList(),
                ),
                if (item.alternatives.length > 2)
                  Text(
                    '+${item.alternatives.length - 2} lainnya',
                    style: AppTheme.bodySmall,
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
