import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tradingMt1/component/dialog/index.dart';

void main() {
  group('CustomDialogController', () {
    test('初始状态应该是不可见', () {
      final controller = CustomDialogController();
      expect(controller.isVisible, false);
    });

    test('show() 应该显示弹窗', () {
      final controller = CustomDialogController();
      controller.show();
      expect(controller.isVisible, true);
    });

    test('hide() 应该隐藏弹窗', () {
      final controller = CustomDialogController();
      controller.show();
      controller.hide();
      expect(controller.isVisible, false);
    });

    test('toggle() 应该切换弹窗状态', () {
      final controller = CustomDialogController();
      expect(controller.isVisible, false);
      controller.toggle();
      expect(controller.isVisible, true);
      controller.toggle();
      expect(controller.isVisible, false);
    });

    test('重复调用 show() 不应该触发多次通知', () {
      final controller = CustomDialogController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      
      controller.show();
      expect(notifyCount, 1);
      
      controller.show();
      expect(notifyCount, 1); // 不应该增加
    });

    test('重复调用 hide() 不应该触发多次通知', () {
      final controller = CustomDialogController();
      int notifyCount = 0;
      controller.addListener(() => notifyCount++);
      
      controller.show();
      notifyCount = 0; // 重置计数
      
      controller.hide();
      expect(notifyCount, 1);
      
      controller.hide();
      expect(notifyCount, 1); // 不应该增加
    });
  });

  group('CustomDialog Widget', () {
    testWidgets('不可见时不应该渲染', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDialog(
              isVisible: false,
              child: Container(
                key: const Key('dialog-content'),
                color: Colors.white,
                child: const Text('测试内容'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('dialog-content')), findsNothing);
    });

    testWidgets('可见时应该渲染内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDialog(
              isVisible: true,
              child: Container(
                key: const Key('dialog-content'),
                color: Colors.white,
                child: const Text('测试内容'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byKey(const Key('dialog-content')), findsOneWidget);
      expect(find.text('测试内容'), findsOneWidget);
    });

    testWidgets('showMask=true 时应该显示遮罩', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDialog(
              isVisible: true,
              config: const CustomDialogConfig(showMask: true),
              child: const Text('测试内容'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // 查找 GestureDetector，它是遮罩的一部分
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('showMask=false 时不应该显示遮罩', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDialog(
              isVisible: true,
              config: const CustomDialogConfig(showMask: false),
              child: const Text('测试内容'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // 应该找不到作为遮罩的 GestureDetector
      final gestures = find.byType(GestureDetector);
      expect(gestures, findsNothing);
    });

    testWidgets('dismissible=true 时点击遮罩应该触发 onClose', (WidgetTester tester) async {
      bool closeCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomDialog(
              isVisible: true,
              config: const CustomDialogConfig(
                showMask: true,
                dismissible: true,
              ),
              onClose: () => closeCalled = true,
              child: const Text('测试内容'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // 点击遮罩（点击 GestureDetector）
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      
      expect(closeCalled, true);
    });

    testWidgets('从不可见变为可见应该播放动画', (WidgetTester tester) async {
      bool isVisible = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => isVisible = true),
                      child: const Text('显示'),
                    ),
                    CustomDialog(
                      isVisible: isVisible,
                      child: const Text('测试内容'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('测试内容'), findsNothing);
      
      // 点击按钮显示弹窗
      await tester.tap(find.text('显示'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      
      // 动画进行中，内容应该可见
      expect(find.text('测试内容'), findsOneWidget);
      
      // 等待动画完成
      await tester.pumpAndSettle();
      expect(find.text('测试内容'), findsOneWidget);
    });
  });

  group('CustomDialogConfig', () {
    test('默认配置应该正确', () {
      const config = CustomDialogConfig();
      expect(config.showMask, true);
      expect(config.maskColor, const Color(0x80000000));
      expect(config.dismissible, true);
      expect(config.animationDuration, const Duration(milliseconds: 300));
    });

    test('自定义配置应该生效', () {
      const config = CustomDialogConfig(
        showMask: false,
        maskColor: Colors.red,
        dismissible: false,
        animationDuration: Duration(milliseconds: 500),
      );
      expect(config.showMask, false);
      expect(config.maskColor, Colors.red);
      expect(config.dismissible, false);
      expect(config.animationDuration, const Duration(milliseconds: 500));
    });
  });
}
