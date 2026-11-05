import 'package:flutter/material.dart';
import 'package:sqlquest/core/theme/design_tokens.dart';
import 'package:sqlquest/shared/widgets/sqlquest_widgets.dart';

/// Judul layar daftar challenge beserta pil progres "x/y Selesai".
class SqlGameHeader extends StatelessWidget {
  const SqlGameHeader({
    super.key,
    required this.completedCount,
    required this.totalCount,
  });

  final int completedCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SQL Game · Query Challenge',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 2),
              Text(
                'Uji kemampuan query di sandbox terisolasi & raih XP',
                style: TextStyle(fontSize: 12.5, color: Colors.grey),
              ),
            ],
          ),
        ),
        StatusPill(
          label: '$completedCount/$totalCount Selesai',
          color: DesignTokens.successLight,
        ),
      ],
    );
  }
}
