import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/app_metadata.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final cs = Theme.of(context).colorScheme;

    Future<void> openExternal(String url) async {
      final uri = Uri.tryParse(url);
      if (uri == null) return;
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    Future<void> openEmail(String email) async {
      final uri = Uri(scheme: 'mailto', path: email);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

    Future<void> openPhone(String phone) async {
      final uri = Uri(scheme: 'tel', path: phone);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }

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

          const SizedBox(height: 16),
          Text(
            'App Support',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy Policy'),
                  subtitle: AppMetadata.hasPrivacyPolicyUrl
                      ? const Text('Open privacy policy')
                      : const Text(
                          'Configure privacyPolicyUrl in app metadata',
                        ),
                  trailing: const Icon(Icons.open_in_new),
                  enabled: AppMetadata.hasPrivacyPolicyUrl,
                  onTap: AppMetadata.hasPrivacyPolicyUrl
                      ? () => openExternal(AppMetadata.privacyPolicyUrl)
                      : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text('Support'),
                  subtitle: AppMetadata.hasSupportUrl
                      ? const Text('Open support page')
                      : const Text('Configure supportUrl in app metadata'),
                  trailing: const Icon(Icons.open_in_new),
                  enabled: AppMetadata.hasSupportUrl,
                  onTap: AppMetadata.hasSupportUrl
                      ? () => openExternal(AppMetadata.supportUrl)
                      : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Contact Email'),
                  subtitle: AppMetadata.hasSupportEmail
                      ? Text(AppMetadata.supportEmail)
                      : const Text('Configure supportEmail in app metadata'),
                  trailing: const Icon(Icons.open_in_new),
                  enabled: AppMetadata.hasSupportEmail,
                  onTap: AppMetadata.hasSupportEmail
                      ? () => openEmail(AppMetadata.supportEmail)
                      : null,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.phone_outlined),
                  title: const Text('Contact Phone'),
                  subtitle: AppMetadata.hasSupportPhone
                      ? Text(AppMetadata.supportPhone)
                      : const Text('Configure supportPhone in app metadata'),
                  trailing: const Icon(Icons.open_in_new),
                  enabled: AppMetadata.hasSupportPhone,
                  onTap: AppMetadata.hasSupportPhone
                      ? () => openPhone(AppMetadata.supportPhone)
                      : null,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(AppMetadata.appName),
              subtitle: Text(
                'Category: ${AppMetadata.appStoreCategory} · Age rating: ${AppMetadata.appStoreAgeRating}',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
