import 'package:flutter/material.dart';
import 'package:metamask_demo/components/custom_button.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late W3MService _w3mService;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MetaMask SDK Dapp'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Spacer(),
          CustomButton(title: 'Connect', onPressed: () {}),
          CustomButton(title: 'Clear Session', onPressed: () {}),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeState();
  }

  _connect() async {}

  void initializeState() async {
    _w3mService = W3MService(
      projectId: '91fea5ea39fc5898af040c6fd6c478c2',
      metadata: const PairingMetadata(
        name: 'Web3Modal Flutter Example',
        description: 'Web3Modal Flutter Example',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'flutterdapp://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );
    await _w3mService.init();
  }
}
