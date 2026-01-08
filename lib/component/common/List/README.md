# CustomList 组件

一个高性能的自定义列表组件，基于 `ListView.builder` 实现虚拟化渲染。

## 功能特性

- 虚拟化渲染，支持大数据列表
- 自定义列表项
- 空状态展示
- 下拉刷新
- 分隔线支持
- 滚动控制
- 滚动停止回调（返回当前可见项信息）
- 滚动中回调

## 安装依赖

确保项目已安装以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
```

## 基础用法

```dart
import 'package:tradingMt1/component/common/List/index.dart';

CustomList(
  dataList: [
    {'title': '标题1', 'value': '值1'},
    {'title': '标题2', 'value': '值2'},
  ],
  itemHeight: 60,
)
```

## 自定义列表项

```dart
CustomList(
  dataList: myData,
  itemHeight: 80,
  itemBuilder: (context, item, index) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Text(item['name']),
          Spacer(),
          Text(item['price']),
        ],
      ),
    );
  },
)
```

## 带下拉刷新

```dart
CustomList(
  dataList: myData,
  itemHeight: 60,
  onRefresh: () async {
    // 刷新数据
    await fetchData();
  },
  itemBuilder: (context, item, index) => MyItemWidget(item: item),
)
```

## 带分隔线

```dart
CustomList(
  dataList: myData,
  itemHeight: 60,
  showDivider: true,
  dividerColor: Colors.grey.shade200,
  itemBuilder: (context, item, index) => MyItemWidget(item: item),
)
```

## 监听滚动停止

滚动停止时会返回当前可见的列表项信息，包含 `VisibleItemInfo` 对象列表。

```dart
CustomList(
  dataList: myData,
  itemHeight: 60,
  onScrollEnd: (visibleItems) {
    // visibleItems 是 List<VisibleItemInfo> 类型
    print('当前可见项数量: ${visibleItems.length}');
    
    for (var info in visibleItems) {
      print('索引: ${info.index}');
      print('数据: ${info.item}');
      print('可见比例: ${info.visibleFraction}'); // 0-1 之间
    }
  },
  itemBuilder: (context, item, index) => MyItemWidget(item: item),
)
```

### VisibleItemInfo 类

| 属性 | 类型 | 说明 |
|------|------|------|
| `index` | `int` | 列表项索引 |
| `item` | `Map<String, dynamic>` | 列表项数据 |
| `visibleFraction` | `double` | 可见比例（0-1），1 表示完全可见 |

### 方法

- `toMap()`：转换为 Map 对象
- `toString()`：转换为字符串

## 监听滚动中

```dart
CustomList(
  dataList: myData,
  itemHeight: 60,
  onScroll: (notification) {
    // notification 是 ScrollNotification 类型
    print('当前滚动位置: ${notification.metrics.pixels}');
    print('最大滚动距离: ${notification.metrics.maxScrollExtent}');
    
    // 判断滚动方向
    if (notification is ScrollUpdateNotification) {
      print('滚动增量: ${notification.scrollDelta}');
    }
  },
  itemBuilder: (context, item, index) => MyItemWidget(item: item),
)
```

## 自定义空状态

```dart
CustomList(
  dataList: [],
  itemHeight: 60,
  emptyWidget: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.inbox, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('暂无数据'),
    ],
  ),
)
```

## 滚动控制

```dart
final ScrollController _controller = ScrollController();

CustomList(
  dataList: myData,
  itemHeight: 60,
  controller: _controller,
  itemBuilder: (context, item, index) => MyItemWidget(item: item),
)

// 滚动到指定位置
_controller.animateTo(
  200,
  duration: Duration(milliseconds: 300),
  curve: Curves.easeOut,
);
```

## API 参数

| 参数 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| `dataList` | `List<Map<String, dynamic>>` | | - | 数据列表 |
| `itemHeight` | `double?` | ❌ | 50 | 列表项高度 |
| `itemBuilder` | `Function?` | ❌ | - | 自定义列表项构建器 |
| `emptyWidget` | `Widget?` | ❌ | - | 自定义空状态组件 |
| `showDivider` | `bool` | ❌ | false | 是否显示分隔线 |
| `dividerColor` | `Color?` | ❌ | grey.shade200 | 分隔线颜色 |
| `onRefresh` | `Future<void> Function()?` | ❌ | - | 下拉刷新回调 |
| `onScrollEnd` | `Function(List<VisibleItemInfo>)?` | ❌ | - | 滚动停止回调，返回可见项信息 |
| `onScroll` | `Function(ScrollNotification)?` | ❌ | - | 滚动中回调 |
| `padding` | `EdgeInsetsGeometry?` | ❌ | - | 列表内边距 |
| `physics` | `ScrollPhysics?` | ❌ | - | 滚动物理效果 |
| `controller` | `ScrollController?` | ❌ | - | 滚动控制器 |

## 性能优化

组件内部已做以下性能优化：

1. **虚拟化渲染**：使用 `ListView.builder`，只渲染可见区域的列表项
2. **缓存区域**：设置 `cacheExtent: 400`，提前渲染即将可见的列表项
3. **关闭自动保持状态**：`addAutomaticKeepAlives: false`，减少内存占用
4. **减少重绘边界**：`addRepaintBoundaries: false`，提升渲染性能
5. **智能控制器管理**：自动管理内部/外部 ScrollController 的生命周期

## 注意事项

1. `itemHeight` 建议设置固定值，可提升滚动性能和可见项计算的准确性
2. 大数据列表建议使用 `itemBuilder` 自定义列表项
3. 下拉刷新时需要返回 `Future`，刷新完成后 UI 会自动更新
4. `onScrollEnd` 回调中的 `visibleFraction` 可用于判断列表项是否完全可见
