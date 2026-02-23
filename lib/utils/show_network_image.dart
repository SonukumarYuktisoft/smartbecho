import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

Widget cachedImage(
  String url, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  BorderRadius? borderRadius,
  Widget? placeholder,
  Widget? error,
}) {
  return ClipRRect(
    borderRadius: borderRadius ?? BorderRadius.zero,
    child: CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) =>
          placeholder ?? const Center(child: CircularProgressIndicator()),
      errorWidget: (_, __, ___) =>
          error ?? const Center(child: Icon(Icons.broken_image)),
    ),
  );
}
