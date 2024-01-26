import 'package:flutter/material.dart';
import 'package:metamask_demo/components/custom_button.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

import '../components/custom_app_bar.dart';
import '../components/method_dialog.dart';
import '../constants/colors.dart';
import '../models/chain_metadata.dart';
import '../utilities/logger.dart';

class HomeScreen extends StatefulWidget {
  final W3MService service;
  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final W3MService _w3mService;

  @override
  void initState() {
    _w3mService = widget.service;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final session = _w3mService.session!;
    final iconImage =
        session.sessionData?.peer.metadata.icons.firstOrNull ?? '';
    final List<Widget> children = [];
    // Get current active account
    final accounts = session.getAccounts() ?? [];
    try {
      final currentNamespace = _w3mService.selectedChain!.namespace;
      final chainsNamespaces = NamespaceUtils.getChainsFromAccounts(accounts);
      if (chainsNamespaces.contains(currentNamespace)) {
        final account = accounts.firstWhere(
          (account) => account.contains('$currentNamespace:'),
        );
        children.add(_buildAccountWidget(account));
      }
    } catch (e) {
      logger.d('[$runtimeType] ${e.toString()}');
    }
    return PopScope(
      canPop: true,
      onPopInvoked: (value) async {
        await disconnectWallet();
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'MetaMask SDK Dapp'),
        backgroundColor: Web3ModalTheme.colorsOf(context).background125,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              W3MAccountButton(service: _w3mService),
              Row(
                children: [
                  if (iconImage.isNotEmpty)
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: NetworkImage(iconImage),
                    ),
                  Expanded(
                    child: Text(
                      session.connectedWalletName ?? '',
                      style: Web3ModalTheme.getDataOf(context)
                          .textStyles
                          .large600
                          .copyWith(
                            color:
                                Web3ModalTheme.colorsOf(context).foreground100,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: session.topic != null,
                child: Column(
                  children: [
                    Text(
                      'Session Topic',
                      style: Web3ModalTheme.getDataOf(context)
                          .textStyles
                          .small600
                          .copyWith(
                            color:
                                Web3ModalTheme.colorsOf(context).foreground100,
                          ),
                    ),
                    Text(
                      '${session.topic}',
                      style: Web3ModalTheme.getDataOf(context)
                          .textStyles
                          .small400
                          .copyWith(
                            color:
                                Web3ModalTheme.colorsOf(context).foreground100,
                          ),
                    ),
                  ],
                ),
              ),
              ..._buildSupportedChainsWidget(),
              ...children,
              CustomButton(
                title: "Disconnect",
                onPressed: disconnectWallet,
                padding: const EdgeInsets.all(16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSupportedChainsWidget() {
    List<Widget> children = [];
    children.addAll(
      [
        const SizedBox(height: 8),
        Text(
          'Supported chains:',
          style: Web3ModalTheme.getDataOf(context).textStyles.small600.copyWith(
                color: Web3ModalTheme.colorsOf(context).foreground100,
              ),
        ),
      ],
    );
    final approvedChains = _w3mService.getApprovedChains() ?? <String>[];
    children.add(
      Text(
        approvedChains.join(', '),
        style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
    );
    return children;
  }

  disconnectWallet() async {
    if (_w3mService.isConnected) {
      await _w3mService.disconnect();
      if (!_w3mService.isConnected) {
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildAccountWidget(String namespaceAccount) {
    final chainId = NamespaceUtils.getChainFromAccount(namespaceAccount);
    final account = NamespaceUtils.getAccount(namespaceAccount);
    final chainMetadata = getChainMetadataFromChain(chainId);

    final List<Widget> children = [
      Text(
        chainMetadata.w3mChainInfo.chainName,
        style: Web3ModalTheme.getDataOf(context).textStyles.title600.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
      const SizedBox(height: 8),
      Text(
        account,
        style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
              color: Web3ModalTheme.colorsOf(context).foreground100,
            ),
      ),
    ];

    children.addAll([
      const SizedBox(height: 8),
      Text(
        'Methods',
        style:
            Web3ModalTheme.getDataOf(context).textStyles.paragraph600.copyWith(
                  color: Web3ModalTheme.colorsOf(context).foreground100,
                ),
      ),
    ]);
    children.addAll(_buildChainMethodButtons(chainMetadata, account));

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: chainMetadata.color),
        borderRadius: const BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  List<Widget> _buildChainMethodButtons(
    ChainMetadata chainMetadata,
    String address,
  ) {
    // Add Methods
    final approvedMethods = _w3mService.getApprovedMethods() ?? <String>[];
    if (approvedMethods.isEmpty) {
      return [
        Text(
          'No methods approved',
          style: Web3ModalTheme.getDataOf(context).textStyles.small400.copyWith(
                color: Web3ModalTheme.colorsOf(context).foreground100,
              ),
        )
      ];
    }
    final usableMethods = [
      "personal_sign",
      "eth_signTransaction",
      "eth_sendTransaction",
    ];
    //
    final List<Widget> children = [
      CustomButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        title: _getButtonName(usableMethods[0]),
        onPressed: approvedMethods.contains(usableMethods[0])
            ? () async {
                String? message = await _showMessageDialogue();
                final future = _w3mService.request(
                  topic: _w3mService.session?.topic ?? '',
                  chainId: chainMetadata.w3mChainInfo.namespace,
                  request: SessionRequestParams(
                    method: usableMethods[0],
                    params: [
                      address,
                      message,
                    ],
                  ),
                );
                if (message != null) {
                  if (!mounted) return;
                  MethodDialog.show(context, usableMethods[0], future);
                  await _w3mService.launchConnectedWallet();
                }
              }
            : null,
      ),
      CustomButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        title: _getButtonName(usableMethods[1]),
        onPressed: approvedMethods.contains(usableMethods[1])
            ? () async {
                // final future = callChainMethod(
                //   chainMetadata.type,
                //   method,
                //   chainMetadata,
                //   address,
                // );
                // //MethodDialog.show(context, method, future);
              }
            : null,
      ),
      CustomButton(
        padding: const EdgeInsets.symmetric(vertical: 8),
        title: _getButtonName(usableMethods[2]),
        onPressed: approvedMethods.contains(usableMethods[2])
            ? () async {
                // final future = callChainMethod(
                //   chainMetadata.type,
                //   method,
                //   chainMetadata,
                //   address,
                // );
                // //MethodDialog.show(context, method, future);
                // await _w3mService.launchConnectedWallet();
              }
            : null,
      ),
    ];

    if (chainMetadata.w3mChainInfo.chainId == '1') {}
    // {
    //   children.add(
    //     Container(
    //       height: 40,
    //       width: double.infinity,
    //       margin: const EdgeInsets.symmetric(vertical: 8),
    //       child: ElevatedButton(
    //         onPressed: () async {
    //           final future = EIP155.testContractCall(
    //             w3mService: widget.w3mService,
    //           );
    //           MethodDialog.show(context, 'Test TetherToken Contract', future);
    //         },
    //         style: ButtonStyle(
    //           backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
    //           shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    //             RoundedRectangleBorder(
    //               borderRadius: BorderRadius.circular(8),
    //             ),
    //           ),
    //         ),
    //         child: Text(
    //           'Test TetherToken Contract',
    //           style: Web3ModalTheme.getDataOf(context)
    //               .textStyles
    //               .small600
    //               .copyWith(
    //             color: Web3ModalTheme.colorsOf(context).foreground100,
    //           ),
    //         ),
    //       ),
    //     ),
    //   );
    // }

    return children;
  }

  ChainMetadata getChainMetadataFromChain(String namespace) {
    try {
      return ChainDataWrapper.chains
          .where((element) => element.w3mChainInfo.namespace == namespace)
          .first;
    } catch (_) {
      return ChainMetadata(
        color: Colors.grey,
        type: ChainType.eip155,
        w3mChainInfo: W3MChainPresets.chains.values.firstWhere(
          (e) => e.namespace == namespace,
        ),
      );
    }
  }

  String _getButtonName(String method) {
    switch (method) {
      case "personal_sign":
        return 'Personal Sign';
      case "eth_signTransaction":
        return 'Sign Transaction';
      case "eth_sendTransaction":
        return 'Send Transaction';
      default:
        return 'NA';
    }
  }

  _showMessageDialogue() {
    return showModalBottomSheet<String?>(
        enableDrag: true,
        isDismissible: false,
        useRootNavigator: true,
        context: context,
        backgroundColor: Web3ModalTheme.colorsOf(context).background175,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        )),
        isScrollControlled: true,
        builder: (context) {
          String? message;
          return ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
            child: Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'Message: ',
                        textAlign: TextAlign.center,
                        style: Web3ModalTheme.getDataOf(context)
                            .textStyles
                            .title400
                            .copyWith(
                              color: Web3ModalTheme.colorsOf(context)
                                  .foreground100,
                            ),
                      ),
                      Flexible(
                          child: TextField(
                        onChanged: (value) {
                          message = value;
                        },
                        onSubmitted: (value) {
                          message = value;
                          Navigator.of(context).pop(message);
                        },
                        cursorColor: kAccentRed,
                        style: Web3ModalTheme.getDataOf(context)
                            .textStyles
                            .title400
                            .copyWith(
                              color: Web3ModalTheme.colorsOf(context)
                                  .foreground100,
                            ),
                      )),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Dismiss",
                          style: TextStyle(
                              color: kAccentRed, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(message);
                        },
                        child: const Text(
                          "Ok",
                          style: TextStyle(
                              color: kAccentRed, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

  // Future<dynamic> callChainMethod(
  //     ChainType type,
  //     String method,
  //     ChainMetadata chainMetadata,
  //     String address,
  //     ) {
  //   final session = _w3mService.session!;
  //   switch (type) {
  //     case ChainType.eip155:
  //       return EIP155.callMethod(
  //         w3mService: _w3mService,
  //         topic: session.topic ?? '',
  //         method: method,
  //         chainId: chainMetadata.w3mChainInfo.namespace,
  //         address: address.toLowerCase(),
  //       );
  //     default:
  //       return Future<dynamic>.value();
  //   }
  // }
}

class ChainDataWrapper {
  static final List<ChainMetadata> chains = [
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.blue.shade300,
      w3mChainInfo: W3MChainPresets.chains['1']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade300,
      w3mChainInfo: W3MChainPresets.chains['137']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade900,
      w3mChainInfo: W3MChainPresets.chains['42161']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.red.shade400,
      w3mChainInfo: W3MChainPresets.chains['43114']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.yellow.shade600,
      w3mChainInfo: W3MChainPresets.chains['56']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: const Color(0xFF123962),
      w3mChainInfo: W3MChainPresets.chains['250']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.red.shade700,
      w3mChainInfo: W3MChainPresets.chains['10']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.blue.shade800,
      w3mChainInfo: W3MChainPresets.chains['9001']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade800,
      w3mChainInfo: W3MChainPresets.chains['4689']!,
    ),
    ChainMetadata(
      type: ChainType.eip155,
      color: Colors.purple.shade700,
      w3mChainInfo: W3MChainPresets.chains['1088']!,
    ),
    // const ChainMetadata(
    //   type: ChainType.solana,
    //   chainId: 'solana:4sGjMW1sUnHzSxGspuhpqLDx6wiyjNtZ',
    //   name: 'Solana',
    //   logo: 'TODO',
    //   color: Colors.black,
    //   rpc: [
    //     "https://solana-api.projectserum.com",
    //   ],
    // ),
    // ChainMetadata(
    //   type: ChainType.kadena,
    //   chainId: 'kadena:mainnet01',
    //   name: 'Kadena',
    //   logo: 'TODO',
    //   color: Colors.purple.shade600,
    //   rpc: [
    //     "https://api.testnet.chainweb.com",
    //   ],
    // ),
  ];
}
