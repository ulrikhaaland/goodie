import 'package:flutter/material.dart';

import '../main.dart';

class GradientButton extends StatelessWidget {
  final void Function()? onPressed;
  final String label;
  final bool isEnabled;
  final EdgeInsetsGeometry? padding;

  const GradientButton({
    Key? key,
    required this.onPressed,
    required this.label,
    this.isEnabled = true,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: isEnabled ? 3 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            gradient: isEnabled
                ? const LinearGradient(
                    colors: [primaryColor, accent1Color],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
            color: isEnabled ? null : Colors.grey.shade300,
          ),
          padding: padding ??
              const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                  color: isEnabled ? Colors.white : Colors.grey.shade700,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}
