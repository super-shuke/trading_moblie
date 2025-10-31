import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

/// 最简单的弹窗使用示例
/// 这是一个最基础的例子，展示如何在您的页面中使用自定义弹窗
class SimpleDialogExample extends StatefulWidget {
  const SimpleDialogExample({super.key});

  @override
  State<SimpleDialogExample> createState() => _SimpleDialogExampleState();
}

class _SimpleDialogExampleState extends State<SimpleDialogExample> {
  // 第1步：创建弹窗控制器
  final CustomDialogController _dialogController = CustomDialogController();

  @override
  void dispose() {
    // 第2步：释放资源（重要！）
    _dialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('简单弹窗示例'),
      ),
      // 第3步：使用 Stack 布局
      body: Stack(
        children: [
          // 您原有的页面内容
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('点击下面的按钮显示弹窗'),
                const SizedBox(height: 20),
                // 第4步：点击按钮显示弹窗
                ElevatedButton(
                  onPressed: () => _dialogController.show(),
                  child: const Text('显示弹窗'),
                ),
              ],
            ),
          ),
          // 第5步：添加弹窗组件
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
                      const Text(
                        '提示',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('这是一个简单的弹窗！'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _dialogController.hide(),
                        child: const Text('关闭'),
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
