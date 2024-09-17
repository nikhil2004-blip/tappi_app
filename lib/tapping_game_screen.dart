import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'border_painter.dart';
import 'animated_button.dart';
import 'start_screen.dart';

class TappingGameScreen extends StatefulWidget {
  final int timeLimit;

  TappingGameScreen({required this.timeLimit});

  @override
  _TappingGameScreenState createState() => _TappingGameScreenState();
}

class _TappingGameScreenState extends State<TappingGameScreen> with SingleTickerProviderStateMixin {
  int _score = 0;
  double _xPosition = 0.0;
  double _yPosition = 0.0;
  final Random _random = Random();
  Color _dotColor = Colors.yellowAccent;
  late Timer _gameTimer;
  int _timeRemaining = 0;
  late AnimationController _animationController;
  bool _isGameOver = false;
  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.timeLimit;
    _startTimer();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _gameTimer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timeRemaining > .2) {
        setState(() {
          _timeRemaining--;
        });
      } else {
        timer.cancel();
        if (!_isGameOver) {
          _isGameOver = true;
          _showGameOverDialog();
        }
      }
    });
  }


  void _triggerTapAnimation() {
    final scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(_animationController);
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  void _generateNewPosition() {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final double scoreBarHeight = 120.0;
    final double ballSize = 80.0;

    setState(() {
      _xPosition = _random.nextDouble() * (width - ballSize);
      _yPosition = _random.nextDouble() * (height - scoreBarHeight - ballSize);
    });
  }

  void _onTap() {
    if (_timeRemaining > 0) {
      setState(() {
        _score++;
        _generateNewPosition();
        _triggerTapAnimation();
      });
    }
  }

  void _changeDotColor(Color color) {
    setState(() {
      _dotColor = color;
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.purple[900],
          title: Center(
            child: Text(
              'Game Over',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 34,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                letterSpacing: 2,
              ),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Score: $_score',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Time Up!',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
          actions: [
            Center(
              child: AnimatedButton(
                text: 'Close',
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => StartScreen()),
                        (route) => false,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
          titlePadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scoreBarHeight = 120.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/pic.jpg',
              fit: BoxFit.cover,
            ),
          ),
          CustomPaint(
            painter: BorderPainter(scoreBarHeight),
            child: Stack(
              children: [
                Positioned(
                  left: _xPosition,
                  top: _yPosition,
                  child: GestureDetector(
                    onTap: _onTap,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.black,
                          width:.8,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/ball.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  bottom: 10,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: Text(
                    'Time Left: $_timeRemaining s',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}