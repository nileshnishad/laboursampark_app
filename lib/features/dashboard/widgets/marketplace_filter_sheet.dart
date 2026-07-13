import 'package:flutter/material.dart';
import '../../../common/data/state_city_data.dart';
import '../../../common/models/business_type_model.dart';
import '../../../common/models/skill_model.dart';
import '../../../l10n/app_localizations.dart';
import '../models/marketplace_filter.dart';

class MarketplaceFilterSheet extends StatefulWidget {
  final MarketplaceFilter initialFilter;
  final List<SkillModel>? skills;
  final List<BusinessTypeModel>? businessTypes;
  final bool isLabourPage;

  const MarketplaceFilterSheet({
    super.key,
    required this.initialFilter,
    required this.skills,
    required this.businessTypes,
    required this.isLabourPage,
  });

  @override
  State<MarketplaceFilterSheet> createState() => _MarketplaceFilterSheetState();
}

class _MarketplaceFilterSheetState extends State<MarketplaceFilterSheet> {
  String _selectedState = '';
  String _selectedCity = '';
  String _selectedArea = '';
  double _rating = 0;
  int _experience = 0;
  String _activePanel = 'location';
  late List<String> _selectedSkillIds;
  late List<String> _selectedBusinessTypeIds;

  @override
  void initState() {
    super.initState();
    _selectedState = widget.initialFilter.state;
    _selectedCity = widget.initialFilter.city;
    _selectedArea = widget.initialFilter.area;
    _rating = widget.initialFilter.minRating;
    _experience = widget.initialFilter.minExperience;
    _selectedSkillIds = List<String>.from(widget.initialFilter.skillIds);
    _selectedBusinessTypeIds = List<String>.from(
      widget.initialFilter.businessTypeIds,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _toggleSelection(String id, List<String> list) {
    setState(() {
      if (list.contains(id)) {
        list.remove(id);
      } else {
        list.add(id);
      }
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedState = '';
      _selectedCity = '';
      _selectedArea = '';
      _rating = 0;
      _experience = 0;
      _selectedSkillIds.clear();
      _selectedBusinessTypeIds.clear();
      _activePanel = 'location';
    });
  }

  void _setActivePanel(String panel) {
    setState(() {
      _activePanel = panel;
    });
  }

  Widget _buildPanelButton(String label, String panelKey, ThemeData theme) {
    final selected = _activePanel == panelKey;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected
            ? theme.colorScheme.primary.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _setActivePanel(panelKey),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: selected ? theme.colorScheme.primary : null,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPanelContent(
    ThemeData theme,
    List<SkillModel> availableSkillItems,
    List<BusinessTypeModel> availableBusinessItems,
  ) {
    switch (_activePanel) {
      case 'location':
        final sortedStates = completeIndiaData.keys.toList()..sort();
        final sortedCities = _selectedState.isEmpty
            ? <String>[]
            : completeIndiaData[_selectedState]?.keys.toList() ?? <String>[];
        sortedCities.sort();
        final sortedAreas = _selectedState.isEmpty || _selectedCity.isEmpty
            ? <String>[]
            : completeIndiaData[_selectedState]?[_selectedCity]?.toList() ??
                  <String>[];
        sortedAreas.sort();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).locationSection,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedState.isEmpty ? null : _selectedState,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.map),
                labelText: AppLocalizations.of(context).stateLabelDropdown,
              ),
              items: sortedStates
                  .map(
                    (state) =>
                        DropdownMenuItem(value: state, child: Text(state)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedState = value ?? '';
                  _selectedCity = '';
                  _selectedArea = '';
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedCity.isEmpty ? null : _selectedCity,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_city),
                labelText: AppLocalizations.of(context).cityLabelDropdown,
              ),
              items: sortedCities
                  .map(
                    (city) => DropdownMenuItem(value: city, child: Text(city)),
                  )
                  .toList(),
              onChanged: _selectedState.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCity = value ?? '';
                        _selectedArea = '';
                      });
                    },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _selectedArea.isEmpty ? null : _selectedArea,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.location_pin),
                labelText: AppLocalizations.of(context).areaLabelDropdown,
              ),
              items: sortedAreas
                  .map(
                    (area) => DropdownMenuItem(value: area, child: Text(area)),
                  )
                  .toList(),
              onChanged: sortedAreas.isEmpty
                  ? null
                  : (value) {
                      setState(() {
                        _selectedArea = value ?? '';
                      });
                    },
            ),
          ],
        );
      case 'rating':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).minimumRatingLabel,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Slider(
              value: _rating,
              min: 0,
              max: 5,
              divisions: 5,
              label: _rating == 0
                  ? AppLocalizations.of(context).anyLabel
                  : _rating.toStringAsFixed(1),
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 8),
            Text(
              _rating == 0
                  ? AppLocalizations.of(context).anyLabel
                  : _rating.toStringAsFixed(1),
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      case 'experience':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context).experienceYearsLabel,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Slider(
              value: _experience.toDouble(),
              min: 0,
              max: 30,
              divisions: 6,
              label: _experience == 0
                  ? AppLocalizations.of(context).anyLabel
                  : '$_experience+',
              onChanged: (value) => setState(() => _experience = value.toInt()),
            ),
            const SizedBox(height: 8),
            Text(
              _experience == 0
                  ? AppLocalizations.of(context).anyLabel
                  : '$_experience+',
              style: theme.textTheme.bodySmall,
            ),
          ],
        );
      case 'items':
        final itemsWidget = widget.isLabourPage
            ? availableSkillItems.map((skill) {
                final selected = _selectedSkillIds.contains(skill.id);
                final languageCode = Localizations.localeOf(
                  context,
                ).languageCode;
                final label = languageCode == 'hi'
                    ? skill.hiName
                    : languageCode == 'mr'
                    ? skill.mrName
                    : skill.enName;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  trailing: selected
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 18,
                        )
                      : null,
                  onTap: () => _toggleSelection(skill.id, _selectedSkillIds),
                  selected: selected,
                  selectedTileColor: theme.colorScheme.primary.withOpacity(
                    0.08,
                  ),
                );
              }).toList()
            : availableBusinessItems.map((businessType) {
                final selected = _selectedBusinessTypeIds.contains(
                  businessType.id,
                );
                final languageCode = Localizations.localeOf(
                  context,
                ).languageCode;
                final label = languageCode == 'hi'
                    ? businessType.hiName
                    : languageCode == 'mr'
                    ? businessType.mrName
                    : businessType.enName;
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(label),
                  trailing: selected
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 18,
                        )
                      : null,
                  onTap: () => _toggleSelection(
                    businessType.id,
                    _selectedBusinessTypeIds,
                  ),
                  selected: selected,
                  selectedTileColor: theme.colorScheme.primary.withOpacity(
                    0.08,
                  ),
                );
              }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.isLabourPage
                  ? AppLocalizations.of(context).skillsLabel
                  : AppLocalizations.of(context).businessTypesLabel,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemBuilder: (_, index) => itemsWidget[index],
                separatorBuilder: (_, __) => const Divider(height: 0),
                itemCount: itemsWidget.length,
              ),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final availableSkillItems = widget.skills ?? const <SkillModel>[];
    final availableBusinessItems =
        widget.businessTypes ?? const <BusinessTypeModel>[];
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).advancedFilterLabel,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(AppLocalizations.of(context).clearLabel),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 108,
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: ListView(
                              padding: EdgeInsets.zero,
                              children: [
                                _buildPanelButton(
                                  AppLocalizations.of(context).locationSection,
                                  'location',
                                  theme,
                                ),
                                _buildPanelButton(
                                  AppLocalizations.of(
                                    context,
                                  ).minimumRatingLabel,
                                  'rating',
                                  theme,
                                ),
                                _buildPanelButton(
                                  AppLocalizations.of(
                                    context,
                                  ).experienceYearsLabel,
                                  'experience',
                                  theme,
                                ),
                                _buildPanelButton(
                                  widget.isLabourPage
                                      ? AppLocalizations.of(context).skillsLabel
                                      : AppLocalizations.of(
                                          context,
                                        ).businessTypesLabel,
                                  'items',
                                  theme,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  height: constraints.maxHeight,
                                  child: _buildPanelContent(
                                    theme,
                                    availableSkillItems,
                                    availableBusinessItems,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    final filter = widget.initialFilter.copyWith(
                      state: _selectedState,
                      city: _selectedCity,
                      minRating: _rating,
                      minExperience: _experience,
                      skillIds: _selectedSkillIds,
                      businessTypeIds: _selectedBusinessTypeIds,
                    );
                    Navigator.of(context).pop(filter);
                  },
                  child: SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context).applyFilterButtonLabel,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
