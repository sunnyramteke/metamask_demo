import 'package:flutter/material.dart';
import 'package:metamask_demo/components/custom_button.dart';
import 'package:web3modal_flutter/services/w3m_service/w3m_service.dart';
import 'package:web3modal_flutter/theme/w3m_theme_widget.dart';

import '../components/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  final W3MService service;
  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final W3MService _w3mService;
  bool canPop = false;

  @override
  void initState() {
    _w3mService = widget.service;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvoked: (value) async {
        await disconnectWallet();
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'MetaMask SDK Dapp'),
        backgroundColor: Web3ModalTheme.colorsOf(context).background125,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomButton(
              title: "Disconnect",
              onPressed: disconnectWallet,
              padding: EdgeInsets.all(16),
            ),
          ],
        ),
      ),
    );
  }

  disconnectWallet() async {
    if (_w3mService.isConnected) {
      await _w3mService.disconnect();
      if (!_w3mService.isConnected) {
        if (!mounted) return;
        setState(() {
          canPop = true;
        });
        Navigator.of(context).pop();
      }
    }
  }
}
