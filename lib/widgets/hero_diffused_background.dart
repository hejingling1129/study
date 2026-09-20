import 'package:flutter/material.dart';

import 'hero_diffused_background_stub.dart'
    if (dart.library.html) 'hero_diffused_background_web.dart' as impl;

class HeroDiffusedBackground extends StatelessWidget {
  const HeroDiffusedBackground({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return impl.buildHeroDiffusedBackground(height);
  }
}
