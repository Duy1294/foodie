import 'package:flutter/material.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/constants/colors.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final SettingsService _settingsService = SettingsService();
  String _selectedLanguage = 'vi';
  bool _isLoading = true;

  final List<Map<String, String>> _languages = [
    {'code': 'vi', 'name': 'Tiếng Việt', 'nativeName': 'Tiếng Việt'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLang = await _settingsService.getLanguage();
    setState(() {
      _selectedLanguage = currentLang;
      _isLoading = false;
    });
  }

  Future<void> _selectLanguage(String languageCode) async {
    if (_selectedLanguage == languageCode) return;

    setState(() {
      _selectedLanguage = languageCode;
    });

    await _settingsService.setLanguage(languageCode);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngôn ngữ đã được thay đổi. Vui lòng khởi động lại ứng dụng.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ngôn ngữ'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedLanguage == language['code'];

                return RadioListTile<String>(
                  title: Text(language['name']!),
                  subtitle: Text(language['nativeName']!),
                  value: language['code']!,
                  groupValue: _selectedLanguage,
                  onChanged: (value) {
                    if (value != null) {
                      _selectLanguage(value);
                    }
                  },
                  secondary: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                );
              },
            ),
    );
  }
}

