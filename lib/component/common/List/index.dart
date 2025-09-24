import 'package:flutter/material.dart';

class CustomList extends StatefulWidget {
  final List<Map<String, dynamic>> dataList;
  final double? itemHeight;
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  )?
  itemBuilder;

  const CustomList({
    super.key,
    required this.dataList,
    this.itemHeight,
    this.itemBuilder,
  });
  @override
  State<CustomList> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomList> {
  bool get isEmpty {
    return widget.dataList.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        children: [
          !isEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: widget.dataList.length,
                    cacheExtent: 400, // 缓存区域大小
                    addAutomaticKeepAlives: false, // 不自动保持状态
                    addRepaintBoundaries: false, // 减少重绘边界
                    itemBuilder: (context, index) {
                      final item = widget.dataList[index];
                      return SizedBox(
                        width: double.infinity,
                        height: widget.itemHeight ?? 50,
                        child:
                            widget.itemBuilder?.call(context, item, index) ??
                            _defaultItemWidget(item),
                      );
                    },
                  ),
                )
              : const Center(
                  child: Text(
                    'no data',
                    style: TextStyle(
                      color: Color.fromRGBO(97, 97, 97, 1),
                      fontSize: 16,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  // default item widget
  Widget _defaultItemWidget(Map<String, dynamic> item) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          item['title'] ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          item['value'] ?? '',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

  // final Map<String, dynamic> colorMap = {
  //   'up': 'Color.fromRGBO(30, 136, 229, 1)',
  //   'down': 'Color.fromRGBO(211, 47, 47, 1)',
  // };

  // String upDownColors(String key) {
  //   return colorMap[key];
  // }
// Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               item['title']
//                   ? Row(
//                       children: [
//                         Text(
//                           item['title'],
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color.fromRGBO(189, 189, 189, 1),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                         Text(
//                           item['titleExtra'] ?? '',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Color.fromRGBO(30, 136, 229, 1),
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     )
//                   : SizedBox(height: 0),
//               if (item['subtitle'] != null)
//                 Text(
//                   item['subtitle'],
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//             ],
//           ),