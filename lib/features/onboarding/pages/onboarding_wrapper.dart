import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingWrapper extends StatefulWidget {
  final VoidCallback onFinish;
  const OnboardingWrapper({super.key, required this.onFinish});

  @override
  State<OnboardingWrapper> createState() => _OnboardingWrapperState();
}

class _OnboardingWrapperState extends State<OnboardingWrapper> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _onNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuart,
      );
    } else {
      _onFinish();
    }
  }

  void _onFinish() {
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header: Skip Action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _onFinish,
                    child: Text(
                      'Lewati',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Content
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildPage1(),
                  _buildPage2(),
                  _buildPage3(),
                ],
              ),
            ),

            // Footer: Progress & Navigation
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  // Progress Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      final isActive = index == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 24 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : AppColors.outline.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 48),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 10,
                        shadowColor: AppColors.primary.withValues(alpha: 0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == 2 ? 'Mulai' : 'Selanjutnya',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return OnboardingPageContent(
      title: 'Manajemen Penuh Kesadaran',
      description:
          'Atur hari Anda dengan niat dan kejelasan, bukan sekadar daftar tugas harian.',
      illustration: Stack(
        alignment: Alignment.center,
        children: [
          // Background soft blur
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
            ),
          ),
          // Illustration Person (Using generic Icon as placeholder for the painterly illustration)
          const Icon(
            Icons.self_improvement,
            size: 200,
            color: AppColors.primary,
          ),
          // Floating Bubbles
          _buildFloatingBubble(
            Alignment.topRight,
            const Offset(-40, 40),
            Icons.calendar_today,
            AppColors.primaryContainer,
          ),
          _buildFloatingBubble(
            Alignment.topLeft,
            const Offset(40, 80),
            Icons.schedule,
            AppColors.secondaryContainer,
          ),
          _buildFloatingBubble(
            Alignment.bottomLeft,
            const Offset(60, -60),
            Icons.check_circle,
            AppColors.tertiaryContainer,
          ),
        ],
      ),
    );
  }

  Widget _buildPage2() {
    return OnboardingPageContent(
      title: 'Fokus dan Aliran',
      description:
          'Kuasai produktivitas Anda dengan pengatur waktu Pomodoro dan analitik berwawasan.',
      illustration: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(60),
              color: AppColors.surfaceContainer.withValues(alpha: 0.8),
            ),
          ),
          const Icon(
            Icons.spa,
            size: 180,
            color: AppColors.secondary,
          ),
          // Pomodoro Card
          Positioned(
            top: 20,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10)
                ],
              ),
              child: const Column(
                children: [
                  Text('FOKUS',
                      style: TextStyle(fontSize: 10, letterSpacing: 1.5)),
                  Text('25:00',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage3() {
    return OnboardingPageContent(
      title: 'Mulai Perjalanan Anda',
      description:
          'Bergabunglah dengan ribuan orang yang telah menemukan ritme sempurna mereka dengan TaskBuddy.',
      illustration: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Container(
              width: 240,
              height: 300,
              color: AppColors.surfaceContainerLow,
              child: const Icon(Icons.groups, size: 120, color: AppColors.tertiary),
            ),
          ),
          Positioned(
            bottom: -10,
            right: -10,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.tertiaryContainer,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 32),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingBubble(Alignment alignment, Offset offset,
      IconData icon, Color color) {
    return Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
