import 'package:flutter/material.dart';

class AppLoadingOverlayController extends ChangeNotifier {
  int _activeRequests = 0;
  String _message = 'Memuat halaman...';

  bool get isVisible => _activeRequests > 0;
  String get message => _message;

  void show({String message = 'Memuat halaman...'}) {
    _activeRequests += 1;
    _message = message;
    notifyListeners();
  }

  void hide() {
    if (_activeRequests == 0) {
      return;
    }

    _activeRequests -= 1;
    if (_activeRequests == 0) {
      _message = 'Memuat halaman...';
    }
    notifyListeners();
  }

  Future<T> run<T>(
    Future<T> Function() action, {
    String message = 'Memuat halaman...',
  }) async {
    show(message: message);
    try {
      return await action();
    } finally {
      hide();
    }
  }
}

class AppLoadingOverlay extends StatefulWidget {
  const AppLoadingOverlay({super.key, required this.child});

  final Widget child;

  static AppLoadingOverlayController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<_AppLoadingOverlayScope>();
    assert(
      scope != null,
      'AppLoadingOverlay is not available in this context.',
    );
    return scope!.controller;
  }

  @override
  State<AppLoadingOverlay> createState() => _AppLoadingOverlayState();
}

class _AppLoadingOverlayState extends State<AppLoadingOverlay> {
  late final AppLoadingOverlayController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppLoadingOverlayController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AppLoadingOverlayScope(
      controller: _controller,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child!,
              IgnorePointer(
                ignoring: !_controller.isVisible,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _controller.isVisible ? 1 : 0,
                  child: _LoadingSplashView(message: _controller.message),
                ),
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

class _AppLoadingOverlayScope extends InheritedWidget {
  const _AppLoadingOverlayScope({
    required this.controller,
    required super.child,
  });

  final AppLoadingOverlayController controller;

  @override
  bool updateShouldNotify(_AppLoadingOverlayScope oldWidget) {
    return controller != oldWidget.controller;
  }
}

Route<T> buildLoadingSplashRoute<T>({
  required RouteSettings settings,
  required WidgetBuilder builder,
  Duration duration = const Duration(milliseconds: 850),
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return LoadingSplashGate(duration: duration, child: builder(context));
    },
  );
}

class LoadingSplashGate extends StatefulWidget {
  const LoadingSplashGate({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 850),
  });

  final Widget child;
  final Duration duration;

  @override
  State<LoadingSplashGate> createState() => _LoadingSplashGateState();
}

class _LoadingSplashGateState extends State<LoadingSplashGate> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _hideSplashLater();
  }

  Future<void> _hideSplashLater() async {
    await Future<void>.delayed(widget.duration);
    if (!mounted) {
      return;
    }
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        IgnorePointer(
          ignoring: !_showSplash,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: _showSplash ? 1 : 0,
            child: const _LoadingSplashView(),
          ),
        ),
      ],
    );
  }
}

class _LoadingSplashView extends StatelessWidget {
  const _LoadingSplashView({this.message = 'Memuat halaman...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFFF8F3EA),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.45, end: 1),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOut,
        builder: (context, opacity, child) {
          return Opacity(opacity: opacity, child: child);
        },
        onEnd: () {},
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    _SkeletonBlock(width: 74, height: 18, radius: 8),
                    Spacer(),
                    _SkeletonBlock(width: 88, height: 18, radius: 999),
                  ],
                ),
                const SizedBox(height: 28),
                const _SkeletonBlock(width: 164, height: 30, radius: 12),
                const SizedBox(height: 10),
                const _SkeletonBlock(width: 230, height: 14, radius: 999),
                const SizedBox(height: 22),
                const _SkeletonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBlock(width: double.infinity, height: 52),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          _SkeletonCircle(size: 56),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SkeletonBlock(width: 160, height: 16),
                                SizedBox(height: 10),
                                _SkeletonBlock(width: 120, height: 12),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const _SkeletonCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonBlock(width: 112, height: 16),
                      SizedBox(height: 16),
                      _SkeletonBlock(width: double.infinity, height: 14),
                      SizedBox(height: 10),
                      _SkeletonBlock(width: double.infinity, height: 14),
                      SizedBox(height: 10),
                      _SkeletonBlock(width: 180, height: 14),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return const _SkeletonCard(
                        child: Row(
                          children: [
                            _SkeletonCircle(size: 52),
                            SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _SkeletonBlock(width: 140, height: 14),
                                  SizedBox(height: 10),
                                  _SkeletonBlock(
                                    width: double.infinity,
                                    height: 12,
                                  ),
                                  SizedBox(height: 10),
                                  _SkeletonBlock(width: 110, height: 12),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 14),
                    itemCount: 3,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 18, top: 8),
                  child: Center(
                    child: Text(
                      message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF82766B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    required this.width,
    required this.height,
    this.radius = 10,
  });

  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8DED1),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFE8DED1),
        shape: BoxShape.circle,
      ),
    );
  }
}
