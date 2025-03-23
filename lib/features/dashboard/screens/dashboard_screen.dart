import 'package:flutter/material.dart';
import 'package:map_mayhem/app/routes.dart';
import 'package:map_mayhem/presentation/themes/app_colors.dart';
import 'package:map_mayhem/presentation/themes/app_text_styles.dart';

/// The main dashboard/home screen of the app.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Mayhem'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRouter.settingsRoute);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User greeting
            const Text(
              'Welcome to Map Mayhem!',
              style: AppTextStyles.gameTitle,
            ),
            const SizedBox(height: 8),
            const Text(
              'Test your geography knowledge with interactive map challenges.',
              style: AppTextStyles.gameInstruction,
            ),
            const SizedBox(height: 24),

            // Game modes section
            const Text(
              'Game Modes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Practice mode card
            _buildGameModeCard(
              context,
              title: 'Practice Mode',
              description: 'Learn at your own pace with spaced repetition',
              icon: Icons.school,
              color: AppColors.primary,
              onTap: () {
                Navigator.pushNamed(context, AppRouter.gameRoute);
              },
            ),
            const SizedBox(height: 16),

            // Challenge mode card (disabled in MVP)
            _buildGameModeCard(
              context,
              title: 'Challenge Mode',
              description: 'Test your knowledge against the clock',
              icon: Icons.timer,
              color: AppColors.secondary,
              onTap: null,
              isDisabled: true,
              disabledText: 'Coming Soon',
            ),
            const SizedBox(height: 16),

            // Custom mode card (disabled in MVP)
            _buildGameModeCard(
              context,
              title: 'Custom Mode',
              description: 'Create your own custom region playlists',
              icon: Icons.playlist_add_check,
              color: AppColors.accent,
              onTap: null,
              isDisabled: true,
              disabledText: 'Coming Soon',
            ),

            const Spacer(),

            // Progress stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    value: '0',
                    label: 'Countries Learned',
                    icon: Icons.public,
                  ),
                  _StatItem(
                    value: '0',
                    label: 'Sessions Completed',
                    icon: Icons.check_circle,
                  ),
                  _StatItem(
                    value: '0%',
                    label: 'Accuracy',
                    icon: Icons.analytics,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    bool isDisabled = false,
    String disabledText = '',
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
            if (isDisabled)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    disabledText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
