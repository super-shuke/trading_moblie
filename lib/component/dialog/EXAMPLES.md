# 自定义弹窗组件使用示例

## 在现有页面中集成弹窗

### 示例 1: 在现有页面添加一个简单弹窗

```dart
import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

class YourExistingPage extends StatefulWidget {
  const YourExistingPage({super.key});

  @override
  State<YourExistingPage> createState() => _YourExistingPageState();
}

class _YourExistingPageState extends State<YourExistingPage> {
  // 1. 创建弹窗控制器
  final CustomDialogController _dialogController = CustomDialogController();

  @override
  void dispose() {
    // 2. 释放控制器资源
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('您的页面')),
      // 3. 使用 Stack 布局
      body: Stack(
        children: [
          // 原有的页面内容
          Center(
            child: ElevatedButton(
              onPressed: () => _dialogController.show(), // 4. 显示弹窗
              child: const Text('打开弹窗'),
            ),
          ),
          // 5. 添加弹窗组件
          ListenableBuilder(
            listenable: _dialogController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _dialogController.isVisible,
                onClose: () => _dialogController.hide(),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('提示', style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 20),
                      const Text('这是弹窗内容'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _dialogController.hide(),
                        child: const Text('确定'),
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

### 示例 2: 确认对话框

```dart
import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

class ConfirmDialogExample extends StatefulWidget {
  const ConfirmDialogExample({super.key});

  @override
  State<ConfirmDialogExample> createState() => _ConfirmDialogExampleState();
}

class _ConfirmDialogExampleState extends State<ConfirmDialogExample> {
  final CustomDialogController _confirmController = CustomDialogController();

  void _handleConfirm() {
    // 处理确认逻辑
    print('用户点击了确认');
    _confirmController.hide();
  }

  void _handleCancel() {
    // 处理取消逻辑
    print('用户点击了取消');
    _confirmController.hide();
  }

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () => _confirmController.show(),
              child: const Text('删除项目'),
            ),
          ),
          ListenableBuilder(
            listenable: _confirmController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _confirmController.isVisible,
                config: const CustomDialogConfig(
                  dismissible: false, // 禁止点击遮罩关闭
                ),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning, color: Colors.orange, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        '确认删除',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text('确定要删除这个项目吗？此操作不可恢复。'),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          TextButton(
                            onPressed: _handleCancel,
                            child: const Text('取消'),
                          ),
                          ElevatedButton(
                            onPressed: _handleConfirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('确定删除'),
                          ),
                        ],
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

### 示例 3: 加载中对话框

```dart
import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

class LoadingDialogExample extends StatefulWidget {
  const LoadingDialogExample({super.key});

  @override
  State<LoadingDialogExample> createState() => _LoadingDialogExampleState();
}

class _LoadingDialogExampleState extends State<LoadingDialogExample> {
  final CustomDialogController _loadingController = CustomDialogController();

  Future<void> _simulateLoading() async {
    _loadingController.show();
    
    // 模拟网络请求
    await Future.delayed(const Duration(seconds: 3));
    
    _loadingController.hide();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: _simulateLoading,
              child: const Text('开始加载'),
            ),
          ),
          ListenableBuilder(
            listenable: _loadingController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _loadingController.isVisible,
                config: const CustomDialogConfig(
                  dismissible: false, // 加载时不可关闭
                  maskColor: Color(0x99000000), // 更深的遮罩
                ),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text('加载中...'),
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

### 示例 4: 自定义颜色主题弹窗

```dart
import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

class ThemedDialogExample extends StatefulWidget {
  const ThemedDialogExample({super.key});

  @override
  State<ThemedDialogExample> createState() => _ThemedDialogExampleState();
}

class _ThemedDialogExampleState extends State<ThemedDialogExample> {
  final CustomDialogController _dialogController = CustomDialogController();

  @override
  void dispose() {
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () => _dialogController.show(),
              child: const Text('显示主题弹窗'),
            ),
          ),
          ListenableBuilder(
            listenable: _dialogController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _dialogController.isVisible,
                config: const CustomDialogConfig(
                  maskColor: Color(0x80673AB7), // 紫色遮罩
                ),
                onClose: () => _dialogController.hide(),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF673AB7), Color(0xFF9C27B0)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars, color: Colors.white, size: 60),
                      const SizedBox(height: 16),
                      const Text(
                        '恭喜！',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '您已成功完成任务',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _dialogController.hide(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF673AB7),
                        ),
                        child: const Text('太棒了！'),
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

## 访问 DialogDemo 页面

可以通过路由访问完整的示例页面：

```dart
// 使用 go_router 导航
context.go('/dialog-demo');

// 或者直接在代码中使用
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const DialogDemo()),
);
```

## 注意事项

1. **必须使用 Stack 布局**：弹窗需要覆盖在页面内容之上
2. **记得释放资源**：在 dispose() 中调用 `controller.dispose()`
3. **使用 ListenableBuilder**：监听控制器状态变化以更新 UI
4. **自定义内容样式**：弹窗内容需要自己设置背景色和装饰
5. **dismissible 配置**：对于确认对话框或加载对话框，建议设置为 false
