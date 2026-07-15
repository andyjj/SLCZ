import 'package:flutter/material.dart';

/// A visual stand-in for a banner ad slot. No ad network is wired in yet —
/// swap the body of this widget for a real ad SDK widget once an ad
/// network account (e.g. AdMob) is set up.
class AdBannerPlaceholder extends StatelessWidget {
  const AdBannerPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
      ),
      alignment: Alignment.center,
      child: Text(
        'Advertisement',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
