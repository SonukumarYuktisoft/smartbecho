import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:smartbecho/utils/app_colors.dart';

class EnhancedImagePicker extends StatefulWidget {
  /// Text label displayed above the image picker
  final String? labelText;

  /// Callback function when an image is selected
  final Function(File?)? onImageSelected;

  /// Initial image to display
  final File? initialImage;

  /// Text to display on the upload button
  final String uploadText;

  /// Height of the image container
  final double height;

  /// Width of the image container
  final double width;

  /// Whether to enable image cropping
  final bool enableCropping;

  /// Whether to enable image compression
  final bool enableCompression;

  /// Quality of the compressed image (0-100)
  final int compressionQuality;

  /// Maximum width for the image
  final double? maxWidth;

  /// Maximum height for the image
  final double? maxHeight;

  /// Function to handle image upload
  final Future<bool> Function(File)? onUpload;

  /// Custom theme color
  final Color? themeColor;

  const EnhancedImagePicker({
    Key? key,
    this.labelText,
    this.onImageSelected,
    this.initialImage,
    this.uploadText = "Upload Image",
    this.height = 120,
    this.width = double.infinity,
    this.enableCropping = true,
    this.enableCompression = true,
    this.compressionQuality = 80,
    this.maxWidth = 800,
    this.maxHeight = 800,
    this.onUpload,
    this.themeColor,
  }) : super(key: key);

  @override
  State<EnhancedImagePicker> createState() => _EnhancedImagePickerState();
}

class _EnhancedImagePickerState extends State<EnhancedImagePicker> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String _errorMessage = '';
  bool _hasPermissionError = false;

  Color get _themeColor => widget.themeColor ?? AppColors.primaryLight;

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.initialImage;
  }

  /// Request camera permission
  Future<bool> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('Camera');
      return false;
    }
    return status.isGranted;
  }

  /// Request gallery permission
  Future<bool> _requestGalleryPermission() async {
    PermissionStatus status = await Permission.photos.request();
    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog('Gallery');
      return false;
    }
    return status.isGranted;
  }

  /// Show dialog when permission is permanently denied
  void _showPermissionDeniedDialog(String permissionType) {
    setState(() {
      _hasPermissionError = true;
      _errorMessage =
          '$permissionType permission denied. Please enable it in app settings.';
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$permissionType Permission Required',
            style: TextStyle(
              color: AppColors.textPrimaryLight,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Please enable $permissionType access in your device settings to use this feature.',
            style: TextStyle(color: AppColors.textSecondaryLight),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondaryLight,
              ),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Open Settings'),
            ),
          ],
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        );
      },
    );
  }

  /// Pick image from gallery
  Future<void> _pickImage() async {
    try {
      bool hasPermission = await _requestGalleryPermission();
      if (!hasPermission) return;

      setState(() {
        _errorMessage = '';
        _hasPermissionError = false;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality:
            widget.enableCompression ? widget.compressionQuality : null,
      );

      if (image != null) {
        File imageFile = File(image.path);

        if (widget.enableCropping) {
          imageFile = await _cropImage(imageFile) ?? imageFile;
        }

        if (widget.enableCompression) {
          imageFile = await _compressImage(imageFile) ?? imageFile;
        }

        setState(() {
          _selectedImage = imageFile;
        });

        widget.onImageSelected?.call(_selectedImage);

        if (widget.onUpload != null) {
          _uploadImage(_selectedImage!);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
      _showErrorSnackBar(_errorMessage);
    }
  }

  /// Take photo using camera
  Future<void> _takePhoto() async {
    try {
      bool hasPermission = await _requestCameraPermission();
      if (!hasPermission) return;

      setState(() {
        _errorMessage = '';
        _hasPermissionError = false;
      });

      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: widget.maxWidth,
        maxHeight: widget.maxHeight,
        imageQuality:
            widget.enableCompression ? widget.compressionQuality : null,
      );

      if (image != null) {
        File imageFile = File(image.path);

        if (widget.enableCropping) {
          imageFile = await _cropImage(imageFile) ?? imageFile;
        }

        if (widget.enableCompression) {
          imageFile = await _compressImage(imageFile) ?? imageFile;
        }

        setState(() {
          _selectedImage = imageFile;
        });

        widget.onImageSelected?.call(_selectedImage);

        if (widget.onUpload != null) {
          _uploadImage(_selectedImage!);
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error taking photo: $e';
      });
      _showErrorSnackBar(_errorMessage);
    }
  }

  /// Crop the selected image
  Future<File?> _cropImage(File imageFile) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        uiSettings: [
          AndroidUiSettings(
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9,
            ],
            toolbarTitle: 'Crop Image',
            toolbarColor: _themeColor,
            toolbarWidgetColor: Colors.white,
            activeControlsWidgetColor: _themeColor,
            backgroundColor: Colors.white,
            statusBarColor: _themeColor,
            cropFrameColor: _themeColor,
            cropGridColor: _themeColor.withValues(alpha: 0.5),
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
            showCropGrid: true,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            resetButtonHidden: false,
            aspectRatioPickerButtonHidden: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cropping image: $e';
      });
      _showErrorSnackBar(_errorMessage);
      return null;
    }
  }

  /// Compress the selected image
  Future<File?> _compressImage(File file) async {
    try {
      final dir = file.parent.path;
      final targetPath = "$dir/${DateTime.now().millisecondsSinceEpoch}.jpg";

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: widget.compressionQuality,
        minWidth: widget.maxWidth?.toInt() ?? 800,
        minHeight: widget.maxHeight?.toInt() ?? 800,
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      setState(() {
        _errorMessage = 'Error compressing image: $e';
      });
      _showErrorSnackBar(_errorMessage);
      return null;
    }
  }

  /// Upload the image with progress tracking
  Future<void> _uploadImage(File image) async {
    if (widget.onUpload == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
      _errorMessage = '';
    });

    try {
      // Simulate upload progress
      Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_uploadProgress < 0.9) {
          setState(() {
            _uploadProgress += 0.1;
          });
        } else {
          timer.cancel();
        }
      });

      // Actual upload
      bool success = await widget.onUpload!(image);

      setState(() {
        _isUploading = false;
        _uploadProgress = 1.0;

        if (!success) {
          _errorMessage = 'Upload failed';
          _showErrorSnackBar(_errorMessage);
        }
      });

      // Reset progress after showing completion
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _uploadProgress = 0.0;
          });
        }
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error uploading image: $e';
      });
      _showErrorSnackBar(_errorMessage);
    }
  }

  /// Remove the selected image
  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _errorMessage = '';
      _uploadProgress = 0.0;
      _isUploading = false;
    });
    widget.onImageSelected?.call(null);
  }

  /// Show image source selection dialog
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: TextStyle(
                    color: AppColors.onSurfaceDark,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                    _buildSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  /// Build image source option widget
  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _themeColor, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }

  /// Show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.errorLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
        ],
        GestureDetector(
          onTap: _hasPermissionError ? null : _showImageSourceDialog,
          child: Container(
            height: widget.height,
            width: widget.width,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.borderLight, width: 0.4),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.08),
                  spreadRadius: 0,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child:
                _selectedImage != null
                    ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _selectedImage!,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (_isUploading)
                          Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(
                                  value: _uploadProgress,
                                  color: _themeColor,
                                  strokeWidth: 3,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Uploading ${(_uploadProgress * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: _isUploading ? null : _removeImage,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.errorLight.withValues(
                                  alpha: 0.8,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    : _hasPermissionError
                    ? _buildErrorState()
                    : _buildUploadPrompt(),
          ),
        ),
        if (_errorMessage.isNotEmpty && !_hasPermissionError) ...[
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 12),
          ),
        ],
      ],
    );
  }

  /// Build upload prompt widget
  Widget _buildUploadPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _themeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: _themeColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.uploadText,
            style: TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap to select',
            style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Build error state widget
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.errorLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.error_outline,
              color: AppColors.errorLight,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Permission Required',
            style: TextStyle(
              color: AppColors.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _errorMessage,
              style: TextStyle(color: AppColors.errorLight, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: openAppSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
