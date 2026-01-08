import 'package:flutter/material.dart';
import 'package:tradingMt1/l10n/app_localizations.dart';
import 'package:tradingMt1/styles/theme/app_common.dart';

/// 包含列表项的索引、数据和可见比例
class VisibleItemInfo {
  /// 列表项索引
  final int index;

  /// 列表项数据
  final Map<String, dynamic> item;

  /// 列表项在可见区域的可见比例（0-1）
  final double visibleFraction;

  VisibleItemInfo({
    required this.index,
    required this.item,
    required this.visibleFraction,
  });

  /// 转换为 Map
  Map<String, dynamic> toMap() {
    return {'index': index, 'item': item, 'visibleFraction': visibleFraction};
  }

  @override
  String toString() {
    return 'VisibleItemInfo(index: $index, visibleFraction: $visibleFraction)';
  }
}

/// 自定义列表组件
///
/// 用于展示数据列表，支持自定义列表项、空状态、下拉刷新等功能
/// 内部使用 ListView.builder 实现虚拟化渲染，性能优异
///
/// 使用示例:
/// ```dart
/// CustomList(
///   dataList: myData,
///   itemHeight: 60,
///   itemBuilder: (context, item, index) => MyItemWidget(item: item),
///   onScrollEnd: (visibleItems) {
///     print('当前可见项: $visibleItems');
///   },
/// )
/// ```
class CustomList extends StatefulWidget {
  /// 数据列表，必填参数
  final List<Map<String, dynamic>> dataList;

  /// 列表项高度，默认为 50
  final double? itemHeight;

  /// 自定义列表项构建器
  /// 如果不传则使用默认的列表项样式
  final Widget Function(
    BuildContext context,
    Map<String, dynamic> item,
    int index,
  )?
  itemBuilder;

  /// 自定义空状态组件
  final Widget? emptyWidget;

  /// 是否显示分隔线
  final bool showDivider;

  /// 分隔线颜色
  final Color? dividerColor;

  /// 下拉刷新回调
  final Future<void> Function()? onRefresh;

  /// 列表内边距
  final EdgeInsetsGeometry? padding;

  /// 滚动物理效果
  final ScrollPhysics? physics;

  /// 滚动控制器
  final ScrollController? controller;

  /// 滚动停止回调，返回当前可见的列表项信息
  final void Function(List<VisibleItemInfo> visibleItems)? onScrollEnd;

  /// 滚动中回调
  final void Function(ScrollNotification notification)? onScroll;

  const CustomList({
    super.key,
    required this.dataList,
    this.itemHeight,
    this.itemBuilder,
    this.emptyWidget,
    this.showDivider = false,
    this.dividerColor,
    this.onRefresh,
    this.padding,
    this.physics,
    this.controller,
    this.onScrollEnd,
    this.onScroll,
  });

  @override
  State<CustomList> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomList> {
  /// 内部滚动控制器
  late ScrollController _scrollController;

  /// 是否使用内部控制器
  bool _useInternalController = false;

  /// 计算属性：判断数据列表是否为空
  bool get isEmpty => widget.dataList.isEmpty;

  /// 获取列表项高度
  double get _itemHeight => widget.itemHeight ?? 50;

  @override
  void initState() {
    super.initState();
    // 如果外部没有传入控制器，则使用内部控制器
    if (widget.controller == null) {
      _scrollController = ScrollController();
      _useInternalController = true;
    } else {
      _scrollController = widget.controller!;
    }
  }

  @override
  void dispose() {
    // 只有内部创建的控制器才需要销毁
    if (_useInternalController) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final themes = Theme.of(context).extension<AppCommon>();

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: isEmpty
          ? _buildEmptyWidget(textTheme, themes)
          : _buildListWidget(),
    );
  }

  /// 构建空状态组件
  Widget _buildEmptyWidget(TextTheme textTheme, AppCommon? themes) {
    // 如果传入了自定义空状态组件，则使用自定义组件
    if (widget.emptyWidget != null) {
      return widget.emptyWidget!;
    }
    // 默认空状态组件
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noData,
        style: textTheme.titleMedium?.copyWith(color: themes?.textSecondary),
      ),
    );
  }

  /// 构建列表组件
  Widget _buildListWidget() {
    Widget listView = NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: ListView.builder(
        controller: _scrollController,
        physics: widget.physics,
        padding: widget.padding,
        itemCount: widget.dataList.length,
        // 缓存区域大小，提升滚动性能
        cacheExtent: 400,
        // 不自动保持状态，减少内存占用
        addAutomaticKeepAlives: false,
        // 减少重绘边界，提升渲染性能
        addRepaintBoundaries: false,
        itemBuilder: _buildListItem,
      ),
    );

    // 如果有下拉刷新回调，包裹 RefreshIndicator
    if (widget.onRefresh != null) {
      return RefreshIndicator(onRefresh: widget.onRefresh!, child: listView);
    }

    return listView;
  }

  /// 处理滚动通知
  bool _handleScrollNotification(ScrollNotification notification) {
    // 滚动中回调
    if (widget.onScroll != null) {
      widget.onScroll!(notification);
    }

    // 滚动停止时回调
    if (notification is ScrollEndNotification && widget.onScrollEnd != null) {
      final visibleItems = _getVisibleItems();
      widget.onScrollEnd!(visibleItems);
    }

    return false;
  }

  /// 获取当前可见的列表项信息
  List<VisibleItemInfo> _getVisibleItems() {
    if (!_scrollController.hasClients) {
      return [];
    }

    final ScrollPosition position = _scrollController.position;
    final double scrollOffset = position.pixels;
    final double viewportHeight = position.viewportDimension;

    // 计算可见区域的起始和结束索引
    final int firstVisibleIndex = (scrollOffset / _itemHeight).floor();
    final int lastVisibleIndex = ((scrollOffset + viewportHeight) / _itemHeight)
        .ceil();

    final List<VisibleItemInfo> visibleItems = [];

    for (int i = firstVisibleIndex; i <= lastVisibleIndex; i++) {
      // 确保索引在有效范围内
      if (i >= 0 && i < widget.dataList.length) {
        // 计算列表项在可见区域的可见比例
        final double itemTop = i * _itemHeight;
        final double itemBottom = itemTop + _itemHeight;
        final double visibleTop = scrollOffset.clamp(itemTop, itemBottom);
        final double visibleBottom = (scrollOffset + viewportHeight).clamp(
          itemTop,
          itemBottom,
        );
        final double visibleFraction =
            (visibleBottom - visibleTop) / _itemHeight;

        visibleItems.add(
          VisibleItemInfo(
            index: i,
            item: widget.dataList[i],
            visibleFraction: visibleFraction,
          ),
        );
      }
    }

    return visibleItems;
  }

  /// 构建单个列表项
  Widget _buildListItem(BuildContext context, int index) {
    final item = widget.dataList[index];

    // 构建列表项内容
    Widget itemContent = SizedBox(
      width: double.infinity,
      height: _itemHeight,
      child:
          widget.itemBuilder?.call(context, item, index) ??
          _defaultItemWidget(context, item),
    );

    // 如果需要显示分隔线
    if (widget.showDivider && index < widget.dataList.length - 1) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          itemContent,
          Divider(
            height: 1,
            color: widget.dividerColor ?? Colors.grey.shade200,
          ),
        ],
      );
    }

    return itemContent;
  }

  /// 默认列表项组件
  ///
  /// 当没有传入 itemBuilder 时使用此默认样式
  /// 显示 title 和 value 两个字段
  Widget _defaultItemWidget(BuildContext context, Map<String, dynamic> item) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            item['title'] ?? '',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          Text(
            item['value'] ?? '',
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
