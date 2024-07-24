import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kalorimatik/FoodEntryScreen.dart';

class UserProfileScreen extends StatefulWidget {
  final User? user;

  UserProfileScreen({required this.user});

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? userProfileData;
  double? bmi;
  double? idealWeight;
  double? dailyWater;
  double? bmr;
  double? dailyCalories;
  double? activityLevelValue; // Aktivite seviyesi değeri

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() async {
    if (widget.user != null) {
      var userProfile = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(widget.user!.uid)
          .get();
      if (userProfile.exists) {
        setState(() {
          userProfileData = userProfile.data();
          _calculateBMI();
          _calculateIdealWeight();
          _calculateBMR();
          _calculateActivityLevel();
          _calculateDailyCalories();
          _calculateDailyWater();
        });
      }
    }
  }

  void _calculateBMI() {
    if (userProfileData != null) {
      double height =
          userProfileData!['height'] / 100; // Boyu metre cinsine çevir
      double weight = userProfileData!['weight'].toDouble();
      bmi = weight / (height * height);
    }
  }

  void _calculateIdealWeight() {
    if (userProfileData != null) {
      double height =
          userProfileData!['height'] / 100; // Boyu metre cinsine çevir
      double idealBMI = 22.0; // İdeal BMI değeri
      idealWeight = idealBMI * height * height;
    }
  }

  void _calculateBMR() {
    if (userProfileData != null) {
      int age = userProfileData!['age'];
      double height = userProfileData!['height'].toDouble();
      double weight = userProfileData!['weight'].toDouble();
      String gender = userProfileData!['gender'];

      if (gender == 'Kadın') {
        bmr = 10 * weight + 6.25 * height - 5 * age - 161;
      } else {
        bmr = 10 * weight + 6.25 * height - 5 * age + 5;
      }
    }
  }

  void _calculateActivityLevel() {
    if (userProfileData != null) {
      String activityLevel = userProfileData!['activityLevel'];
      switch (activityLevel) {
        case 'hareketsiz':
          activityLevelValue = 1.2;
          break;
        case 'Az hareketli':
          activityLevelValue = 1.375;
          break;
        case 'hareketli':
          activityLevelValue = 1.55;
          break;
        case 'Aktif hareketli':
          activityLevelValue = 1.725;
          break;
        default:
          activityLevelValue = 1.2; // Varsayılan olarak 'Hareketsiz' seviyesi
          break;
      }
    }
  }

  void _calculateDailyCalories() {
    if (bmr != null && activityLevelValue != null) {
      dailyCalories = bmr! * activityLevelValue!;
    }
  }

  void _calculateDailyWater() {
    if (userProfileData != null) {
      double weight = userProfileData!['weight'].toDouble();
      dailyWater = weight * 0.033; // Günlük su ihtiyacı hesaplama formülü
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
      ),
      body: userProfileData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Yaş: ${userProfileData!['age']}'),
                  Text('Boy: ${userProfileData!['height']} cm'),
                  Text('Kilo: ${userProfileData!['weight']} kg'),
                  Text('Hedef Kilo: ${userProfileData!['goalWeight']} kg'),
                  Text('Cinsiyet: ${userProfileData!['gender']}'),
                  Text('Hareket Tipi: ${userProfileData!['activityLevel']}'),
                  Text('Hedef Süre: ${userProfileData!['goalDuration']} gün'),
                  SizedBox(height: 16),
                  Text(
                      'Vücut Kitle İndeksi (BMI): ${bmi?.toStringAsFixed(2) ?? 'Hesaplanamadı'}'),
                  Text(
                      'İdeal Kilo: ${idealWeight?.toStringAsFixed(2) ?? 'Hesaplanamadı'} kg'),
                  Text(
                      'Bazal Metabolizma Hızı (BMR): ${bmr?.toStringAsFixed(2) ?? 'Hesaplanamadı'} kcal/gün'),
                  Text(
                      'Günlük Kalori İhtiyacı: ${dailyCalories?.toStringAsFixed(2) ?? 'Hesaplanamadı'} kcal'),
                  Text(
                      'Günlük Su İhtiyacı: ${dailyWater?.toStringAsFixed(2) ?? 'Hesaplanamadı'} Litre '),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                FoodEntryScreen(user: widget.user)),
                      );
                    },
                    child: Text('Yemek Girişi Yap'),
                  ),
                ],
              ),
            ),
    );
  }
}
