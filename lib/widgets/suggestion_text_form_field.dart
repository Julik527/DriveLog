import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Normales TextFormField mit anklickbaren lokalen Vorschlägen.
///
/// Beispiel: Marke, Modell, Kraftstoffart, Reifen, Öl oder Problem-Bauteil.
class SuggestionTextFormField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final String? helperText;
  final String? suffixText;
  final IconData prefixIcon;
  final List<String> suggestions;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSuggestionSelected;

  const SuggestionTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.suggestions,
    this.hintText,
    this.helperText,
    this.suffixText,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.validator,
    this.onSuggestionSelected,
  });

  @override
  State<SuggestionTextFormField> createState() => _SuggestionTextFormFieldState();
}

class _SuggestionTextFormFieldState extends State<SuggestionTextFormField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _focusNode.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant SuggestionTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestions != widget.suggestions && mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focusNode.removeListener(_refresh);
    _focusNode.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<String> get _visibleSuggestions {
    final query = widget.controller.text.trim().toLowerCase();
    final source = query.isEmpty
        ? widget.suggestions
        : widget.suggestions.where((item) => item.toLowerCase().contains(query)).toList();
    return source.take(8).toList();
  }

  void _useSuggestion(String value) {
    widget.controller.text = value;
    widget.controller.selection = TextSelection.collapsed(offset: value.length);
    widget.onSuggestionSelected?.call(value);
    FocusScope.of(context).unfocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final visibleSuggestions = _visibleSuggestions;
    final showSuggestions = _focusNode.hasFocus && visibleSuggestions.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            suffixText: widget.suffixText,
            prefixIcon: Icon(widget.prefixIcon),
            suffixIcon: const Icon(Icons.auto_awesome),
          ),
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          validator: widget.validator,
        ),
        if (showSuggestions) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: visibleSuggestions.map((suggestion) {
              return _ClickableSuggestionChip(
                label: suggestion,
                onSelected: () => _useSuggestion(suggestion),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}

class _ClickableSuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onSelected;

  const _ClickableSuggestionChip({
    required this.label,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Direkt bei Pointer-Down übernehmen, damit der Fokuswechsel das Chip
        // nicht vorher ausblendet.
        onTapDown: (_) => onSelected(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppTheme.gold.withOpacity(0.45)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, size: 15, color: AppTheme.gold),
              const SizedBox(width: 7),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
