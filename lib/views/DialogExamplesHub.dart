import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 弹窗示例总览页面
/// 展示所有可用的弹窗使用示例
class DialogExamplesHub extends StatelessWidget {
  const DialogExamplesHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('弹窗组件示例中心'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 页面标题和说明
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '自定义弹窗组件',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '支持遮罩配置、颜色自定义、外部控制显示隐藏等功能。',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          // 示例列表
          const Text(
            '📱 示例列表',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          
          // 示例1：简单弹窗
          _buildExampleCard(
            context,
            icon: Icons.info_outline,
            iconColor: Colors.blue,
            title: '简单弹窗示例',
            description: '最基础的弹窗用法，5步快速上手',
            features: [
              '✓ 基础配置',
              '✓ 显示/隐藏控制',
              '✓ 自定义内容',
            ],
            route: '/simple-dialog',
          ),
          
          // 示例2：完整演示
          _buildExampleCard(
            context,
            icon: Icons.dashboard_customize,
            iconColor: Colors.purple,
            title: '完整功能演示',
            description: '展示所有可用的配置选项和功能',
            features: [
              '✓ 默认弹窗',
              '✓ 自定义颜色遮罩',
              '✓ 无遮罩模式',
            ],
            route: '/dialog-demo',
          ),
          
          // 示例3：交易确认
          _buildExampleCard(
            context,
            icon: Icons.trending_up,
            iconColor: Colors.green,
            title: '交易确认示例',
            description: '实战场景：交易买卖确认弹窗',
            features: [
              '✓ 买入确认弹窗',
              '✓ 卖出确认弹窗',
              '✓ 成功提示弹窗',
            ],
            route: '/trading-confirm',
          ),
          
          const SizedBox(height: 30),
          
          // 文档链接
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: Colors.orange.shade700),
                      const SizedBox(width: 10),
                      Text(
                        '📚 文档',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '• API文档: lib/component/dialog/README.md',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '• 使用示例: lib/component/dialog/EXAMPLES.md',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '• 源代码: lib/component/dialog/custom_dialog.dart',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 核心功能列表
          Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.green.shade700),
                      const SizedBox(width: 10),
                      Text(
                        '✨ 核心功能',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildFeatureItem('遮罩显示/隐藏配置'),
                  _buildFeatureItem('遮罩颜色自定义'),
                  _buildFeatureItem('外部控制器 (Controller)'),
                  _buildFeatureItem('自定义内容 Widget'),
                  _buildFeatureItem('淡入淡出 + 缩放动画'),
                  _buildFeatureItem('点击遮罩关闭配置'),
                  _buildFeatureItem('动画时长配置'),
                  _buildFeatureItem('无障碍访问支持'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required List<String> features,
    required String route,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图标
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              // 内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...features.map(
                      (feature) => Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          feature,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 箭头
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: Colors.green),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
