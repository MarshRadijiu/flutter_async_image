# async_image

[![pub version](https://img.shields.io/pub/v/async_image.svg)](https://pub.dev/packages/async_image)

A Flutter widget that wraps [OctoImage](https://pub.dev/packages/octo_image) to enable asynchronously loading an `ImageProvider`, while retaining all of OctoImage's powerful features.

This is useful when you need to perform some asynchronous work before you can determine which image provider to display, for example, fetching a FileImage or a NetworkImage based on

## Features

- **Asynchronous `ImageProvider`**: Load any `ImageProvider` from a `Future`.
- **Full `OctoImage` compatibility**: Use placeholders, progress indicators, error widgets, and transformations from `OctoImage`.

## Getting started

Add `async_image` to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  async_image: ^1.0.0
```

Then, run `flutter pub get` in your terminal.

## Usage

Here is a simple example of how to use `AsyncImage`. First, create a function that returns a `Future<ImageProvider>`.

```dart
Future<ImageProvider> _loadMetadataImageFromUrl(String url) async {
  final metadata = await AnyLinkPreview.getMetadata(link: url);

  final image = metadata?.image;
  if (image == null) {
    throw Exception('Cannot load image from "$url"');
  }

  return Future.delayed(
    const Duration(seconds: 2),
    () => NetworkImage(image),
  );
}
```

Then, use the `AsyncImage` widget in your UI and provide the future. You can also specify builders for placeholder, progress, and error states, just like you would with `OctoImage`.

```dart
import 'package:async_image/async_image.dart';
import 'package:flutter/material.dart';

class MyImageScreen extends StatelessWidget {
  const MyImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AsyncImage Example')),
      body: Center(
        child: AsyncImage(
          image: _loadMetadataImageFromUrl("https://pub.dev"),
          width: 300,
          height: 300,
          // Optional: Show a placeholder while the image is loading
          placeholderBuilder: (context) => const CircularProgressIndicator(),
          // Optional: Show an error icon if the image fails to load
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.error,
            color: Colors.red,
            size: 48,
          ),
        ),
      ),
    );
  }
}
```

## Additional Information

`AsyncImage` is built on top of `OctoImage` and exposes most of its parameters. For more advanced use cases like image transformations or custom animations, please refer to the [OctoImage documentation](https://pub.dev/packages/octo_image).
