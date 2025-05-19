import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatelessWidget {
  const ElevatedButtonWidget({
    super.key,
    required this.label,
    required this.onTap,
  });

  final Widget label;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Color(0xFFEB50A8).withAlpha(200),
          foregroundColor: Theme.of(context).colorScheme.onSurface,
        ),
        child: label,
      ),
    );
  }
}

class TextButtonWidget extends StatelessWidget {
  const TextButtonWidget({super.key, required this.label, required this.onTap});
  final Widget label;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      child: label,
    );
  }
}

class OutlinedButtonWidget extends StatelessWidget {
  const OutlinedButtonWidget({
    super.key,
    required this.label,
    required this.onTap,
  });
  final Widget label;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Color(0xFFEB50A8)),
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      onPressed: onTap,
      child: label,
    );
  }
}
