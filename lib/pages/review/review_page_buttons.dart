import 'package:flutter/material.dart';

class ReviewPageButtons extends StatefulWidget {
  final VoidCallback onLeftPressed;
  final VoidCallback onRightPressed;
  final String rightButtonText;
  final bool? canSubmit;
  final bool isSubmit;

  const ReviewPageButtons({
    Key? key,
    required this.onLeftPressed,
    required this.onRightPressed,
    required this.isSubmit,
    this.rightButtonText = "Neste",
    required this.canSubmit,
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
        _buildLeftButton(),
        _buildRightButton(context),
      ],
    );
  }

  Widget _buildRightButton(BuildContext context) {
    if (widget.canSubmit == true) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ElevatedButton(
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(8.0), // Increased shadow depth
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Rounded corners
              ),
            ),
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey.shade300; // Disabled color
                }
                return Theme.of(context).colorScheme.secondary;
              },
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled)) {
                  return Colors.grey.shade600; // Foreground when disabled
                }
                return Colors.white; // Regular foreground color
              },
            ),
          ),
          onPressed: widget.canSubmit! ? widget.onRightPressed : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              mainAxisSize: MainAxisSize
                  .min, // To ensure the Row takes only as much space as required
              children: [
                const Icon(Icons.check), // An icon for emphasis
                const SizedBox(width: 8.0), // Gap between icon and text
                Text(
                  widget.rightButtonText,
                  style: const TextStyle(
                    fontSize: 18, // Slightly larger font size
                    fontWeight: FontWeight.bold, // Bold font weight
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: _rightButtonStyle(),
          onPressed: widget.onRightPressed,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
            child: Text(
              widget.rightButtonText,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
        ),
      );
    }
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
          if (states.contains(MaterialState.disabled)) {
            return Colors.grey.shade300; // Disabled color
          }
          return Theme.of(context)
              .colorScheme
              .secondary; // Use secondary color from colorScheme
        },
      ),
    );
  }

  Widget _buildLeftButton() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        style: _leftButtonStyle(),
        onPressed: widget.onLeftPressed,
        child: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
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
    );
  }

  ButtonStyle _leftButtonStyle() {
    return ButtonStyle(
      elevation: MaterialStateProperty.all(8.0),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.black),
        ),
      ),
      backgroundColor: MaterialStateProperty.all(Colors.white),
    );
  }
}
