import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const MenuItem({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 62,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFECE7E7),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFC1C1C1)),
              ),
              child: Center(
                child: Image.asset(
                  icon,
                  width: 24,
                  height: 24,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w300,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
