import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildPlutoGridShimmer({int rowCount = 10, int columnCount = 8}) {
  return ListView.builder(
    itemCount: rowCount,
    itemBuilder: (context, rowIndex) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: List.generate(columnCount, (colIndex) {
              return Expanded(
                child: Container(
                  height: 20,
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  color: Colors.white,
                ),
              );
            }),
          ),
        ),
      );
    },
  );
}
