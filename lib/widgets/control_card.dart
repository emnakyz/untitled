import 'package:flutter/material.dart';

class ControlCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onOn;
  final VoidCallback onOff;

  const ControlCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.onOn,
    required this.onOff,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.blueGrey),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: onOn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('AÇ'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onOff,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('KAPAT'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
