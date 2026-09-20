import 'dart:ui';

import 'package:flutter/material.dart';

Widget buildHeroDiffusedBackground(double height) {
  return SizedBox(
    height: height,
    width: double.infinity,
    child: Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff000000),
                Color(0xf7000000),
                Color(0xe0000000),
                Color(0xb8000000),
                Color(0x85000000),
                Color(0x51000000),
                Color(0x28000000),
                Color(0x0f000000),
                Color(0x00000000),
              ],
              stops: [0.0, 0.12, 0.24, 0.36, 0.48, 0.60, 0.72, 0.86, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff5b58d8),
                    Color(0xff7a6de6),
                    Color(0xffb088e8),
                    Color(0xb8b088e8),
                    Color(0x5eb088e8),
                    Color(0x00f8f7fc),
                  ],
                  stops: [0.0, 0.18, 0.38, 0.55, 0.74, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: -40,
          right: -40,
          top: height * 0.22,
          height: height * 0.7,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x6bb088e8),
                    Color(0x22b088e8),
                    Color(0x00f8f7fc),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
