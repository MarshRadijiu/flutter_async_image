part of 'async_image.widget.dart';

/// A [ImageProvider] that never loads an image. The only way to complete is by
/// calling [error].
///
/// This is used as a placeholder image provider in the [AsyncImage] widget.
class _NeverImageProvider extends ImageProvider<_NeverImageProvider> {
  static const String name = "NeverImageProvider";
  final Completer<Codec> completer = Completer<Codec>();
  final double scale = 1.0;

  @Deprecated("loadBuffer is deprecated, use loadImage instead")
  @override
  ImageStreamCompleter loadBuffer(
    _NeverImageProvider key,
    DecoderBufferCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: scale,
      debugLabel: name,
      informationCollector: () => <DiagnosticsNode>[ErrorDescription(name)],
    );
  }

  @override
  ImageStreamCompleter loadImage(
    _NeverImageProvider key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: scale,
      debugLabel: name,
      informationCollector: () => <DiagnosticsNode>[ErrorDescription(name)],
    );
  }

  Future<Codec> _loadAsync(_NeverImageProvider key) async {
    assert(key == this);
    return completer.future;
  }

  @override
  Future<_NeverImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_NeverImageProvider>(this);
  }

  @override
  bool operator ==(Object other) {
    if (other is _NeverImageProvider) {
      return other.completer == completer;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(completer, completer.hashCode);

  @override
  String toString() => '$name($completer)';

  /// Complete the never ending image provider with an error.
  void error(Object error, [StackTrace? stackTrace]) {
    if (!completer.isCompleted) {
      completer.completeError(error, stackTrace);
    }
  }
}
