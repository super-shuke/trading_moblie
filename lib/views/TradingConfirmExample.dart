import 'package:flutter/material.dart';
import 'package:tradingMt1/component/dialog/index.dart';

/// 实战示例：交易确认弹窗
/// 在真实的交易场景中使用弹窗来确认买入/卖出操作
class TradingConfirmExample extends StatefulWidget {
  const TradingConfirmExample({super.key});

  @override
  State<TradingConfirmExample> createState() => _TradingConfirmExampleState();
}

class _TradingConfirmExampleState extends State<TradingConfirmExample> {
  // 买入确认弹窗控制器
  final CustomDialogController _buyConfirmController = CustomDialogController();
  
  // 卖出确认弹窗控制器
  final CustomDialogController _sellConfirmController = CustomDialogController();
  
  // 成功提示弹窗控制器
  final CustomDialogController _successController = CustomDialogController();

  String _selectedCoin = 'BTC/USDT';
  double _amount = 1.0;

  @override
  void dispose() {
    _buyConfirmController.dispose();
    _sellConfirmController.dispose();
    _successController.dispose();
    super.dispose();
  }

  // 处理买入
  void _handleBuy() {
    _buyConfirmController.hide();
    // 模拟交易API调用
    Future.delayed(const Duration(milliseconds: 500), () {
      _successController.show();
    });
  }

  // 处理卖出
  void _handleSell() {
    _sellConfirmController.hide();
    // 模拟交易API调用
    Future.delayed(const Duration(milliseconds: 500), () {
      _successController.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易示例'),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          // 主界面
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 交易对选择
                const Text(
                  '交易对',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _selectedCoin,
                  isExpanded: true,
                  items: ['BTC/USDT', 'ETH/USDT', 'BNB/USDT']
                      .map((coin) => DropdownMenuItem(
                            value: coin,
                            child: Text(coin),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCoin = value!;
                    });
                  },
                ),
                const SizedBox(height: 30),
                
                // 交易数量
                const Text(
                  '数量',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '请输入交易数量',
                  ),
                  onChanged: (value) {
                    _amount = double.tryParse(value) ?? 1.0;
                  },
                ),
                const SizedBox(height: 40),
                
                // 买入/卖出按钮
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _buyConfirmController.show(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          '买入',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _sellConfirmController.show(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: const Text(
                          '卖出',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 买入确认弹窗
          ListenableBuilder(
            listenable: _buyConfirmController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _buyConfirmController.isVisible,
                config: const CustomDialogConfig(
                  dismissible: false, // 不允许点击遮罩关闭
                  maskColor: Color(0x80000000),
                ),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '确认买入',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('交易对：'),
                          Text(
                            _selectedCoin,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('数量：'),
                          Text(
                            _amount.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _buyConfirmController.hide(),
                              child: const Text('取消'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleBuy,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                              child: const Text(
                                '确认买入',
                                style: TextStyle(color: Colors.white),
                              ),
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
          
          // 卖出确认弹窗
          ListenableBuilder(
            listenable: _sellConfirmController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _sellConfirmController.isVisible,
                config: const CustomDialogConfig(
                  dismissible: false,
                  maskColor: Color(0x80000000),
                ),
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_down,
                        color: Colors.red,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '确认卖出',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('交易对：'),
                          Text(
                            _selectedCoin,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('数量：'),
                          Text(
                            _amount.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => _sellConfirmController.hide(),
                              child: const Text('取消'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _handleSell,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                '确认卖出',
                                style: TextStyle(color: Colors.white),
                              ),
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
          
          // 成功提示弹窗
          ListenableBuilder(
            listenable: _successController,
            builder: (context, child) {
              return CustomDialog(
                isVisible: _successController.isVisible,
                config: const CustomDialogConfig(
                  maskColor: Color(0x80000000),
                ),
                onClose: () => _successController.hide(),
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 60,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        '交易成功！',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '您的订单已提交',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => _successController.hide(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          minimumSize: const Size(double.infinity, 45),
                        ),
                        child: const Text(
                          '确定',
                          style: TextStyle(color: Colors.white),
                        ),
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
