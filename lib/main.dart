import 'dart:io';
import 'dart:math';
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

  TextEditingController realWidthController = TextEditingController(text: "4.0");
  TextEditingController realHeightController = TextEditingController(text: "4.0");

  double scaleY = 1.0;
  double _rotation = 0.0;

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

  void _updateRedSquareDistortion() {
    setState(() {
      scaleY = square1.width / square1.height;
    });
  }

  void _resetState() {
    setState(() {
      square1 = const Rect.fromLTWH(50, 100, 200, 200);
      square2 = const Rect.fromLTWH(120, 150, 100, 100);
      scaleY = 1.0;
      _rotation = 0.0;
      realWidthController.text = "4.0";
      realHeightController.text = "4.0";
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, double> realSizeYellow = _calculateYellowSquareRealSize();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Tính"),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            const SizedBox(height: 50,),
            ElevatedButton(
              onPressed: () {
                _pickImage(ImageSource.camera);
                Navigator.pop(context);
              },
              child: const Text("Chụp ảnh"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _pickImage(ImageSource.gallery);
                Navigator.pop(context);
              },
              child: const Text("Chọn ảnh"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _updateRedSquareDistortion();
                Navigator.pop(context);
              },
              child: const Text("Tính"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                _resetState();
                Navigator.pop(context);
              },
              child: const Text("Reset"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: realWidthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Chiều rộng thực tế"),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: realHeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Chiều dài thực tế"),
              onChanged: (val) => setState(() {}),
            ),
            const SizedBox(height: 20),
            Text(
              "Kích thước thực tế ô vàng: ${realSizeYellow["width"]?.toStringAsFixed(2)} x ${realSizeYellow["height"]?.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _image == null
                ? const Center(child: Text("Chưa có ảnh"))
                : Stack(
              children: [
                Center(
                  child: Transform.scale(
                    scaleY: scaleY,
                    child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                  ),
                ),
                _buildResizableSquare(square1, Colors.red, (newRect) {
                  setState(() => square1 = newRect);
                }),
                _buildResizableSquare(square2, Colors.yellow, (newRect) {
                  setState(() => square2 = newRect);
                }, rotation: _rotation, onRotate: (newAngle) {
                  setState(() {
                    _rotation = newAngle;
                  });
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResizableSquare(Rect rect, Color borderColor, Function(Rect) onUpdate, {double rotation = 0.0, Function(double)? onRotate}) {
    return Positioned(
      left: rect.left,
      top: rect.top,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            onUpdate(Rect.fromLTWH(rect.left + details.delta.dx, rect.top + details.delta.dy, rect.width, rect.height));
          });
        },
        child: Transform.rotate(
          angle: rotation,
          child: Stack(
            clipBehavior: Clip.none,
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
                      onUpdate(Rect.fromLTWH(rect.left, rect.top, rect.width + details.delta.dx, rect.height + details.delta.dy));
                    });
                  },
                  child: const Icon(Icons.open_in_full, color: Colors.blue, size: 24),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    if (onRotate != null) {
                      final centerX = rect.left + rect.width / 2;
                      final centerY = rect.top + rect.height / 2;
                      final touchX = rect.left + rect.width + details.localPosition.dx;
                      final touchY = rect.top + details.localPosition.dy;
                      final angle = atan2(touchY - centerY, touchX - centerX);
                      setState(() {
                        onRotate(angle);
                      });
                    }
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Icon(Icons.rotate_right, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
