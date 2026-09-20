import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
const _viewType = 'hero-diffused-bg-v4';

bool _viewRegistered = false;

Widget buildHeroDiffusedBackground(double height) {
  _ensureViewRegistered();
  return SizedBox(
    height: height,
    width: double.infinity,
    child: const HtmlElementView(viewType: _viewType),
  );
}

void _ensureViewRegistered() {
  if (_viewRegistered) return;
  _viewRegistered = true;

  ui_web.platformViewRegistry.registerViewFactory(
    _viewType,
    (int viewId) => _createElement(),
  );
}

html.Element _createElement() {
  // 垂直 alpha：顶部实、向下逐步透明，溶入 pageBg，无硬切边。
  const maskFade = 'linear-gradient(to bottom, '
      '#000 0%, '
      'rgba(0,0,0,0.97) 12%, '
      'rgba(0,0,0,0.88) 24%, '
      'rgba(0,0,0,0.72) 36%, '
      'rgba(0,0,0,0.52) 48%, '
      'rgba(0,0,0,0.32) 60%, '
      'rgba(0,0,0,0.16) 72%, '
      'rgba(0,0,0,0.06) 84%, '
      'rgba(0,0,0,0.015) 93%, '
      'transparent 100%)';

  final root = html.DivElement()
    ..style.setProperty('position', 'relative')
    ..style.setProperty('width', '100%')
    ..style.setProperty('height', '100%')
    ..style.setProperty('overflow', 'hidden')
    ..style.setProperty('pointer-events', 'none')
    ..style.setProperty('background', 'transparent');

  final colorField = html.DivElement()
    ..style.setProperty('position', 'absolute')
    ..style.setProperty('inset', '0')
    ..style.setProperty(
      'background',
      'linear-gradient(135deg, '
      '#5b58d8 0%, '
      '#7a6de6 18%, '
      '#b088e8 38%, '
      'rgba(176,136,232,0.72) 52%, '
      'rgba(176,136,232,0.38) 66%, '
      'rgba(176,136,232,0.14) 80%, '
      'rgba(248,247,252,0) 100%)',
    )
    ..style.setProperty('-webkit-mask-image', maskFade)
    ..style.setProperty('mask-image', maskFade)
    ..style.setProperty('-webkit-mask-size', '100% 100%')
    ..style.setProperty('mask-size', '100% 100%');

  final topGlow = html.DivElement()
    ..style.setProperty('position', 'absolute')
    ..style.setProperty('top', '-18%')
    ..style.setProperty('left', '-12%')
    ..style.setProperty('width', '70%')
    ..style.setProperty('height', '58%')
    ..style.setProperty(
      'background',
      'radial-gradient(ellipse at 20% 10%, '
      'rgba(91,88,216,0.95) 0%, '
      'rgba(122,109,230,0.45) 42%, '
      'transparent 74%)',
    )
    ..style.setProperty('filter', 'blur(22px)')
    ..style.setProperty('-webkit-filter', 'blur(22px)')
    ..style.setProperty('-webkit-mask-image', maskFade)
    ..style.setProperty('mask-image', maskFade);

  final midBloom = html.DivElement()
    ..style.setProperty('position', 'absolute')
    ..style.setProperty('top', '8%')
    ..style.setProperty('right', '-18%')
    ..style.setProperty('width', '72%')
    ..style.setProperty('height', '62%')
    ..style.setProperty(
      'background',
      'radial-gradient(ellipse at 70% 20%, '
      'rgba(176,136,232,0.7) 0%, '
      'rgba(176,136,232,0.22) 48%, '
      'transparent 78%)',
    )
    ..style.setProperty('filter', 'blur(28px)')
    ..style.setProperty('-webkit-filter', 'blur(28px)')
    ..style.setProperty('-webkit-mask-image', maskFade)
    ..style.setProperty('mask-image', maskFade);

  final blurDiffuse = html.DivElement()
    ..style.setProperty('position', 'absolute')
    ..style.setProperty('left', '-12%')
    ..style.setProperty('right', '-12%')
    ..style.setProperty('top', '28%')
    ..style.setProperty('height', '62%')
    ..style.setProperty(
      'background',
      'linear-gradient(180deg, '
      'rgba(176,136,232,0.42) 0%, '
      'rgba(176,136,232,0.18) 35%, '
      'rgba(248,247,252,0.08) 70%, '
      'transparent 100%)',
    )
    ..style.setProperty('filter', 'blur(26px)')
    ..style.setProperty('-webkit-filter', 'blur(26px)');

  root.children.addAll([colorField, topGlow, midBloom, blurDiffuse]);
  return root;
}
