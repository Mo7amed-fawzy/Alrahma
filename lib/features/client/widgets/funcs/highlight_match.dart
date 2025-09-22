import 'package:alrahma/core/utils/app_colors.dart';
import 'package:alrahma/core/utils/custom_text_styles.dart';
import 'package:flutter/material.dart';

Text highlightMatch(String text, String? query, {TextStyle? style}) {
  final effectiveStyle = style ?? CustomTextStyles.cairoRegular16;

  if (query == null || query.isEmpty) {
    return Text(
      text,
      style: effectiveStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  final lowerText = text.toLowerCase();
  final lowerQuery = query.toLowerCase();

  final spans = <TextSpan>[];
  int start = 0;

  while (true) {
    final index = lowerText.indexOf(lowerQuery, start);
    if (index < 0) {
      spans.add(TextSpan(text: text.substring(start)));
      break;
    }

    if (index > start) {
      spans.add(TextSpan(text: text.substring(start, index)));
    }

    spans.add(
      TextSpan(
        text: text.substring(index, index + query.length),
        style: effectiveStyle.copyWith(
          backgroundColor: AppColors.warningYellow.withOpacity(0.5),
        ),
      ),
    );

    start = index + query.length;
  }

  return Text.rich(
    TextSpan(style: effectiveStyle, children: spans),
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
  );
}
