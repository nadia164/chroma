import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/color_tile.dart';
import '../models/palette_color.dart';
import '../services/palette_service.dart';
import '../models/saved_palette.dart';
import '../services/palette_storage_service.dart';
import 'saved_palettes_screen.dart';
import '../services/theme_controller.dart';

class HomeScreen extends StatefulWidget {
  final ThemeController themeController;

  const HomeScreen({super.key, required this.themeController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();

  List<PaletteColor> _palette = [
    const PaletteColor(color: Color(0xFF24382F), name: 'Forest'),
    const PaletteColor(color: Color(0xFF6A4635), name: 'Earth'),
    const PaletteColor(color: Color(0xFFC47A3D), name: 'Autumn'),
    const PaletteColor(color: Color(0xFFD69A5B), name: 'Amber'),
    const PaletteColor(color: Color(0xFFE8D8B5), name: 'Cream'),
  ];

  int _paletteGeneration = 0;
  final PaletteService _paletteService = PaletteService();

  final PaletteStorageService _paletteStorageService = PaletteStorageService();

  bool _isGenerating = false;
  bool _isCurrentPaletteSaved = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(colorScheme),
                  const SizedBox(height: 56),
                  _buildIntroduction(theme),
                  const SizedBox(height: 32),
                  _buildPromptInput(theme),
                  const SizedBox(height: 20),
                  _buildGenerateButton(colorScheme),
                  const SizedBox(height: 12),
                  _buildSaveButton(colorScheme),
                  const SizedBox(height: 48),
                  _buildPalettePreview(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          'CHROMA',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SavedPalettesScreen()),
            );
          },
          icon: const Icon(Icons.bookmark_border_rounded),
          tooltip: 'My Palettes',
        ),
        IconButton(
          onPressed: _showThemePicker,
          icon: const Icon(Icons.brightness_6_outlined),
          tooltip: 'Change theme',
        ),
      ],
    );
  }

  Widget _buildIntroduction(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Turn a feeling\ninto color.',
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w900,
            height: 0.95,
            letterSpacing: -1.5,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Describe a mood, place, object, or idea and create a palette around it.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPromptInput(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: TextField(
        controller: _promptController,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Try "Autumn forest"...',
          prefixIcon: const Icon(Icons.auto_awesome_outlined),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: FilledButton.icon(
        onPressed: _isGenerating ? null : _generatePalette,
        icon: _isGenerating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(_isGenerating ? 'GENERATING...' : 'GENERATE PALETTE'),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        onPressed: _isCurrentPaletteSaved ? null : _savePalette,
        icon: Icon(
          _isCurrentPaletteSaved
              ? Icons.bookmark_rounded
              : Icons.bookmark_border_rounded,
        ),
        label: Text(_isCurrentPaletteSaved ? 'SAVED' : 'SAVE PALETTE'),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildPalettePreview() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        if (isMobile) {
          return SizedBox(
            height: 600,
            child: Column(
              children: List.generate(_palette.length, (index) {
                return Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.96,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: ColorTile(
                      key: ValueKey(
                        '${_paletteGeneration}_${_palette[index].color.toARGB32()}',
                      ),
                      paletteColor: _palette[index],
                      onLockChanged: () {
                        _toggleLock(index);
                      },
                    ),
                  ),
                );
              }),
            ),
          );
        }

        return SizedBox(
          height: 420,
          child: Row(
            children: List.generate(_palette.length, (index) {
              return Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(
                          begin: 0.96,
                          end: 1.0,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: ColorTile(
                    key: ValueKey(
                      '${_paletteGeneration}_${_palette[index].color.toARGB32()}',
                    ),
                    paletteColor: _palette[index],
                    onLockChanged: () {
                      _toggleLock(index);
                    },
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  void _toggleLock(int index) {
    setState(() {
      final currentColor = _palette[index];

      _palette[index] = currentColor.copyWith(isLocked: !currentColor.isLocked);

      _isCurrentPaletteSaved = false;
    });
  }

  Future<void> _generatePalette() async {
    if (_isGenerating) {
      return;
    }

    HapticFeedback.lightImpact();

    setState(() {
      _isGenerating = true;
    });

    try {
      final generatedPalette = await _paletteService.generatePalette(
        prompt: _promptController.text,
        currentPalette: _palette,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _palette = generatedPalette;
        _paletteGeneration++;
        _isCurrentPaletteSaved = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Unable to generate palette. Please try again.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _savePalette() async {
    final palette = SavedPalette(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      prompt: _promptController.text.trim().isEmpty
          ? 'Untitled Palette'
          : _promptController.text.trim(),
      colors: List<PaletteColor>.from(_palette),
      createdAt: DateTime.now(),
    );

    try {
      await _paletteStorageService.savePalette(palette);

      if (!mounted) {
        return;
      }

      setState(() {
        _isCurrentPaletteSaved = true;
      });

      HapticFeedback.lightImpact();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Palette saved'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Unable to save palette.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  void _showThemePicker() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final currentTheme = widget.themeController.themeMode;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Appearance',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how Chroma should look.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context: context,
                  title: 'System',
                  icon: Icons.brightness_auto_outlined,
                  mode: ThemeMode.system,
                  currentTheme: currentTheme,
                ),
                _buildThemeOption(
                  context: context,
                  title: 'Light',
                  icon: Icons.light_mode_outlined,
                  mode: ThemeMode.light,
                  currentTheme: currentTheme,
                ),
                _buildThemeOption(
                  context: context,
                  title: 'Dark',
                  icon: Icons.dark_mode_outlined,
                  mode: ThemeMode.dark,
                  currentTheme: currentTheme,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentTheme,
  }) {
    final isSelected = mode == currentTheme;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: isSelected ? const Icon(Icons.check_rounded) : null,
      selected: isSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onTap: () async {
        await widget.themeController.setThemeMode(mode);

        if (!context.mounted) {
          return;
        }

        Navigator.of(context).pop();
      },
    );
  }
}
