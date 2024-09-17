import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'tapping_game_screen.dart';
import 'animated_button.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late VideoPlayerController _controller;
  int _selectedTimeLimit = 10;
  final List<int> _timeOptions = [10, 20, 30, 40, 50, 60];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/videos/vid.mp4')
      ..initialize().then((_) {
        setState(() {});
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
          backgroundColor: Colors.deepPurple,
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
