import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/widgets/common/accessible_button.dart';
import '../../../l10n/app_localizations.dart';

class LanguageSelectionScreen extends StatefulWidget {
  static const String routeName = '/language-selection';

  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String _selectedLanguageCode = 'en';

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString('selected_language') ?? 'en';
    setState(() {
      _selectedLanguageCode = savedLanguage;
    });
  }

  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', languageCode);
    setState(() {
      _selectedLanguageCode = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.language),
        leading: AccessibleIconButton(
          icon: Icons.arrow_back,
          onPressed: () => Navigator.of(context).pop(),
          semanticLabel: l10n.backButton,
          tooltip: l10n.back,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Language Settings',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select your preferred language. The app will restart to apply the changes.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),

          // Language Options
          Card(
            child: Column(
              children: AppLocalizations.supportedLocales.map((locale) {
                final isSelected = locale.languageCode == _selectedLanguageCode;
                final languageName = _getLanguageDisplayName(locale);
                final nativeName = _getNativeLanguageName(locale);
                
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSelected 
                        ? theme.colorScheme.primary.withValues(alpha: 0.1)
                        : theme.colorScheme.surface,
                    child: Text(
                      _getLanguageFlag(locale),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  title: Text(
                    languageName,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: nativeName != languageName 
                      ? Text(
                          nativeName,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        )
                      : null,
                  trailing: isSelected 
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                        )
                      : null,
                  onTap: () => _selectLanguage(locale.languageCode),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 24),

          // RTL Support Information
          if (_selectedLanguageCode == 'ar') ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_textdirection_r_to_l,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Right-to-Left Support',
                          style: theme.textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Arabic language includes full right-to-left (RTL) layout support with mirrored navigation and text alignment.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Apply Changes Button
          AccessibleButton(
            onPressed: _selectedLanguageCode != Localizations.localeOf(context).languageCode
                ? () => _applyLanguageChange(context)
                : null,
            semanticLabel: 'Apply language changes',
            backgroundColor: _selectedLanguageCode != Localizations.localeOf(context).languageCode
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.12),
            child: Text(
              'Apply Changes',
              style: TextStyle(
                color: _selectedLanguageCode != Localizations.localeOf(context).languageCode
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface.withValues(alpha: 0.38),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'fr':
        return 'French';
      case 'de':
        return 'German';
      case 'ar':
        return 'Arabic';
      default:
        return 'English';
    }
  }

  String _getNativeLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ar':
        return 'العربية';
      default:
        return 'English';
    }
  }

  String _getLanguageFlag(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'ar':
        return '🇸🇦';
      default:
        return '🇺🇸';
    }
  }

  void _selectLanguage(String languageCode) {
    _saveLanguage(languageCode);
  }

  void _applyLanguageChange(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text(
            'The app needs to restart to apply the language changes. '
            'Your data will be preserved.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // In a real app, you would implement app restart logic here
                // For now, we'll show a message
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Language will be applied on next app start'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              child: const Text('Restart'),
            ),
          ],
        );
      },
    );
  }
}