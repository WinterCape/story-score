import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  final String name;
  final double size;
  final Color? color;

  const CustomIcon(this.name, {super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final path =
        'assets/images/icons/${brightness == Brightness.dark ? 'dark' : 'light'}/ic_$name.png';
    return Image.asset(
      path,
      width: size,
      height: size,
      color: color,
      errorBuilder: (_, _, _) => Icon(Icons.help_outline, size: size),
    );
  }
}
