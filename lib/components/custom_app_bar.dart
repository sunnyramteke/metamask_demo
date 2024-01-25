import 'package:flutter/material.dart';
import 'package:metamask_demo/controllers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:web3modal_flutter/theme/w3m_theme_widget.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isCustom = Web3ModalTheme.isCustomTheme(context);

    return AppBar(
      title: Text(title),
      backgroundColor: Web3ModalTheme.colorsOf(context).background175,
      foregroundColor: Web3ModalTheme.colorsOf(context).foreground100,
      actions: [
        IconButton(
          icon: Web3ModalTheme.maybeOf(context)?.isDarkMode ?? false
              ? const Icon(Icons.light_mode_outlined)
              : const Icon(Icons.dark_mode_outlined),
          onPressed: Provider.of<DarkThemeProvider>(context, listen: false)
              .changeTheme,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
