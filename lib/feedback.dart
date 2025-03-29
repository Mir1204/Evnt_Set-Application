import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Evntset Feedback',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: FeedbackPage(),
    );
  }
}

enum YesNo { yes, no, somewhat }

class FeedbackPage extends StatefulWidget {
  @override
  _FeedbackPageState createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  // Question 1: Overall Experience Rating
  double _overallExperience = 3.0;

  // Question 2: Favorite Part (Text)
  final _favoritePartController = TextEditingController();

  // Question 3: Likelihood to Recommend (Rating)
  double _recommendRating = 3.0;

  // Question 4: Did the event meet your expectations? (Radio)
  YesNo? _expectations = YesNo.yes;

  // Question 5: Suggestions for Improvement (Text)
  final _improvementsController = TextEditingController();

  // Question 6: Additional Comments (Text)
  final _additionalCommentsController = TextEditingController();

  // Question 7: Feedback on Speakers (Text)
  final _speakersFeedbackController = TextEditingController();

  // Question 8: How engaging were the sessions? (Rating)
  double _sessionEngagement = 3.0;

  // Question 9: How was the event organization? (Rating)
  double _organizationRating = 3.0;

  // Question 10: Would you attend future events? (Radio)
  YesNo? _futureAttendance = YesNo.yes;

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation for submit button
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 200),
    );
    _scaleAnimation =
        Tween<double>(begin: 1.0, end: 1.05).animate(_animationController);
  }

  @override
  void dispose() {
    _favoritePartController.dispose();
    _improvementsController.dispose();
    _additionalCommentsController.dispose();
    _speakersFeedbackController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _submitFeedback() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      // Process and show feedback summary
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Thank You!'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. Overall Experience: $_overallExperience stars'),
                  SizedBox(height: 4),
                  Text('2. Favorite Part: ${_favoritePartController.text.trim()}'),
                  SizedBox(height: 4),
                  Text('3. Recommendation: $_recommendRating stars'),
                  SizedBox(height: 4),
                  Text(
                      '4. Met Expectations: ${_expectations == YesNo.yes ? "Yes" : _expectations == YesNo.no ? "No" : "Somewhat"}'),
                  SizedBox(height: 4),
                  Text('5. Improvement Suggestions: ${_improvementsController.text.trim()}'),
                  SizedBox(height: 4),
                  Text('6. Additional Comments: ${_additionalCommentsController.text.trim()}'),
                  SizedBox(height: 4),
                  Text('8. Session Engagement: $_sessionEngagement stars'),
                  SizedBox(height: 4),
                  Text('9. Organization Rating: $_organizationRating stars'),
                  SizedBox(height: 4),
                  Text(
                      '10. Future Attendance: ${_futureAttendance == YesNo.yes ? "Yes" : _futureAttendance == YesNo.no ? "No" : "Somewhat"}'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _formKey.currentState!.reset();
                  _favoritePartController.clear();
                  _improvementsController.clear();
                  _additionalCommentsController.clear();
                  _speakersFeedbackController.clear();
                  setState(() {
                    _overallExperience = 3.0;
                    _recommendRating = 3.0;
                    _sessionEngagement = 3.0;
                    _organizationRating = 3.0;
                    _expectations = YesNo.yes;
                    _futureAttendance = YesNo.yes;
                  });
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.lightBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.lightBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: EdgeInsets.all(12), child: child),
    );
  }

  Widget _buildRadioOption(YesNo value, String label, YesNo? groupValue,
      ValueChanged<YesNo?> onChanged) {
    return Row(
      children: [
        Radio<YesNo>(
          value: value,
          groupValue: groupValue,
          activeColor: Colors.lightBlue,
          onChanged: onChanged,
        ),
        Text(label, style: TextStyle(fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Gradient background for a modern look.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue.shade50, Colors.lightBlue.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 16),
                  Center(
                    child: Text(
                      'We Value Your Feedback!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Question 1: Overall Experience Rating
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '1. How would you rate your overall experience?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _overallExperience,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _overallExperience = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Question 2: Favorite Part of the Event
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '2. What was your favorite part of the event?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _favoritePartController,
                          decoration: _buildInputDecoration('Share your thoughts'),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please share your favorite part';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  // Question 3: Likelihood to Recommend
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3. How likely are you to recommend this event to a friend?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _recommendRating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.green,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _recommendRating = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Question 4: Event Expectations
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '4. Did the event meet your expectations?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadioOption(YesNo.yes, 'Yes', _expectations,
                                    (value) {
                                  setState(() {
                                    _expectations = value;
                                  });
                                }),
                            _buildRadioOption(YesNo.no, 'No', _expectations,
                                    (value) {
                                  setState(() {
                                    _expectations = value;
                                  });
                                }),
                            _buildRadioOption(
                                YesNo.somewhat, 'Somewhat', _expectations,
                                    (value) {
                                  setState(() {
                                    _expectations = value;
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Question 5: Suggestions for Improvement
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '5. What improvements would you suggest?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _improvementsController,
                          decoration: _buildInputDecoration('Your suggestions'),
                          maxLines: 3,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please share your suggestions';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  // Question 6: Additional Comments
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '6. Any additional comments?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _additionalCommentsController,
                          decoration: _buildInputDecoration('Your comments'),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),

                  // Question 8: Session Engagement
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '7. How engaging were the sessions?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _sessionEngagement,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.orange,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _sessionEngagement = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Question 9: Event Organization
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '8. How would you rate the event organization?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Center(
                          child: RatingBar.builder(
                            initialRating: _organizationRating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.purple,
                            ),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _organizationRating = rating;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Question 10: Future Attendance
                  _buildCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '9. Would you attend future events?',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildRadioOption(YesNo.yes, 'Yes', _futureAttendance,
                                    (value) {
                                  setState(() {
                                    _futureAttendance = value;
                                  });
                                }),
                            _buildRadioOption(YesNo.no, 'No', _futureAttendance,
                                    (value) {
                                  setState(() {
                                    _futureAttendance = value;
                                  });
                                }),
                            _buildRadioOption(YesNo.somewhat, 'Somewhat', _futureAttendance,
                                    (value) {
                                  setState(() {
                                    _futureAttendance = value;
                                  });
                                }),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // Animated Submit Button
                  Center(
                    child: GestureDetector(
                      onTapDown: (_) => _animationController.forward(),
                      onTapUp: (_) {
                        _animationController.reverse();
                        _submitFeedback();
                      },
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 32),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 6,
                          ),
                          child: Text(
                            'Submit Feedback',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
