# 自定义弹窗组件 (CustomDialog)

这是一个功能强大、高度可定制的 Flutter 弹窗组件，支持遮罩配置、颜色自定义、显示控制等功能。

## 功能特性

- ✅ **遮罩配置**：支持显示/隐藏遮罩
- ✅ **颜色自定义**：可自定义遮罩颜色
- ✅ **外部控制**：通过 Controller 控制弹窗显示/隐藏
- ✅ **自定义内容**：支持任意 Widget 作为弹窗内容
- ✅ **多种动画效果**：支持中间淡入淡出和底部滑动两种动画
- ✅ **可关闭配置**：可配置点击遮罩是否关闭弹窗

## 快速开始

### 基本用法

```dart
import 'package:traveling_app/component/dialog/index.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final CustomDialogController _controller = CustomDialogController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 主内容
          Center(
            child: ElevatedButton(
              onPressed: () => _controller.show(),
              child: Text('显示弹窗'),
            ),
          ),
          // 弹窗
          ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _controller.isVisible,
                onClose: () => _controller.hide(),
                child: Container(
                  padding: EdgeInsets.all(20),
                  color: Colors.white,
                  child: Text('弹窗内容'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### 自定义遮罩颜色

```dart
CustomDialog(
  isVisible: _controller.isVisible,
  config: CustomDialogConfig(
    showMask: true,
    maskColor: Color(0x80FF5722), // 半透明橙色
  ),
  onClose: () => _controller.hide(),
  child: YourCustomWidget(),
)
```

### 不显示遮罩

```dart
CustomDialog(
  isVisible: _controller.isVisible,
  config: CustomDialogConfig(
    showMask: false,
  ),
  onClose: () => _controller.hide(),
  child: YourCustomWidget(),
)
```

### 禁止点击遮罩关闭

```dart
CustomDialog(
  isVisible: _controller.isVisible,
  config: CustomDialogConfig(
    dismissible: false, // 不允许点击遮罩关闭
  ),
  onClose: () => _controller.hide(),
  child: YourCustomWidget(),
)
```

### 自定义动画时长

```dart
CustomDialog(
  isVisible: _controller.isVisible,
  config: CustomDialogConfig(
    animationDuration: Duration(milliseconds: 500),
  ),
  onClose: () => _controller.hide(),
  child: YourCustomWidget(),
)
```

### 底部滑动动画

```dart
CustomDialog(
  isVisible: _controller.isVisible,
  config: CustomDialogConfig(
    animationType: DialogAnimationType.slideFromBottom, // 从底部滑动
  ),
  onClose: () => _controller.hide(),
  child: YourCustomWidget(),
)
```

## API 文档

### CustomDialog

弹窗组件主体。

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| child | Widget | 是 | 弹窗内容 |
| isVisible | bool | 是 | 是否显示弹窗 |
| config | CustomDialogConfig | 否 | 弹窗配置 |
| onClose | VoidCallback? | 否 | 关闭回调 |

### CustomDialogConfig

弹窗配置类。

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| showMask | bool | true | 是否显示遮罩 |
| maskColor | Color | Color(0x80000000) | 遮罩颜色（半透明黑色） |
| dismissible | bool | true | 是否可以点击遮罩关闭 |
| animationDuration | Duration | Duration(milliseconds: 300) | 动画时长 |
| animationType | DialogAnimationType | DialogAnimationType.fade | 动画类型 |

### DialogAnimationType

弹窗动画类型枚举。

| 值 | 说明 |
|----|------|
| fade | 中间淡入淡出 + 缩放动画 |
| slideFromBottom | 从底部向上滑动 |

### CustomDialogController

弹窗控制器，用于控制弹窗的显示和隐藏。

#### 方法

- `show()`: 显示弹窗
- `hide()`: 隐藏弹窗
- `toggle()`: 切换弹窗显示状态

#### 属性

- `isVisible`: 当前弹窗是否可见

## 完整示例

查看 `lib/views/DialogDemo.dart` 文件获取完整的使用示例，包括：

- 默认弹窗
- 自定义颜色遮罩弹窗
- 无遮罩弹窗

## 注意事项

1. 使用 `Stack` 布局，确保弹窗在正确的层级显示
2. 使用 `ListenableBuilder` 监听 Controller 的变化
3. 记得在 `dispose()` 方法中释放 Controller
4. 弹窗内容需要自己添加背景色或装饰
5. 建议使用 `Container` 或 `Card` 包裹弹窗内容以获得更好的视觉效果

## 测试

运行测试命令：

```bash
flutter test test/custom_dialog_test.dart
```

测试覆盖：
- Controller 的所有方法
- 弹窗的显示/隐藏
- 遮罩的显示/隐藏
- 点击遮罩关闭功能
- 动画效果

## License

MIT
