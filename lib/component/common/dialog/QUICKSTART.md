# 快速开始指南

## 🚀 5分钟快速上手

### 步骤1：导入组件

```dart
import 'package:traveling_app/component/dialog/index.dart';
```

### 步骤2：创建控制器

在您的 State 类中创建一个控制器：

```dart
class _MyPageState extends State<MyPage> {
  // 创建控制器
  final CustomDialogController _dialogController = CustomDialogController();
  
  @override
  void dispose() {
    // 别忘了释放资源！
    _dialogController.dispose();
    super.dispose();
  }
  
  // ... 其他代码
}
```

### 步骤3：使用 Stack 布局

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(  // ← 使用 Stack
      children: [
        // 您的页面内容
        Center(
          child: ElevatedButton(
            onPressed: () => _dialogController.show(), // ← 显示弹窗
            child: Text('显示弹窗'),
          ),
        ),
        
        // 弹窗组件（见步骤4）
        // ...
      ],
    ),
  );
}
```

### 步骤4：添加弹窗组件

```dart
ListenableBuilder(
  listenable: _dialogController,
  builder: (context, child) {
    return CustomDialog(
      isVisible: _dialogController.isVisible,
      onClose: () => _dialogController.hide(),
      child: Container(
        width: 300,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('标题', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Text('这是弹窗内容'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _dialogController.hide(),
              child: Text('关闭'),
            ),
          ],
        ),
      ),
    );
  },
)
```

### 步骤5：运行！

完成！现在您可以运行您的应用了。

---

## 📋 完整示例代码

```dart
import 'package:flutter/material.dart';
import 'package:traveling_app/component/dialog/index.dart';

class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final CustomDialogController _dialogController = CustomDialogController();

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('我的页面')),
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () => _dialogController.show(),
              child: Text('显示弹窗'),
            ),
          ),
          ListenableBuilder(
            listenable: _dialogController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _dialogController.isVisible,
                onClose: () => _dialogController.hide(),
                child: Container(
                  width: 300,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('提示', style: TextStyle(fontSize: 20)),
                      SizedBox(height: 20),
                      Text('这是弹窗内容'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _dialogController.hide(),
                        child: Text('关闭'),
                      ),
                    ],
                  ),
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

---

## 🎨 常用配置

### 自定义遮罩颜色

```dart
CustomDialog(
  config: CustomDialogConfig(
    maskColor: Color(0x80FF5722), // 半透明橙色
  ),
  // ...
)
```

### 不显示遮罩

```dart
CustomDialog(
  config: CustomDialogConfig(
    showMask: false,
  ),
  // ...
)
```

### 禁止点击遮罩关闭

```dart
CustomDialog(
  config: CustomDialogConfig(
    dismissible: false,
  ),
  // ...
)
```

### 自定义动画时长

```dart
CustomDialog(
  config: CustomDialogConfig(
    animationDuration: Duration(milliseconds: 500),
  ),
  // ...
)
```

### 底部滑动动画

```dart
CustomDialog(
  config: CustomDialogConfig(
    animationType: DialogAnimationType.slideFromBottom,
  ),
  // ...
)
```

---

## 🎯 查看完整示例

访问以下路由查看实际运行的示例：

- **示例中心**: `/examples-hub` - 所有示例的总览
- **简单示例**: `/simple-dialog` - 最基础的用法
- **完整演示**: `/dialog-demo` - 所有功能展示
- **交易示例**: `/trading-confirm` - 实战场景示例

或者在代码中查看：
- `lib/views/SimpleDialogExample.dart` - 简单示例
- `lib/views/DialogDemo.dart` - 完整演示
- `lib/views/TradingConfirmExample.dart` - 交易确认示例

---

## 💡 提示

1. **必须使用 Stack**：弹窗需要覆盖在页面内容上方
2. **记得 dispose**：避免内存泄漏
3. **使用 ListenableBuilder**：自动响应控制器状态变化
4. **自定义样式**：Container 中的样式完全由您控制

---

## 📚 更多资源

- **API文档**: `lib/component/dialog/README.md`
- **详细示例**: `lib/component/dialog/EXAMPLES.md`
- **源代码**: `lib/component/dialog/custom_dialog.dart`
