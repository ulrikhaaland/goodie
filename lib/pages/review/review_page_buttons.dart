import 'package:flutter/material.dart';
import 'package:goodie/main.dart';

import '../../widgets/gradient_button.dart';

class ReviewPageButtons extends StatefulWidget {
  final VoidCallback onLeftPressed;
  final VoidCallback onRightPressed;
  final String rightButtonText;
  final bool? canSubmit;
  final bool isSubmit;
  final bool hideLeftButton;
  final bool hideRightButton;

  const ReviewPageButtons({
    Key? key,
    required this.onLeftPressed,
    required this.onRightPressed,
    required this.isSubmit,
    this.rightButtonText = "Neste",
    required this.canSubmit,
    required this.hideLeftButton,
    required this.hideRightButton,
  }) : super(key: key);

  @override
  State<ReviewPageButtons> createState() => _ReviewPageButtonsState();
}

class _ReviewPageButtonsState extends State<ReviewPageButtons> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.hideLeftButton) const Spacer(),
        if (!widget.hideLeftButton) _buildLeftButton(),
        if (!widget.hideRightButton) _buildRightButton(context),
      ],
    );
  }

  Widget _buildRightButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GradientButton(
        onPressed: widget.canSubmit == true ? widget.onRightPressed : null,
        label: widget.rightButtonText,
        isEnabled: widget.canSubmit == true,
      ),
    );
  }

  ButtonStyle _rightButtonStyle() {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(8.0),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      backgroundColor: MaterialStateProperty.resolveWith<Color>(
        (Set<MaterialState> states) {
          if (widget.canSubmit == false) {
            return Colors.grey.shade300; // Disabled color
          } else {
            return primaryColor; // Regular color
          }
        },
      ),
    );
  }

  Widget _buildLeftButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: GestureDetector(
        onTap: widget.onLeftPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 32.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey.shade300],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 8),
                blurRadius: 8,
              ),
            ],
            border: Border.all(color: Colors.grey[600]!, width: 1),
          ),
          child: Center(
            child: Text(
              "Tilbake",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
