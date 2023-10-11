import 'package:flutter/material.dart';
import 'package:goodie/widgets/gradient_circular_progress.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: GradientCircularProgressIndicator(),
      ),
    );
  }
}
