import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/constants/colors.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn giao diện'),
      ),
      body: ListView(
        children: [
          RadioListTile<ThemeMode>(
            title: const Text('Sáng'),
            subtitle: const Text('Giao diện sáng'),
            value: ThemeMode.light,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
            secondary: themeProvider.themeMode == ThemeMode.light
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
          ),
          const Divider(),
          RadioListTile<ThemeMode>(
            title: const Text('Tối'),
            subtitle: const Text('Giao diện tối'),
            value: ThemeMode.dark,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
            secondary: themeProvider.themeMode == ThemeMode.dark
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
          ),
          const Divider(),
          RadioListTile<ThemeMode>(
            title: const Text('Theo hệ thống'),
            subtitle: const Text('Tự động theo cài đặt hệ thống'),
            value: ThemeMode.system,
            groupValue: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) {
                themeProvider.setThemeMode(value);
              }
            },
            secondary: themeProvider.themeMode == ThemeMode.system
                ? const Icon(Icons.check_circle, color: AppColors.primary)
                : null,
          ),
        ],
      ),
    );
  }
}

