import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Shared layout constants so every screen lines up.
const kPagePadding = EdgeInsets.fromLTRB(24, 24, 24, 96);
const kSectionGap = SizedBox(height: 24);

/// Consistent empty state: icon, headline, one line of guidance. Always
/// centered in the content area, never floating at the top of a list.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: scheme.outline),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurface.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }
}

/// Small (i) button that opens a plain-language explanation. Use it wherever
/// a term or threshold isn't self-evident.
class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.title, required this.body});

  final String title;

  /// Paragraphs, shown in order.
  final List<String> body;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.info_outline, size: 16),
      tooltip: title,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
      onPressed: () => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.info_outline),
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final paragraph in body)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(paragraph,
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
          actions: [
            FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it')),
          ],
        ),
      ),
    );
  }
}

/// Section label with an icon, used above every card group.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title,
      {super.key, required this.icon, this.action, this.info});

  final String title;
  final IconData icon;
  final Widget? action;

  /// Optional (i) explanation shown next to the title.
  final InfoButton? info;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (info != null) ...[const SizedBox(width: 4), info!],
          if (action != null) ...[const Spacer(), action!],
        ],
      ),
    );
  }
}

/// Headline number tile used on the dashboard and budget screens.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.note,
    this.info,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final String? note;
  final InfoButton? info;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 16, color: color),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(label,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  ?info,
                ],
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: color)),
              if (note != null)
                Text(note!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Label/value line used inside detail panes.
class DetailRow extends StatelessWidget {
  const DetailRow(this.label, this.value, {super.key, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7))),
          ),
          Text(value,
              style: TextStyle(fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// Text field with consistent spacing for dialogs. Pressing Enter submits
/// the dialog — by default that means the same thing as clicking Save.
class DialogField extends StatelessWidget {
  const DialogField(this.controller, this.label,
      {super.key,
      this.obscure = false,
      this.autofocus = false,
      this.helper,
      this.onSubmitted});

  final TextEditingController controller;
  final String label;
  final bool obscure;
  final bool autofocus;
  final String? helper;

  /// Runs on Enter. Defaults to closing the dialog with a `true` result,
  /// which every edit dialog treats as "save".
  final VoidCallback? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        autofocus: autofocus,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) =>
            (onSubmitted ?? () => Navigator.of(context).pop(true))(),
        decoration: InputDecoration(
          labelText: label,
          helperText: helper,
          helperMaxLines: 2,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/// Makes Enter trigger [onSubmit] anywhere inside [child], so a dialog can
/// be saved from a dropdown or checkbox, not just from a text field.
class SubmitOnEnter extends StatelessWidget {
  const SubmitOnEnter({super.key, required this.onSubmit, required this.child});

  final VoidCallback onSubmit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.enter): onSubmit,
        const SingleActivator(LogicalKeyboardKey.numpadEnter): onSubmit,
      },
      child: FocusScope(child: child),
    );
  }
}
