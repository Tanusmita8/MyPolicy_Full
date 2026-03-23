import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  const InfoCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {

        final width = constraints.maxWidth;

        /// ✅ RESPONSIVE TEXT SCALE
        double titleSize;
        double valueSize;
        double subtitleSize;
        double iconSize;
        double padding;

        if (width > 360) {
          titleSize = 15;
          valueSize = 24;
          subtitleSize = 12;
          iconSize = 26;
          padding = 22;
        } else {
          titleSize = 13;
          valueSize = 20;
          subtitleSize = 11;
          iconSize = 22;
          padding = 18;
        }

        return Container(

          /// ⭐ VERY IMPORTANT
          /// Prevents giant blue cards on tablets / folds
          constraints: const BoxConstraints(
            minHeight: 140,
            maxHeight: 180,
          ),

          padding: EdgeInsets.all(padding),

          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 6),
              )
            ],
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            /// ⭐ REMOVE SPACE BETWEEN (this caused stretching)
            mainAxisSize: MainAxisSize.min,

            children: [

              /// ICON
              Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),

              const SizedBox(height: 16),

              /// TITLE
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: titleSize,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 6),

              /// VALUE
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              /// SUBTITLE
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: subtitleSize,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
