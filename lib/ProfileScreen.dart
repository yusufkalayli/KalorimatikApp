import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final User? user;

  ProfileScreen({required this.user});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  int _currentStep = 0;
  String? _selectedGender;
  String? _activityLevel;

  void _nextStep() {
    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) _currentStep--;
    });
  }

  void _saveUserProfile() async {
    try {
      await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.user!.uid)
          .set({
        'gender': _selectedGender,
        'age': int.parse(_ageController.text),
        'height': int.parse(_heightController.text),
        'weight': int.parse(_weightController.text),
        'goalWeight': int.parse(_goalWeightController.text),
        'activityLevel': _activityLevel,
        'goalDuration': int.parse(_durationController.text),
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Profil başarıyla kaydedildi')));
      Navigator.popUntil(context, ModalRoute.withName('/'));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil kaydedilirken hata oluştu: $e')));
    }
  }

  Widget _buildGenderSelection() {
    return Column(
      children: [
        Text('Cinsiyetinizi seçin', style: TextStyle(fontSize: 20)),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = 'Erkek';
                });
                _nextStep();
              },
              child: Column(
                children: [
                  Image.asset('assets/male.png', width: 100, height: 100),
                  SizedBox(height: 10),
                  Text('Erkek'),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = 'Kadın';
                });
                _nextStep();
              },
              child: Column(
                children: [
                  Image.asset('assets/female.png', width: 100, height: 100),
                  SizedBox(height: 10),
                  Text('Kadın'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDetails() {
    return Column(
      children: [
        TextField(
          controller: _ageController,
          decoration: InputDecoration(labelText: 'Yaş'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _heightController,
          decoration: InputDecoration(labelText: 'Boy (cm)'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _weightController,
          decoration: InputDecoration(labelText: 'Kilo (kg)'),
          keyboardType: TextInputType.number,
        ),
        TextField(
          controller: _goalWeightController,
          decoration: InputDecoration(labelText: 'Hedef Kilo (kg)'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _nextStep,
          child: Text('Devam Et'),
        ),
      ],
    );
  }

  Widget _buildActivityLevel() {
    return Column(
      children: [
        Text('Aktivite seviyenizi seçin', style: TextStyle(fontSize: 20)),
        SizedBox(height: 20),
        ListTile(
          title: Text('Hareketsiz'),
          onTap: () {
            setState(() {
              _activityLevel = 'Hareketsiz';
            });
            _nextStep();
          },
        ),
        ListTile(
          title: Text('Az hareketli'),
          onTap: () {
            setState(() {
              _activityLevel = 'Az hareketli';
            });
            _nextStep();
          },
        ),
        ListTile(
          title: Text('Hareketli'),
          onTap: () {
            setState(() {
              _activityLevel = 'Hareketli';
            });
            _nextStep();
          },
        ),
        ListTile(
          title: Text('Aktif hareketli'),
          onTap: () {
            setState(() {
              _activityLevel = 'Aktif hareketli';
            });
            _nextStep();
          },
        ),
      ],
    );
  }

  Widget _buildGoalDuration() {
    return Column(
      children: [
        TextField(
          controller: _durationController,
          decoration: InputDecoration(labelText: 'Hedef Süre (gün)'),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _saveUserProfile,
          child: Text('Kaydet'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_currentStep == 0) _buildGenderSelection(),
            if (_currentStep == 1) _buildProfileDetails(),
            if (_currentStep == 2) _buildActivityLevel(),
            if (_currentStep == 3) _buildGoalDuration(),
            if (_currentStep > 0)
              TextButton(
                onPressed: _previousStep,
                child: Text('Geri'),
              ),
          ],
        ),
      ),
    );
  }
}
