import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/document_model.dart';
import '../services/supabase_service.dart';
import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../widgets/document_list_tile.dart';
import '../widgets/empty_state_view.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<DocumentModel> _results = [];
  bool _isLoading = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _performSearch('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isLoading = true);
    final service = Provider.of<SupabaseService>(context, listen: false);

    List<DocumentModel> list;
    if (query.trim().isEmpty) {
      list = await service.getDocuments(onlyPublished: true);
    } else {
      list = await service.searchDocuments(query.trim());
    }

    if (mounted) {
      setState(() {
        _results = list;
        _isLoading = false;
      });
    }
  }

  List<DocumentModel> get _filteredResults {
    if (_selectedFilter == 'all') return _results;
    return _results
        .where((d) => d.docType.toLowerCase() == _selectedFilter.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    final filterOptions = [
      {'key': 'all', 'label': localizations.translate('all')},
      {'key': 'cours', 'label': localizations.translate('cours')},
      {'key': 'td', 'label': localizations.translate('td')},
      {'key': 'tp', 'label': localizations.translate('tp')},
      {'key': 'examen', 'label': localizations.translate('examens')},
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: localizations.translate('search_placeholder'),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            contentPadding: EdgeInsets.zero,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onChanged: (val) {
            _performSearch(val);
          },
        ),
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: filterOptions.map((f) {
                final isSelected = _selectedFilter == f['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0, left: 8.0),
                  child: ChoiceChip(
                    label: Text(f['label']!),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = f['key']!;
                      });
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          // Search Results
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredResults.isEmpty
                    ? EmptyStateView(
                        icon: Icons.search_off_rounded,
                        title: localizations.translate('no_results_found'),
                        description:
                            'جرب البحث بكلمات أخرى أو تغيير نوع الملفات المحددة.',
                      )
                    : Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 950),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredResults.length,
                            itemBuilder: (context, index) {
                              return DocumentListTile(
                                document: _filteredResults[index],
                              );
                            },
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
