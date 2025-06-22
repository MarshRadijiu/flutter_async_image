import 'dart:async';
import 'dart:ui' show Codec;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:octo_image/octo_image.dart';

part 'never.image_provider.dart';

/// A Future that resolves to an [ImageProvider].
typedef AsyncImageProvider<T extends Object> = Future<ImageProvider<T>>;

class AsyncImage extends StatelessWidget {
  /// The image that should be shown.
  final AsyncImageProvider image;

  /// Optional builder to further customize the display of the image.
  final Widget Function(BuildContext context, Widget child)? imageBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final Widget Function(BuildContext context)? placeholderBuilder;

  /// Widget displayed while the target [imageUrl] is loading.
  final Widget Function(BuildContext context, ImageChunkEvent? progress)?
  progressIndicatorBuilder;

  /// Widget displayed while the target [imageUrl] failed loading.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  )?
  errorBuilder;

  /// The duration of the fade-in animation for the [placeholderBuilder].
  final Duration placeholderFadeInDuration;

  /// The duration of the fade-out animation for the [placeholderBuilder].
  final Duration fadeOutDuration;

  /// The curve of the fade-out animation for the [placeholderBuilder].
  final Curve fadeOutCurve;

  /// The duration of the fade-in animation for the [imageUrl].
  final Duration fadeInDuration;

  /// The curve of the fade-in animation for the [imageUrl].
  final Curve fadeInCurve;

  /// If non-null, require the image to have this width.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double? width;

  /// If non-null, require the image to have this height.
  ///
  /// If null, the image will pick a size that best preserves its intrinsic
  /// aspect ratio. This may result in a sudden change if the size of the
  /// placeholder widget does not match that of the target image. The size is
  /// also affected by the scale factor.
  final double? height;

  /// How to inscribe the image into the space allocated during layout.
  ///
  /// The default varies based on the other fields. See the discussion at
  /// [paintImage].
  final BoxFit? fit;

  /// How to align the image within its bounds.
  ///
  /// The alignment aligns the given position in the image to the given position
  /// in the layout bounds. For example, a [Alignment] alignment of (-1.0,
  /// -1.0) aligns the image to the top-left corner of its layout bounds, while
  /// a [Alignment] alignment of (1.0, 1.0) aligns the bottom right of the
  /// image with the bottom right corner of its layout bounds. Similarly, an
  /// alignment of (0.0, 1.0) aligns the bottom middle of the image with the
  /// middle of the bottom edge of its layout bounds.
  ///
  /// If the [alignment] is [TextDirection]-dependent (i.e. if it is a
  /// [AlignmentDirectional]), then an ambient [Directionality] widget
  /// must be in scope.
  ///
  /// Defaults to [Alignment.center].
  ///
  /// See also:
  ///
  ///  * [Alignment], a class with convenient constants typically used to
  ///    specify an [AlignmentGeometry].
  ///  * [AlignmentDirectional], like [Alignment] for specifying alignments
  ///    relative to text direction.
  final AlignmentGeometry alignment;

  /// How to paint any portions of the layout bounds not covered by the image.
  final ImageRepeat repeat;

  /// Whether to paint the image in the direction of the [TextDirection].
  ///
  /// If this is true, then in [TextDirection.ltr] contexts, the image will be
  /// drawn with its origin in the top left (the "normal" painting direction for
  /// children); and in [TextDirection.rtl] contexts, the image will be drawn
  /// with a scaling factor of -1 in the horizontal direction so that the origin
  /// is in the top right.
  ///
  /// This is occasionally used with children in right-to-left environments, for
  /// children that were designed for left-to-right locales. Be careful, when
  /// using this, to not flip children with integral shadows, text, or other
  /// effects that will look incorrect when flipped.
  ///
  /// If this is true, there must be an ambient [Directionality] widget in
  /// scope.
  final bool matchTextDirection;

  /// If non-null, this color is blended with each image pixel using
  /// [colorBlendMode].
  final Color? color;

  /// Used to combine [color] with this image.
  ///
  /// The default is [BlendMode.srcIn]. In terms of the blend mode, [color] is
  /// the source and this image is the destination.
  ///
  /// See also:
  ///
  ///  * [BlendMode], which includes an illustration of the effect of each
  ///  blend mode.
  final BlendMode? colorBlendMode;

  /// Target the interpolation quality for image scaling.
  ///
  /// If not given a value, defaults to FilterQuality.low.
  final FilterQuality filterQuality;

  /// Whether to continue showing the old image (true), or briefly show the
  /// placeholder (false), when the image provider changes.
  final bool gaplessPlayback;

  /// If non-null, the width of the image cache.
  final int? memCacheWidth;

  /// If non-null, the height of the image cache.
  final int? memCacheHeight;

  /// Creates an AsyncImage that displays an image. The [image] is a [Future]
  /// that resolves to an [ImageProvider]. The AsyncImage should work with any
  /// [ImageProvider].
  const AsyncImage({
    super.key,
    required this.image,
    this.imageBuilder,
    this.placeholderBuilder,
    this.progressIndicatorBuilder,
    this.errorBuilder,
    Duration? fadeOutDuration,
    Curve? fadeOutCurve,
    Duration? fadeInDuration,
    Curve? fadeInCurve,
    this.width,
    this.height,
    this.fit,
    AlignmentGeometry? alignment,
    ImageRepeat? repeat,
    bool? matchTextDirection,
    this.color,
    FilterQuality? filterQuality,
    this.colorBlendMode,
    Duration? placeholderFadeInDuration,
    bool? gaplessPlayback,
    this.memCacheWidth,
    this.memCacheHeight,
  }) : fadeOutDuration = fadeOutDuration ?? const Duration(milliseconds: 1000),
       fadeOutCurve = fadeOutCurve ?? Curves.easeOut,
       fadeInDuration = fadeInDuration ?? const Duration(milliseconds: 500),
       fadeInCurve = fadeInCurve ?? Curves.easeIn,
       alignment = alignment ?? Alignment.center,
       repeat = repeat ?? ImageRepeat.noRepeat,
       matchTextDirection = matchTextDirection ?? false,
       filterQuality = filterQuality ?? FilterQuality.low,
       placeholderFadeInDuration = placeholderFadeInDuration ?? Duration.zero,
       gaplessPlayback = gaplessPlayback ?? false;

  /// Creates an AsyncImage that displays an image with a predefined [OctoSet].
  /// The [image] is a [Future] that resolves to an [ImageProvider]. The
  /// AsyncImage should work with any [ImageProvider].
  ///
  /// The [octoSet] should be set and contains all the information for the
  /// placeholder, error and image transformations.
  AsyncImage.fromSet({
    super.key,
    required this.image,
    required OctoSet octoSet,
    Duration? fadeOutDuration,
    Curve? fadeOutCurve,
    Duration? fadeInDuration,
    Curve? fadeInCurve,
    this.width,
    this.height,
    this.fit,
    AlignmentGeometry? alignment,
    ImageRepeat? repeat,
    bool? matchTextDirection,
    this.color,
    FilterQuality? filterQuality,
    this.colorBlendMode,
    Duration? placeholderFadeInDuration,
    bool? gaplessPlayback,
    this.memCacheWidth,
    this.memCacheHeight,
  }) : imageBuilder = octoSet.imageBuilder,
       placeholderBuilder = octoSet.placeholderBuilder,
       progressIndicatorBuilder = octoSet.progressIndicatorBuilder,
       errorBuilder = octoSet.errorBuilder,
       fadeOutDuration = fadeOutDuration ?? const Duration(milliseconds: 1000),
       fadeOutCurve = fadeOutCurve ?? Curves.easeOut,
       fadeInDuration = fadeInDuration ?? const Duration(milliseconds: 500),
       fadeInCurve = fadeInCurve ?? Curves.easeIn,
       alignment = alignment ?? Alignment.center,
       repeat = repeat ?? ImageRepeat.noRepeat,
       matchTextDirection = matchTextDirection ?? false,
       filterQuality = filterQuality ?? FilterQuality.low,
       placeholderFadeInDuration = placeholderFadeInDuration ?? Duration.zero,
       gaplessPlayback = gaplessPlayback ?? false;

  @override
  Widget build(BuildContext context) {
    final defaultProvider = _NeverImageProvider();

    return FutureBuilder(
      key: ValueKey(key ?? image),
      future: image,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          defaultProvider.error(snapshot.error!, snapshot.stackTrace);
        }

        return OctoImage(
          image: snapshot.data ?? defaultProvider,
          imageBuilder: imageBuilder,
          placeholderBuilder: placeholderBuilder,
          progressIndicatorBuilder: progressIndicatorBuilder,
          errorBuilder: errorBuilder,
          placeholderFadeInDuration: placeholderFadeInDuration,
          fadeOutDuration: fadeOutDuration,
          fadeOutCurve: fadeOutCurve,
          fadeInDuration: fadeInDuration,
          fadeInCurve: fadeInCurve,
          width: width,
          height: height,
          fit: fit,
          alignment: alignment,
          repeat: repeat,
          matchTextDirection: matchTextDirection,
          color: color,
          colorBlendMode: colorBlendMode,
          filterQuality: filterQuality,
          gaplessPlayback: gaplessPlayback,
          memCacheWidth: memCacheWidth,
          memCacheHeight: memCacheHeight,
        );
      },
      initialData: defaultProvider,
    );
  }
}
