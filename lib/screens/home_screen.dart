import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/color_tile.dart';
import '../models/palette_color.dart';
import '../services/palette_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
    final TextEditingController _promptController = TextEditingController();

    List<PaletteColor> _palette = [
      const PaletteColor(
        color: Color(0xFF24382F),
        name: 'Forest',
      ),
      const PaletteColor(
        color: Color(0xFF6A4635),
        name: 'Earth',
      ),
      const PaletteColor(
        color: Color(0xFFC47A3D),
        name: 'Autumn',
      ),
      const PaletteColor(
        color: Color(0xFFD69A5B),
        name: 'Amber',
      ),
      const PaletteColor(
        color: Color(0xFFE8D8B5),
        name: 'Cream',
      ),
    ];

    int _paletteGeneration = 0;
    final PaletteService _paletteService = PaletteService();

    bool _isGenerating = false;

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
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 1100,
              ),
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
          onPressed: () {},
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
          color: theme.colorScheme.outlineVariant.withValues(
            alpha: 0.5,
          ),
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
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              )
            : const Icon(Icons.auto_awesome),
        label: Text(
          _isGenerating
              ? 'GENERATING...'
              : 'GENERATE PALETTE',
        ),
        style: FilledButton.styleFrom(
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
              children: List.generate(
                _palette.length,
                (index) {
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
                },
              ),
            ),
          );
        }

        return SizedBox(
          height: 420,
          child: Row(
            children: List.generate(
              _palette.length,
              (index) {
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
              },
            ),
          ),
        );
      },
    );
  }

  void _toggleLock(int index) {
    setState(() {
      final currentColor = _palette[index];

      _palette[index] = currentColor.copyWith(
        isLocked: !currentColor.isLocked,
      );
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
        currentPalette: _palette,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _palette = generatedPalette;
        _paletteGeneration++;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to generate palette. Please try again.',
            ),
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

}