import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String time;
  final String title;
  final String room;
  final String type;

  const ScheduleCard({
    Key? key,
    required this.time,
    required this.title,
    required this.room,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 29,
          child: Text(
            time,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w300,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE7E7E7),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: const Color(0xFF5B98F4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.28,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF89AEFE),
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(color: const Color(0xFF60A6D8)),
                  ),
                  child: Text(
                    type,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 10,
                      color: Colors.black,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room,
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
          ),
        ),
      ],
    );
  }
}