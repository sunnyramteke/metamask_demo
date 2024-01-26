import 'package:flutter/material.dart';
import 'package:metamask_demo/components/custom_app_bar.dart';
import 'package:metamask_demo/components/custom_button.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

import 'home_screen.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({
    super.key,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late W3MService _w3mService;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  void _onPersonalSign() async {
    await _w3mService.launchConnectedWallet();
    var hash = await _w3mService.web3App?.request(
      topic: _w3mService.session!.topic!,
      chainId: 'eip155:$_chainId',
      request: const SessionRequestParams(
        method: 'personal_sign',
        params: ['GM from W3M flutter!!', '0xdeadbeef'],
      ),
    );
    debugPrint(hash);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCustom = Web3ModalTheme.isCustomTheme(context);

    return Scaffold(
      appBar: const CustomAppBar(title: 'MetaMask SDK Dapp'),
      backgroundColor: Web3ModalTheme.colorsOf(context).background125,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          CustomButton(
            title: 'Connect',
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              if (!_w3mService.isConnected) {
                await _w3mService.openModal(context, SelectNetworkPage(
                  onTapNetwork: (info) {
                    _w3mService.selectChain(info);
                    widgetStack.instance.addDefault();
                  },
                ));
                if (_w3mService.isConnected) {
                  if (!mounted) return;
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => HomeScreen(service: _w3mService)));
                }
              }
            },
          ),
          CustomButton(
            title: 'Clear Session',
            padding: const EdgeInsets.all(16),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No Action Added'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _initializeService() async {
    W3MChainPresets.chains.putIfAbsent('11155111', () => _sepoliaChain);
    _w3mService = W3MService(
      projectId: "005f407b9fc2a7d933227a43707545cb",
      logLevel: LogLevel.error,
      metadata: const PairingMetadata(
        name: 'metamask_demo',
        description: 'A new Flutter project.',
        url: 'https://www.walletconnect.com/',
        icons: ['https://walletconnect.com/walletconnect-logo.png'],
        redirect: Redirect(
          native: 'metamask_demo://',
          universal: 'https://www.walletconnect.com',
        ),
      ),
    );
    await _w3mService.init();
  }
}

const _chainId = "11155111";

final _sepoliaChain = W3MChainInfo(
  chainName: 'Sepolia',
  namespace: 'eip155:$_chainId',
  chainId: _chainId,
  tokenName: 'ETH',
  rpcUrl: 'https://rpc.sepolia.org/',
  blockExplorer: W3MBlockExplorer(
    name: 'Sepolia Explorer',
    url: 'https://sepolia.etherscan.io/',
  ),
);
