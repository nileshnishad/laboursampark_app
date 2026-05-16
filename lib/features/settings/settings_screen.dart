import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).settings),
        backgroundColor: cs.surface,
        iconTheme: IconThemeData(color: cs.onSurface),
        foregroundColor: cs.onSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            AppLocalizations.of(context).settings,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: Text(AppLocalizations.of(context).systemDefault),
                  value: ThemeMode.system,
                  groupValue: appState.themeMode,
                  onChanged: (v) =>
                      appState.setThemeMode(v ?? ThemeMode.system),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(AppLocalizations.of(context).lightMode),
                  value: ThemeMode.light,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v ?? ThemeMode.light),
                ),
                RadioListTile<ThemeMode>(
                  title: Text(AppLocalizations.of(context).darkMode),
                  value: ThemeMode.dark,
                  groupValue: appState.themeMode,
                  onChanged: (v) => appState.setThemeMode(v ?? ThemeMode.dark),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).language,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(AppLocalizations.of(context).english),
                  leading: Radio<String>(
                    value: 'en',
                    groupValue: appState.locale?.languageCode ?? 'en',
                    onChanged: (v) => appState.setLocale(Locale(v!)),
                  ),
                  onTap: () => appState.setLocale(const Locale('en')),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).hindi),
                  leading: Radio<String>(
                    value: 'hi',
                    groupValue: appState.locale?.languageCode ?? 'en',
                    onChanged: (v) => appState.setLocale(Locale(v!)),
                  ),
                  onTap: () => appState.setLocale(const Locale('hi')),
                ),
                ListTile(
                  title: Text(AppLocalizations.of(context).marathi),
                  leading: Radio<String>(
                    value: 'mr',
                    groupValue: appState.locale?.languageCode ?? 'en',
                    onChanged: (v) => appState.setLocale(Locale(v!)),
                  ),
                  onTap: () => appState.setLocale(const Locale('mr')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
