import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A Future that resolves to an [ImageProvider].
typedef AsyncImageProviderCallback<T extends Object> =
    Future<ImageProvider<T>> Function();

/// A [ImageProvider] that loads an image from a future.
class AsyncImageProvider extends ImageProvider<Object> {
  static const String name = "AsyncImageProvider";
  final AsyncImageProviderCallback provider;

  ImageProvider<Object>? _provider;

  AsyncImageProvider(this.provider);

  @Deprecated("loadBuffer is deprecated, use loadImage instead")
  @override
  ImageStreamCompleter loadBuffer(Object key, DecoderBufferCallback decode) {
    return AsyncImageStreamCompleter(
      _cache().then((provider) => provider.loadBuffer(key, decode)),
      informationCollector: () => <DiagnosticsNode>[ErrorDescription(name)],
    );
  }

  @override
  ImageStreamCompleter loadImage(Object key, ImageDecoderCallback decode) {
    return AsyncImageStreamCompleter(
      _cache().then((provider) => provider.loadImage(key, decode)),
      informationCollector: () => <DiagnosticsNode>[ErrorDescription(name)],
    );
  }

  @override
  Future<Object> obtainKey(ImageConfiguration configuration) {
    return provider().then((provider) {
      _provider = provider;
      return provider.obtainKey(configuration);
    });
  }

  Future<ImageProvider> _cache() => Future.value(_provider ?? provider());

  @override
  bool operator ==(Object other) {
    if (other is AsyncImageProvider) {
      return other.provider == provider;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(provider, provider.hashCode);

  @override
  String toString() => '$name($provider)';
}

/// A [ImageStreamCompleter] that asynchronously listens to an image stream.
class AsyncImageStreamCompleter extends ImageStreamCompleter {
  final Future<ImageStreamCompleter> future;

  ImageStreamCompleter? _completer;
  ImageStreamListener? _listener;

  AsyncImageStreamCompleter(
    this.future, {
    InformationCollector? informationCollector,
  }) {
    future.then((completer) {
      _completer = completer;
      _listener = ImageStreamListener(
        (info, _) => setImage(info),
        onChunk: (event) => reportImageChunkEvent(event),
        onError: (Object error, StackTrace? stack) {
          reportError(
            context: ErrorDescription('resolving an async image completer'),
            exception: error,
            stack: stack,
          );
        },
      );

      _completer!.addListener(_listener!);
    });
  }

  @override
  void onDisposed() {
    final completer = _completer;
    final listener = _listener;
    if (completer != null && listener != null) {
      completer.removeListener(listener);
      completer.maybeDispose();
    }

    _completer = null;
    _listener = null;

    super.onDisposed();
  }
}
