import 'package:flutter/material.dart';
import 'welcome_screen.dart'; // Import the welcome screen

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  _GoalSelectionScreenState createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  int _selectedGoalIndex = -1;

  final List<Map<String, dynamic>> _goals = [
    {
      'icon': Icons.water_drop,
      'color': Colors.green,
      'text': 'Drink More Water',
    },
    {
      'icon': Icons.bubble_chart,
      'color': Colors.blue,
      'text': 'Improve digestions',
    },
    {
      'icon': Icons.local_hospital,
      'color': Colors.purple,
      'text': 'Lead a Healty Lifestyle',
    },
    {'icon': Icons.fitness_center, 'color': Colors.grey, 'text': 'Lose weight'},
    {
      'icon': Icons.explore,
      'color': Colors.yellow,
      'text': 'Just trying out the app, mate!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Assessment'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: 1 / 17, // First step of 17
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Select Your Goal',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedGoalIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                _selectedGoalIndex == index
                                    ? _goals[index]['color']
                                    : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          color:
                              _selectedGoalIndex == index
                                  ? _goals[index]['color'].withOpacity(0.1)
                                  : Colors.white,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _goals[index]['color'],
                            child: Icon(
                              _goals[index]['icon'],
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            _goals[index]['text'],
                            style: TextStyle(
                              color:
                                  _selectedGoalIndex == index
                                      ? Colors.black
                                      : Colors.grey.shade600,
                            ),
                          ),
                          trailing:
                              _selectedGoalIndex == index
                                  ? Icon(
                                    Icons.check_circle,
                                    color: _goals[index]['color'],
                                  )
                                  : null,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _selectedGoalIndex != -1
                      ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const WelcomeScreen(),
                          ),
                        );
                      }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Continue',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
