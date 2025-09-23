import 'package:flutter/material.dart';

class CurrencyDetails extends StatefulWidget {
  const CurrencyDetails({super.key, required this.symbol});

  final String symbol;

  @override
  State<CurrencyDetails> createState() => _CurrencyDetailsState();
}

class _CurrencyDetailsState extends State<CurrencyDetails> {
  @override
  Widget build(BuildContext context) {
    return Text('details Page');
  }
}
