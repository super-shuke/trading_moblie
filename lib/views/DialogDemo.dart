import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

class DialogDemo extends StatefulWidget {
  const DialogDemo({super.key});

  @override
  State<DialogDemo> createState() => _DialogDemoState();
}

class _DialogDemoState extends State<DialogDemo> {
  final CustomDialogController _dialogController = CustomDialogController();
  final CustomDialogController _customColorDialogController =
      CustomDialogController();
  final CustomDialogController _noMaskDialogController =
      CustomDialogController();
  final CustomDialogController _slideDialogController =
      CustomDialogController();

  @override
  void dispose() {
    _dialogController.dispose();
    _customColorDialogController.dispose();
    _noMaskDialogController.dispose();
    _slideDialogController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('自定义弹窗示例'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          // 主内容区域
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _dialogController.show(),
                  child: const Text('显示默认弹窗'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _customColorDialogController.show(),
                  child: const Text('显示自定义颜色遮罩弹窗'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _noMaskDialogController.show(),
                  child: const Text('显示无遮罩弹窗'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _slideDialogController.show(),
                  child: const Text('显示底部滑动弹窗'),
                ),
              ],
            ),
          ),
          // 默认弹窗
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
                        '默认弹窗',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('这是一个默认配置的弹窗，带有半透明黑色遮罩。'),
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
          // 自定义颜色遮罩弹窗
          ListenableBuilder(
            listenable: _customColorDialogController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _customColorDialogController.isVisible,
                config: const CustomDialogConfig(
                  showMask: true,
                  maskColor: Color(0x80FF5722), // 半透明橙色遮罩
                ),
                onClose: () => _customColorDialogController.hide(),
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
                        '自定义颜色遮罩',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('这个弹窗使用了半透明橙色遮罩。'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _customColorDialogController.hide(),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 无遮罩弹窗
          ListenableBuilder(
            listenable: _noMaskDialogController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _noMaskDialogController.isVisible,
                config: const CustomDialogConfig(
                  showMask: false, // 不显示遮罩
                  dismissible: false, // 不可点击外部关闭
                ),
                onClose: () => _noMaskDialogController.hide(),
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '无遮罩弹窗',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('这个弹窗没有遮罩，只能通过按钮关闭。'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _noMaskDialogController.hide(),
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 底部滑动弹窗
          ListenableBuilder(
            listenable: _slideDialogController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _slideDialogController.isVisible,
                config: const CustomDialogConfig(
                  showMask: true,
                  animationType: DialogAnimationType.slideFromBottom, // 从底部滑动
                ),
                onClose: () => _slideDialogController.hide(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '底部滑动弹窗',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '这个弹窗从底部向上滑动显示，常用于操作菜单、选择器等场景。',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _slideDialogController.hide(),
                              child: const Text('取消'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _slideDialogController.hide(),
                              child: const Text('确定'),
                            ),
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
