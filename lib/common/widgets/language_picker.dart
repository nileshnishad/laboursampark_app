import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';

/// All supported languages — [englishName] is sent to the API,
/// [nativeName] is shown in the UI in the language's own script.
class AppLanguage {
  final String englishName;
  final String nativeName;

  const AppLanguage(this.englishName, this.nativeName);
}

const List<AppLanguage> kAllLanguages = [
  AppLanguage('Hindi', 'हिंदी'),
  AppLanguage('English', 'English'),
  AppLanguage('Marathi', 'मराठी'),
  AppLanguage('Bhojpuri', 'भोजपुरी'),
  AppLanguage('Telugu', 'తెలుగు'),
  AppLanguage('Gujarati', 'ગુજરાતી'),
  AppLanguage('Kannada', 'ಕನ್ನಡ'),
  AppLanguage('Tamil', 'தமிழ்'),
  AppLanguage('Bengali', 'বাংলা'),
  AppLanguage('Punjabi', 'ਪੰਜਾਬੀ'),
  AppLanguage('Odia', 'ଓଡ଼ିଆ'),
  AppLanguage('Urdu', 'اردو'),
  AppLanguage('Assamese', 'অসমীয়া'),
  AppLanguage('Maithili', 'मैथिली'),
  AppLanguage('Rajasthani', 'राजस्थानी'),
];

/// Shows a bottom-sheet multi-select language picker.
/// [selected] is the current list of English language names.
/// Returns the updated list when the user taps Done, or null if dismissed.
Future<List<String>?> showLanguagePicker(
  BuildContext context, {
  required List<String> selected,
}) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _LanguagePickerSheet(selected: List<String>.from(selected)),
  );
}

class _LanguagePickerSheet extends StatefulWidget {
  final List<String> selected;

  const _LanguagePickerSheet({required this.selected});

  @override
  State<_LanguagePickerSheet> createState() => _LanguagePickerSheetState();
}

class _LanguagePickerSheetState extends State<_LanguagePickerSheet> {
  late List<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = List<String>.from(widget.selected);
  }

  void _toggle(String name) {
    setState(() {
      if (_selected.contains(name)) {
        _selected.remove(name);
      } else {
        _selected.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Color(0xFFF59E0B);

    return Container(
      height: MediaQuery.of(context).size.height * 0.72,
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.translate_rounded, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Languages',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Choose all languages you can speak',
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurface.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Language grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 3.2,
              ),
              itemCount: kAllLanguages.length,
              itemBuilder: (_, i) {
                final lang = kAllLanguages[i];
                final isSelected = _selected.contains(lang.englishName);
                return GestureDetector(
                  onTap: () => _toggle(lang.englishName),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withOpacity(0.1)
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? color : cs.outline.withOpacity(0.4),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check_circle_rounded
                              : Icons.circle_outlined,
                          size: 18,
                          color: isSelected
                              ? color
                              : cs.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang.nativeName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? color : cs.onSurface,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                lang.englishName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: cs.onSurface.withOpacity(0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 12 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_selected.length} language${_selected.length == 1 ? '' : 's'} selected',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface.withOpacity(0.6),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, _selected),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A small top-of-form widget for registration screens that lets unauthenticated
/// users switch the app label language quickly. It only changes UI labels.
class RegistrationLocaleSwitcher extends StatelessWidget {
  const RegistrationLocaleSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final current = appState.locale?.languageCode ?? 'en';

    String nativeLabel(String enName) {
      try {
        return kAllLanguages
            .firstWhere((l) => l.englishName == enName)
            .nativeName;
      } catch (_) {
        return enName;
      }
    }

    final supported = [
      {'code': 'en', 'label': 'EN'},
      {'code': 'hi', 'label': nativeLabel('Hindi')},
      {'code': 'mr', 'label': nativeLabel('Marathi')},
    ];

    // More compact single-row chips suitable for AppBar actions
    return SizedBox(
      height: 32,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: supported.asMap().entries.map((entry) {
          final item = entry.value;
          final idx = entry.key;
          final selectedItem = item['code'] == current;

          return Padding(
            padding: EdgeInsets.only(left: idx == 0 ? 0 : 6),
            child: GestureDetector(
              onTap: () {
                final code = item['code']!;
                final locale = Locale(code);
                if (code != current) {
                  Provider.of<AppState>(
                    context,
                    listen: false,
                  ).setLocale(locale);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedItem
                      ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: selectedItem
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.12),
                    width: 1,
                  ),
                ),
                child: Text(
                  item['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selectedItem
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A tappable chip-display widget that opens the language picker bottom sheet.
/// Drop-in replacement for the languages _ChipEditor.
class LanguageSelectorField extends StatelessWidget {
  final List<String> selected;
  final void Function(List<String>) onChanged;

  const LanguageSelectorField({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const color = Color(0xFFF59E0B);

    // Map English names to native display names
    String nativeName(String en) {
      return kAllLanguages
          .where((l) => l.englishName == en)
          .map((l) => l.nativeName)
          .firstWhere((_) => true, orElse: () => en);
    }

    return GestureDetector(
      onTap: () async {
        final result = await showLanguagePicker(context, selected: selected);
        if (result != null) onChanged(result);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: cs.onSurface.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: cs.outline.withOpacity(0.18)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.translate_rounded, size: 14, color: color),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const Icon(Icons.add_rounded, size: 18, color: color),
              ],
            ),
            const SizedBox(height: 8),
            if (selected.isEmpty)
              Text(
                'Tap to select languages',
                style: TextStyle(
                  fontSize: 12,
                  color: cs.onSurface.withOpacity(0.35),
                ),
              )
            else
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: selected.map((en) {
                  return GestureDetector(
                    onTap: () {
                      final updated = List<String>.from(selected)..remove(en);
                      onChanged(updated);
                    },
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 6, 5),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.25)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            nativeName(en),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.close_rounded,
                            size: 13,
                            color: color,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
