import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sowon_ai/screen/chat_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _imageFadeController;
  late AnimationController _textFadeController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _imageFadeAnimation;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    _rotationAnimation =
        Tween<double>(begin: 0, end: 1).animate(_rotationController);

    _imageFadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _imageFadeAnimation =
        Tween<double>(begin: 1, end: 0).animate(_imageFadeController);

    _textFadeController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _textFadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(_textFadeController);

    Future.delayed(const Duration(seconds: 2), () {
      _imageFadeController.forward();
      Future.delayed(const Duration(seconds: 1), () {
        _textFadeController.forward();
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const ChatScreen()),
          );
        });
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _imageFadeController.dispose();
    _textFadeController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            FadeTransition(
              opacity: _imageFadeAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: Image.asset(
                  "assets/images/sowonai.png",
                  width: 100,
                ),
              ),
            ),
            FadeTransition(
              opacity: _textFadeAnimation,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Sowon_AI',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.chat,
                    color: Colors.blueAccent,
                    size: 35,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
