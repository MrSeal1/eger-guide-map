import 'package:flutter/material.dart';

class CustomMarkerWidget extends StatelessWidget {
  final IconData icon;
  final Color backgroundColor;

  const CustomMarkerWidget({
    super.key,
    required this.icon,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(45),
            blurRadius: 4,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: backgroundColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}