import 'package:flutter/material.dart';

class ControlCard extends StatefulWidget {
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
  State<ControlCard> createState() => _ControlCardState();
}

class _ControlCardState extends State<ControlCard> {
  bool _isOn = false;

  void _toggle(bool value) {
    setState(() => _isOn = value);
    if (value) {
      widget.onOn();
    } else {
      widget.onOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isOn
        ? const Color(0xFF34C759)
        : Colors.grey.shade400;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: activeColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              widget.icon,
              size: 26,
              color: activeColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),
          // iOS style toggle
          Switch.adaptive(
            value: _isOn,
            onChanged: _toggle,
            activeTrackColor: const Color(0xFF34C759),
          ),
          Text(
            _isOn ? 'Açık' : 'Kapalı',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _isOn
                  ? const Color(0xFF34C759)
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
