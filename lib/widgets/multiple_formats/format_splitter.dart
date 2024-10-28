import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:async';

class ImageSplitter extends StatefulWidget {
  final String imageUrl;
  final int rows;
  final int cols;

  const ImageSplitter({
    Key? key,
    required this.imageUrl,
    this.rows = 2,
    this.cols = 2,
  }) : super(key: key);

  @override
  _ImageSplitterState createState() => _ImageSplitterState();
}

class _ImageSplitterState extends State<ImageSplitter> {
  late Future<ui.Image?> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = loadImage(widget.imageUrl);
  }

  Future<ui.Image?> loadImage(String url) async {
    final Completer<ui.Image> completer = Completer();
    final NetworkImage networkImage = NetworkImage(url);
    final ImageStream stream = networkImage.resolve(ImageConfiguration());

    stream.addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }),
    );

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.cols,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        return _buildImageSection(index);
      },
      itemCount: widget.rows * widget.cols,
    );
  }

  Widget _buildImageSection(int index) {
    int row = index ~/ widget.cols; // Integer division to get the row number
    int col = index % widget.cols; // Modulus to get the column number

    return ClipRect(
      child: FutureBuilder<ui.Image?>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return CustomPaint(
              painter: ImageSlicePainter(
                image: snapshot.data!,
                row: row,
                col: col,
                rows: widget.rows,
                cols: widget.cols,
              ),
            );
          } else {
            return Container(
                color: Colors.grey[300]); // Placeholder while loading
          }
        },
      ),
    );
  }
}

class ImageSlicePainter extends CustomPainter {
  final ui.Image image;
  final int row;
  final int col;
  final int rows;
  final int cols;

  ImageSlicePainter({
    required this.image,
    required this.row,
    required this.col,
    required this.rows,
    required this.cols,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final sliceWidth = size.width / cols;
    final sliceHeight = size.height / rows;

    final srcRect = Rect.fromLTWH(
      col * sliceWidth,
      row * sliceHeight,
      sliceWidth,
      sliceHeight,
    );

    final destRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, srcRect, destRect, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
