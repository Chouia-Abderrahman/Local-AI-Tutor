import 'package:flutter/material.dart';

import '../model/model_setup_banner.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ModelSetupBanner(),
          SizedBox(height: 48),
          _EmptyLibrary(),
        ],
      ),
    );
  }
}

class _EmptyLibrary extends StatelessWidget {
  const _EmptyLibrary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(
          Icons.picture_as_pdf_outlined,
          size: 64,
          color: theme.colorScheme.outline,
        ),
        const SizedBox(height: 16),
        Text('No documents yet', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        const Text('Importing PDFs and text files comes next.'),
      ],
    );
  }
}
