import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../utils/validators.dart';

class DynamicConfigList extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;
  final String label1;
  final String label2;
  final IconData icon;
  final VoidCallback onAdd;
  final void Function(int, String, String) onUpdate;
  final void Function(int) onRemove;

  const DynamicConfigList({
    super.key,
    required this.title,
    required this.items,
    required this.label1,
    required this.label2,
    required this.icon,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.secondaryBlue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: onAdd,
              icon: const Icon(Icons.add, color: AppColors.primaryCyan),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isPortMapping = title == 'Port Mappings';
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: item[label1.toLowerCase().replaceAll(' ', '')] ?? '',
                    decoration: InputDecoration(
                      labelText: label1,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (value) => onUpdate(index, item.keys.first, value),
                    validator: isPortMapping ? Validators.validatePort : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: item[label2.toLowerCase().replaceAll(' ', '')] ?? '',
                    decoration: InputDecoration(
                      labelText: label2,
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                    onChanged: (value) => onUpdate(index, item.keys.last, value),
                    validator: isPortMapping ? Validators.validatePort : null,
                  ),
                ),
                IconButton(
                  onPressed: () => onRemove(index),
                  icon: const Icon(Icons.remove, color: Color(0xFFEF4444)),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
} 