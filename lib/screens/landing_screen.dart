import 'package:flutter/material.dart';
import 'package:metamask_demo/components/custom_app_bar.dart';
import 'package:metamask_demo/components/custom_button.dart';
import 'package:web3modal_flutter/pages/select_network_page.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';
import 'package:web3modal_flutter/widgets/widget_stack/widget_stack_singleton.dart';

import '../utilities/logger.dart';
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
    logger.i(hash);
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
      projectId: "91fea5ea39fc5898af040c6fd6c478c2",
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

    _w3mService.addListener(_serviceListener);
    _w3mService.onSessionEventEvent.subscribe(_onSessionEvent);
    _w3mService.onSessionUpdateEvent.subscribe(_onSessionUpdate);
    _w3mService.onSessionConnectEvent.subscribe(_onSessionConnect);
    _w3mService.onSessionDeleteEvent.subscribe(_onSessionDelete);
  }

  @override
  void dispose() {
    _w3mService.onSessionEventEvent.unsubscribe(_onSessionEvent);
    _w3mService.onSessionUpdateEvent.unsubscribe(_onSessionUpdate);
    _w3mService.onSessionConnectEvent.unsubscribe(_onSessionConnect);
    _w3mService.onSessionDeleteEvent.unsubscribe(_onSessionDelete);
    super.dispose();
  }

  void _serviceListener() {
    setState(() {});
  }

  void _onSessionEvent(SessionEvent? args) {
    logger.i('[$runtimeType] _onSessionEvent $args');
  }

  void _onSessionUpdate(SessionUpdate? args) {
    logger.i('[$runtimeType] _onSessionUpdate $args');
  }

  void _onSessionConnect(SessionConnect? args) {
    logger.i('[$runtimeType] _onSessionConnect $args');
  }

  void _onSessionDelete(SessionDelete? args) {
    logger.i('[$runtimeType] _onSessionDelete $args');
  }
}

const _chainId = "11155111";

final _sepoliaChain = W3MChainInfo(
  chainName: 'Sepolia',
  namespace: 'eip155:$_chainId',
  chainId: _chainId,
  tokenName: 'ETH',
  rpcUrl: 'https://sepolia.infura.io/v3/d66891f4698b4fe68397ad9394ad66d3',
  blockExplorer: W3MBlockExplorer(
    name: 'Sepolia Explorer',
    url: 'https://sepolia.etherscan.io/',
  ),
);
