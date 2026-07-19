import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  final String course;
  final String title;
  final String opened;
  final String due;

  const AssignmentCard({
    Key? key,
    required this.course,
    required this.title,
    required this.opened,
    required this.due,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E7E7),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF17AA2D)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            course,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.26,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Opened:',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                opened,
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Text(
                'Due:',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                due,
                style: const TextStyle(
                  fontSize: 10,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}