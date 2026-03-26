import 'package:flutter/material.dart';

class AnimatedWaveText extends StatelessWidget {
  final String text;
  final int activeIndex;
  final TextStyle style;
  final Duration duration;

  const AnimatedWaveText({
    super.key,
    required this.text,
    required this.activeIndex,
    required this.style,
    this.duration = const Duration(milliseconds: 220),
  });

  @override
  Widget build(BuildContext context) {
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    final characters = text.split('');
    final animatedCharacters = characters.where((character) => character != ' ');
    final animatedCount = animatedCharacters.length;

    if (animatedCount == 0) {
      return Text(text, style: style);
    }

    final baseColor =
        style.color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    final currentIndex = activeIndex % animatedCount;
    var visibleCharacterIndex = 0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: characters.map((character) {
        if (character == ' ') {
          return Text(character, style: style);
        }

        final distance = (visibleCharacterIndex - currentIndex).abs();
        final isPrimaryWave = distance == 0;
        final isSecondaryWave = distance == 1;
        final isTertiaryWave = distance == 2;
        final offsetY = isPrimaryWave
            ? -14.0
            : (isSecondaryWave ? -8.0 : (isTertiaryWave ? -3.0 : 0.0));
        final scale = isPrimaryWave
            ? 1.14
            : (isSecondaryWave ? 1.07 : (isTertiaryWave ? 1.02 : 1.0));
        final opacity = isPrimaryWave
            ? 1.0
            : (isSecondaryWave ? 0.92 : (isTertiaryWave ? 0.82 : 0.62));

        visibleCharacterIndex += 1;

        return AnimatedContainer(
          duration: duration,
          curve: Curves.easeInOut,
          transform: Matrix4.translationValues(0, offsetY, 0),
          child: AnimatedScale(
            duration: duration,
            curve: Curves.easeInOut,
            scale: scale,
            child: AnimatedDefaultTextStyle(
              duration: duration,
              curve: Curves.easeInOut,
              style: style.copyWith(
                color: baseColor.withValues(alpha: opacity),
                fontWeight: isPrimaryWave ? FontWeight.w700 : style.fontWeight,
              ),
              child: Text(character),
            ),
          ),
        );
      }).toList(),
    );
  }
}
