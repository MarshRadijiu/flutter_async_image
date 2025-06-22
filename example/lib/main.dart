import 'package:any_link_preview/any_link_preview.dart';
import 'package:async_image/async_image.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo Async Image',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AsyncImageDemo(title: 'Flutter Demo Async Image'),
    );
  }
}

class AsyncImageDemo extends StatefulWidget {
  const AsyncImageDemo({super.key, required this.title});

  final String title;

  @override
  State<AsyncImageDemo> createState() => _AsyncImageDemoState();
}

class _AsyncImageDemoState extends State<AsyncImageDemo> {
  String _link = 'https://pub.dev';

  final TextEditingController _controller = TextEditingController(
    text: 'https://pub.dev',
  );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(16),
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.hardEdge,
              width: 256,
              height: 256,
              child: AsyncImage(
                image: _loadMetadataImageFromUrl(_link),
                placeholderBuilder: OctoPlaceholder.circularProgressIndicator(),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  label: Text('Enter a URL'),
                  hintText: 'https://pub.dev',
                ),
                onEditingComplete:
                    () => setState(() {
                      _link = _controller.value.text;
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
