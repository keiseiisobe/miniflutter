import 'package:miniflutter/widgets.dart' as miniflutter;
import 'package:flutter/material.dart' hide DefaultTextStyle;
import 'package:flutter/widgets.dart' as flutter show DefaultTextStyle;

/// Text Widget is just a wrapper of RichText which is a RenderObjectWidget.
/// see the link below for details.
/// https://docs.flutter.dev/resources/architectural-overview#rendering-and-layout:~:text=Correspondingly%2C%20the%20Image%20and%20Text%20widgets%20might%20insert%20child%20widgets%20such%20as%20RawImage%20and%20RichText%20during%20the%20build%20process.%20The%20eventual%20widget%20hierarchy%20might%20therefore%20be%20deeper%20than%20what%20the%20code%20represents%2C%20as%20in%20this%20case2%3A
class Text extends miniflutter.StatelessWidget {
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
    final defaultTextStyle = miniflutter.DefaultTextStyle.of(context);

    return RichText(
      text: TextSpan(
        text: data,
        style: style ?? defaultTextStyle.style.merge(style),
      ),
      textAlign: textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start,
      softWrap: softWrap ?? defaultTextStyle.softWrap,
      overflow: overflow ?? defaultTextStyle.overflow,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
    );
  }
}

class DefaultTextStyle extends InheritedTheme {
  const DefaultTextStyle({
    super.key,
    required this.style,
    this.textAlign,
    this.softWrap = true,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    required super.child,
  });

  const DefaultTextStyle.fallback({super.key})
    /// Default TextStyle depends on your platform.
    /// ex.
    /// The default font-family for Android,Fuchsia and Linux is Roboto.
    /// The default font-family for iOS is SF Pro Display/SF Pro Text.
    /// The default font-family for MacOS is .AppleSystemUIFont.
    /// The default font-family for Windows is Segoe UI.
    /// https://api.flutter.dev/flutter/painting/TextStyle-class.html#:~:text=The%20default%20font%2Dfamily,is%20Segoe%20UI.
    : style = const TextStyle(),
      textAlign = null,
      softWrap = true,
      overflow = TextOverflow.clip,
      maxLines = null,
      super(child: const _NullWidget());

  final TextStyle style;

  final TextAlign? textAlign;

  final bool softWrap;

  final TextOverflow overflow;

  final int? maxLines;

  @override
  Widget wrap(BuildContext context, Widget child) {
    throw UnimplementedError();
  }

  @override
  bool updateShouldNotify(DefaultTextStyle oldWidget) {
    throw UnimplementedError();
  }

  static flutter.DefaultTextStyle of(BuildContext context) {
    // BuildContext.dependOnInheritedWidgetOfExactType method require only O(1) arithmetical cost
    // to search neareset widget<T> from element tree.
    // https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html#:~:text=Calling%20this%20method%20is%20O(1)%20with%20a%20small%20constant%20factor
    return context
            .dependOnInheritedWidgetOfExactType<flutter.DefaultTextStyle>() ??
        const flutter.DefaultTextStyle.fallback();
  }
}

class _NullWidget extends StatelessWidget {
  const _NullWidget();

  @override
  Widget build(BuildContext context) {
    throw FlutterError(
      'DefaultTextStyle.of has been called, but DefaultTextStyle widget wan\'t found in widget tree.',
    );
  }
}
