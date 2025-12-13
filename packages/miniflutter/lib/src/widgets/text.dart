import 'package:flutter/widgets.dart';

class Text extends StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.softWrap,
    this.overflow,
    this.maxLines,
  });

  final String data;

  final TextStyle? style;

  final TextAlign? textAlign;

  final bool? softWrap;

  final TextOverflow? overflow;

  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    return RichText(
      text: TextSpan(text: data),
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      softWrap: softWrap ?? defaultTextStyle.softWrap,
      overflow: overflow ?? defaultTextStyle.overflow,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
    );
  }
}
