import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double progress;
  final Color color;
  final double height;

  const ProgressBar({
    Key? key,
    required this.progress,
    required this.color,
    this.height = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.6 * progress.clamp(0.0, 1.0),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ],
      ),
    );
  }
}
