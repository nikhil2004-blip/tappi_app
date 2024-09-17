import 'package:flutter/material.dart';
import 'dart:math';
import 'package:video_player/video_player.dart';
import 'dart:async';
void main() {
  runApp(MyApp());
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapping Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StartScreen(),
    );
  }
}


class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late VideoPlayerController _controller;
  int _selectedTimeLimit = 10; // Default time limit in seconds
  final List<int> _timeOptions = [10, 20, 30, 40, 50, 60]; // Time options for dropdown

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/vid.mp4')
      ..initialize().then((_) {
        setState(() {}); // Ensure the UI gets updated after initialization
        _controller.play();
        _controller.setLooping(true);
      }).catchError((error) {
        print('Error initializing video player: $error');
      });
  }

  void _showStartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple, // Gamey background color
          title: Text(
            'Select Time Limit',
            style: TextStyle(
              color: Colors.yellowAccent,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.purple[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<int>(
                  value: _selectedTimeLimit,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.purple[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  dropdownColor: Colors.purple[100],
                  items: _timeOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                        decoration: BoxDecoration(
                          color: Colors.purple[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$value SEC',
                          style: TextStyle(color: Colors.black87, fontSize: 20),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _selectedTimeLimit = newValue!;
                    });
                  },
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TappingGameScreen(
                        timeLimit: _selectedTimeLimit,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellowAccent,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  textStyle: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
                child: Text(
                  'START',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          titlePadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _controller.value.isInitialized
              ? Positioned.fill(
            child: VideoPlayer(_controller),
          )
              : Center(child: CircularProgressIndicator()),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedButton(
                  text: "PLAY",
                  onPressed: _showStartDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class AnimatedButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;

  AnimatedButton({required this.text, required this.onPressed});

  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween(begin: 1.0, end: 0.95).animate(_controller);
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.yellowAccent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontFamily: 'Roboto',
            ),
          ),
        ),
      ),
    );
  }
}
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
  Color _dotColor = Colors.yellowAccent; // Default dot color
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
    final double scoreBarHeight = 120.0; // Height of the score and timing bar
    final double ballSize = 80.0; // Ball size

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
        _triggerTapAnimation(); // Add this line
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
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.purple[900], // Dark purple background
          title: Center(
            child: Text(
              'Game Over',
              style: TextStyle(
                color: Colors.redAccent, // Bold and contrasting color
                fontSize: 34, // Large font size
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                letterSpacing: 2, // Letter spacing for a gamey look
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
                  letterSpacing: 1.5, // Consistent letter spacing
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
                  letterSpacing: 1.5, // Consistent letter spacing
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
            SizedBox(height: 20), // Add spacing below the button
          ],
          titlePadding: EdgeInsets.all(20),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double scoreBarHeight = 120.0; // Height of the score and timing bar

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


class BorderPainter extends CustomPainter {
  final double scoreBarHeight;

  BorderPainter(this.scoreBarHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth =0.1;

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height - scoreBarHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



