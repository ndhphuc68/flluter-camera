import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MaterialApp(home: ImageWithTwoSquares()));
}

class ImageWithTwoSquares extends StatefulWidget {
  const ImageWithTwoSquares({super.key});

  @override
  _ImageWithTwoSquaresState createState() => _ImageWithTwoSquaresState();
}

class _ImageWithTwoSquaresState extends State<ImageWithTwoSquares> {
  File? _image;
  final picker = ImagePicker();

  Rect square1 = const Rect.fromLTWH(50, 100, 200, 200); // Ô đỏ
  Rect square2 = const Rect.fromLTWH(120, 150, 100, 100); // Ô vàng

  TextEditingController realWidthController =
      TextEditingController(text: "4.0");
  TextEditingController realHeightController =
      TextEditingController(text: "4.0");

  // Hàm chọn ảnh từ camera
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Map<String, double> _calculateYellowSquareRealSize() {
    double realWidthRed = double.tryParse(realWidthController.text) ?? 1.0;
    double realHeightRed = double.tryParse(realHeightController.text) ?? 1.0;

    double scaleX = realWidthRed / square1.width;
    double scaleY = realHeightRed / square1.height;

    return {
      "width": square2.width * scaleX,
      "height": square2.height * scaleY,
    };
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> realSizeYellow = _calculateYellowSquareRealSize();

    return Scaffold(
      appBar: AppBar(title: const Text("Chụp đeeeeeeeeee")),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text("Chụp ảnh"),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text("Chọn ảnh"),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: realWidthController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Chiều rộng"),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: realHeightController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: "Chiều dài"),
                    onChanged: (val) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _image == null
                ? const Center(child: Text("Chưa có ảnh"))
                : Stack(children: [
                    Image.file(_image!,
                        fit: BoxFit.cover, width: double.infinity),
                    _buildResizableSquare(square1, Colors.red, (newRect) {
                      setState(() => square1 = newRect);
                    }),
                    _buildResizableSquare(square2, Colors.yellow, (newRect) {
                      setState(() => square2 = newRect);
                    }),
                  ]),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                    "Kích thước thực tế ô vàng: ${realSizeYellow["width"]?.toStringAsFixed(2)}cm x ${realSizeYellow["height"]?.toStringAsFixed(2)}cm"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizableSquare(
      Rect rect, Color borderColor, Function(Rect) onUpdate) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            onUpdate(Rect.fromLTWH(rect.left + details.delta.dx,
                rect.top + details.delta.dy, rect.width, rect.height));
          });
        },
        child: Stack(
          children: [
            Container(
              width: rect.width,
              height: rect.height,
              decoration: BoxDecoration(
                border: Border.all(color: borderColor, width: 3),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    onUpdate(Rect.fromLTWH(
                        rect.left,
                        rect.top,
                        rect.width + details.delta.dx,
                        rect.height + details.delta.dy));
                  });
                },
                child: const Icon(Icons.open_in_full,
                    color: Colors.blue, size: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
