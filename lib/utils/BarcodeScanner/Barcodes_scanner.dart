import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

/// ============ BARCODE SCANNER CONTROLLER (GetX) ============
class BarcodeScannerController extends GetxController {
  var scannedBarcode = Rx<String?>(null);
  var scannedBarcodes = <String>[].obs;

  void setBarcode(String barcode) {
    scannedBarcode.value = barcode;
    scannedBarcodes.add(barcode);
  }

  void clearBarcode() {
    scannedBarcode.value = null;
  }

  void clearHistory() {
    scannedBarcodes.clear();
  }

  void removeBarcode(int index) {
    scannedBarcodes.removeAt(index);
  }

  Future<String?> openBarcodeScanner() async {
    final result = await Navigator.push(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => const BarcodeScannerView(),
      ),
    );
    return result;
  }
}

/// ============ REUSABLE BARCODE SCANNER FUNCTION ============

class BarcodeScannerView extends StatefulWidget {
  const BarcodeScannerView({super.key});

  @override
  State<BarcodeScannerView> createState() => _BarcodeScannerViewState();
}

class _BarcodeScannerViewState extends State<BarcodeScannerView>
    with TickerProviderStateMixin {
  bool isScanned = false;
  late MobileScannerController cameraController;
  bool isTorchOn = false;
  late AnimationController _animationController;
  String? _scannedCode;
  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    try {
      cameraController.toggleTorch();
      setState(() {
        isTorchOn = !isTorchOn;
      });
    } catch (e) {
      Get.snackbar('Error', 'Flash error: $e');
    }
  }

  void _switchCamera() {
    try {
      cameraController.switchCamera();
    } catch (e) {
      Get.snackbar('Error', 'Camera error: $e');
    }
  }

  void _closeScanner() {
    Navigator.pop(context);
  }

  Future<void> _handleBarcode(String code) async {
    await HapticFeedback.mediumImpact();
    await cameraController.stop();

    if (mounted) {
      _scannedCode = code; // Store the scanned code
      
      await Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text('Barcode Scanned'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text('Product Code:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  code,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                isScanned = false;
                _scannedCode = null; // Clear the code
                cameraController.start();
              },
              child: const Text('Scan Again'),
            ),
            TextButton(
              onPressed: () {
            //  player.play(AssetSource('audio/beep.mp3'));
                Navigator.pop(context);
              },
              child: const Text('Confirm'),
            ), 
          ],
        ),
        barrierDismissible: false,
      );

      // After dialog closes, return the code
      if (mounted && _scannedCode != null) {
        Navigator.pop(context, _scannedCode);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Barcode Scanner',
       actionItem: [
          IconButton(
            icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
            tooltip: 'Toggle Flash',
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: _switchCamera,
            tooltip: 'Switch Camera',
          ),
        ],

      ),
      // appBar: AppBar(
      //   title: const Text("Barcode Scanner"),
      //   centerTitle: true,
      //   backgroundColor: Colors.blue[800],
      //   elevation: 0,
      //   actions: [
      //     IconButton(
      //       icon: Icon(isTorchOn ? Icons.flash_on : Icons.flash_off),
      //       onPressed: _toggleFlash,
      //       tooltip: 'Toggle Flash',
      //     ),
      //     IconButton(
      //       icon: const Icon(Icons.cameraswitch),
      //       onPressed: _switchCamera,
      //       tooltip: 'Switch Camera',
      //     ),
      //   ],
      // ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
               player.play(
                AssetSource('audio/beep.mp3',));
              final List<Barcode> barcodes = capture.barcodes;
               
              if (isScanned || barcodes.isEmpty) return;

              isScanned = true;
              final String code = barcodes.first.rawValue ?? "Unknown";


              _handleBarcode(code);
            },
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
          Positioned.fill(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  height: 200,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      _buildCorner(top: 0, left: 0),
                      _buildCorner(top: 0, right: 0),
                      _buildCorner(bottom: 0, left: 0),
                      _buildCorner(bottom: 0, right: 0),
                      AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Positioned(
                            top: _animationController.value * 200,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 2,
                              color: Colors.green,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Text(
              'Position barcode inside the frame',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Close Scanner'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _closeScanner,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: top != null ? BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            bottom: bottom != null ? BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            left: left != null ? BorderSide(color: Colors.green, width: 4) : BorderSide.none,
            right: right != null ? BorderSide(color: Colors.green, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }
}