import 'dart:async';

import 'package:flutter/material.dart';

import '../services/place_autocomplete_service.dart';
import '../theme/app_theme.dart';

/// Textfeld mit anklickbaren Ortsvorschlägen.
///
/// Beim Tippen werden lokale Vorschläge sofort angezeigt. Zusätzlich fragt die
/// App nach kurzer Pause Nominatim ab und zeigt echte Ortsvorschläge an.
class LocationAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? helperText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;
  final ValueChanged<PlaceSuggestion>? onSuggestionSelected;
  final bool enabled;
  final PlaceAutocompleteContext autocompleteContext;

  const LocationAutocompleteField({
    super.key,
    required this.controller,
    required this.labelText,
    this.helperText,
    required this.prefixIcon,
    this.validator,
    this.onSuggestionSelected,
    this.enabled = true,
    this.autocompleteContext = PlaceAutocompleteContext.trip,
  });

  @override
  State<LocationAutocompleteField> createState() => _LocationAutocompleteFieldState();
}

class _LocationAutocompleteFieldState extends State<LocationAutocompleteField> {
  final _service = PlaceAutocompleteService();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<PlaceSuggestion> _suggestions = const [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_scheduleSearch);
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) _scheduleSearch();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    widget.controller.removeListener(_scheduleSearch);
    _focusNode.dispose();
    super.dispose();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), _loadSuggestions);
  }

  Future<void> _loadSuggestions() async {
    if (!widget.enabled || !_focusNode.hasFocus) return;

    final query = widget.controller.text.trim();
    setState(() => _isLoading = query.length >= 2);

    final suggestions = await _service.search(
      query,
      context: widget.autocompleteContext,
    );
    if (!mounted || !_focusNode.hasFocus) return;

    setState(() {
      _suggestions = suggestions;
      _isLoading = false;
    });
  }

  void _selectSuggestion(PlaceSuggestion suggestion) {
    _debounce?.cancel();
    widget.controller.text = suggestion.valueForInput;
    widget.controller.selection = TextSelection.collapsed(offset: widget.controller.text.length);
    widget.onSuggestionSelected?.call(suggestion);
    FocusScope.of(context).unfocus();
    setState(() => _suggestions = const []);
  }

  @override
  Widget build(BuildContext context) {
    final showSuggestions = widget.enabled && _focusNode.hasFocus && _suggestions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          decoration: InputDecoration(
            labelText: widget.labelText,
            helperText: widget.helperText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : const Icon(Icons.manage_search),
          ),
          textCapitalization: TextCapitalization.words,
          validator: widget.validator,
        ),
        if (showSuggestions) ...[
          const SizedBox(height: 8),
          _SuggestionPanel(
            children: [
              for (final suggestion in _suggestions)
                _ClickableSuggestionRow(
                  icon: Icons.place_outlined,
                  title: suggestion.title,
                  subtitle: suggestion.subtitle,
                  onSelected: () => _selectSuggestion(suggestion),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  final List<Widget> children;

  const _SuggestionPanel({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(children: children),
      ),
    );
  }
}

class _ClickableSuggestionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onSelected;

  const _ClickableSuggestionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // onTapDown übernimmt den Wert sofort. Dadurch verschwinden die
        // Vorschläge nicht vorher durch Fokusverlust, was auf Desktop sonst
        // schnell wie "nicht klickbar" wirkt.
        onTapDown: (_) => onSelected(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 19),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                    if (subtitle.trim().isNotEmpty)
                      Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.mutedText, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.north_west, size: 16, color: AppTheme.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}
